//
//  ContentView.swift
//  ARAddress
//
//  Created by O'Brien, Patrick on 11/20/20.
//

import SwiftUI
import RealityKit
import Snap
import UIKit
import Combine



struct ContentView : View {
    @StateObject var arViewModel = ARMapViewModel()
    @State var term = ""
    
    var body: some View {
        ZStack {
            ARContainer(arModel: arViewModel)
            ForEach(arViewModel.currentAnnotations) { entity in
                ScreenSpaceView(entity: entity)
            }
            SnapDrawer(large: .paddingToTop(24), medium: .fraction(0.4), tiny: .height(100), allowInvisible: false) { state in
                SearchList(searchTerm: $term, nearbyAddress: $arViewModel.lm.searchDataList, drawerState: state,
                           onChangeHandler: {
                            arViewModel.lm.searchForAddress(for: $0) },
                           onTapHandler:  { 
                            arViewModel.lm.getCoordinate(for: $0) {
                                arViewModel.addGeoAnchor()
                            }
                           })
            }.modifier(KeyboardAdaptive())
        }
    }
}
