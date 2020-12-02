//
//  ViewModels.swift
//  ARAddress
//
//  Created by O'Brien, Patrick on 11/20/20.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

class ARMapViewModel: NSObject, HasARModel, ObservableObject {
    typealias AnchorID = UUID
    @Published var arView: ARView = ARView(frame: .zero)
    @Published var currentAnnotations = [ScreenSpaceEntity]()
    @Published var dataList = [AnchorID: AnnotationData]()
    @Published var annotationType: AnnotationType = .screenspace
    
    var currentAddress: Address?
    @Published var lm = LocationManager()

    
    
    private var subscription: Cancellable!
    
    override init() {
        super.init()
        
        let initialConfig = ARGeoTrackingConfiguration()
        initialConfig.planeDetection = [.horizontal]
        //arView.debugOptions = [.showAnchorOrigins]
        self.arViewGestureSetup()
        checkAvailability()
        arView.session.delegate = self
        subscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in
            self.updateScreenEntities(on: $0)
        }
        arView.session.run(initialConfig)
    }
    
    func checkAvailability() {
        ARGeoTrackingConfiguration.checkAvailability { (available, error) in
            if !available {
                let errorDescription = error?.localizedDescription ?? ""
                print(errorDescription)
            }
        }
    }
    
    func addGeoAnchor() {
        guard let coord = self.lm.currentCoordinate else { return }
        let anchor = ARGeoAnchor(coordinate: coord)
        guard let point = arView.project(SIMD3<Float>(x: anchor.transform.columns.3.x, y: anchor.transform.columns.3.y, z: anchor.transform.columns.3.z)) else { return }
        guard let address = lm.currentAddress else { return }
        let tempData = AnnotationData(id: anchor.identifier, title: address.title, subtitle: address.subtitle, location: point, type: .screenspace)
        dataList[anchor.identifier] = tempData
        arView.session.add(anchor: anchor)
    }
    
//    func addGeoAnchor() {
//        // FOR TEST OVERLOAD
//        let anchor = ARGeoAnchor(coordinate: CLLocationCoordinate2D(latitude: 37.780041, longitude: -122.204275))
//        arView.session.add(anchor: anchor)
//    }

    func updateScreenEntities(on event: SceneEvents.Update) {
        for screenAnnot in currentAnnotations {
            guard let screenPoint = arView.project(screenAnnot.position) else { return }
            
            // Calculates whether the note can be currently visible by the camera.
            let cameraForward = arView.cameraTransform.matrix.columns.2.xyz
            let cameraToWorldPointDirection = normalize(screenAnnot.transform.translation - arView.cameraTransform.translation)
            let dotProduct = dot(cameraForward, cameraToWorldPointDirection)
            let isVisible = dotProduct < 0

            // Updates the screen position of the note based on its visibility
            screenAnnot.location = screenPoint
        }
    }
}

extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        return self[SIMD3(0, 1, 2)]
    }
}

extension ARMapViewModel: ARSessionDelegate {

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors.compactMap({ $0 as? ARGeoAnchor }) {
            if let data = dataList[anchor.identifier] {
                let annotation = ScreenSpaceEntity(worldTransform: anchor.transform, data: data, loc: data.location)
                currentAnnotations.append(annotation)
                arView.scene.addAnchor(annotation)
            }
        }
        
//        for anchor in anchors.compactMap({ $0 as? ARGeoAnchor }) {
//            guard let address = currentAddress else { return }
//            switch annotationType {
//            case .screenspace:
//                guard let point = arView.project(SIMD3<Float>(x: anchor.transform.columns.3.x, y: anchor.transform.columns.3.y, z: anchor.transform.columns.3.z)) else { return }
//                let data = AnnotationData(id: address.id, address: address, location: point, type: .screenspace)
//                let annot = ScreenSpaceEntity(worldTransform: anchor.transform, data: data)
//                currentAnnotation.append(annot)
//                arView.scene.addAnchor(annot) // Safe to unwrap
//            case .worldspace:
//                // TODO: ADD WorldSpace Annotation
////                let annotation = WorldSpaceEntity(arAnchor: anchor, data: data)
////                annotation.generateCollisionShapes(recursive: true)
////                arView.installGestures(.all, for: annotation)
////                arView.scene.addAnchor(annotation)
////                worldEntities.append(annotation)
//                print()
//            }
//        }
    }
}

// MARK: For testing
extension ARMapViewModel {
    
    func arViewGestureSetup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnARView))
        arView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tappedOnARView(_ sender: UITapGestureRecognizer) {
        // If annotationType is not selected abort touch gesture otherwise place selected Annotation
        insertTestAnnotation(sender)
    }
    
    fileprivate func insertTestAnnotation(_ sender: UITapGestureRecognizer) {
        // Get the user's tap screen location.
        let touchLocation = sender.location(in: arView)
        
        // Cast a ray to check for its intersection with any planes.
        guard let raycastResult = arView.raycast(from: touchLocation, allowing: .estimatedPlane, alignment: .any).first else {
            return
        }
        let arAnchor = ARAnchor(name: "blah", transform: raycastResult.worldTransform)
        arView.session.add(anchor: arAnchor)
    }
}
