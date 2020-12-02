//
//  PGLocationManager.swift
//  ARAddress
//
//  Created by O'Brien, Patrick on 10/26/20.
//

import Foundation
import CoreLocation
import Combine
import MapKit

class LocationManager: NSObject, ObservableObject {
    
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var searchDataList: [Address] = []
    @Published var lat = ""
    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var currentAddress: Address?
    private let locationManager = CLLocationManager()
    private let searchCompleter = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.searchCompleter.delegate = self
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }

        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    func searchForAddress(for text: String) {
        guard let lastLoc = self.lastLocation else { return }
        searchCompleter.region = MKCoordinateRegion(center: lastLoc.coordinate, latitudinalMeters: 5_000, longitudinalMeters: 5_000)
        searchCompleter.queryFragment = text
    }
    
    func getCoordinate(for address: Address, completion: @escaping ()->()) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address.title + " " + address.subtitle) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                print("No Coordinate Found")
                return
            }
            self.currentCoordinate = location.coordinate
            self.currentAddress = address
        }
        completion()
    }
}

extension LocationManager: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchDataList = completer.results.filter { $0.subtitle != "Search Nearby" }.map { result in
            Address(id: UUID(), title: result.title, subtitle: result.subtitle)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        lat = String(location.coordinate.latitude)
    }

}
