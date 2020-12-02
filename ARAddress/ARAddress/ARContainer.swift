//
//  ARContainer.swift
//  ARAddress
//
//  Created by O'Brien, Patrick on 11/20/20.
//

import Foundation
import RealityKit
import SwiftUI

struct ARContainer<ARViewModel>: UIViewRepresentable where ARViewModel: HasARModel {
    @ObservedObject var arModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        return arModel.arView
        
    }
    func updateUIView(_ uiView: ARView, context: Context) {}
}

public protocol HasARModel: ObservableObject {
    var arView: ARView { get }
}
