//
//  AnnotationEntity.swift
//  ARAddress
//
//  Created by O'Brien, Patrick on 11/15/20.


import ARKit
import RealityKit
import SwiftUI

///// An Entity which has an anchoring component and a screen space view component, where the screen space view is a StickyNoteView.
//class WorldSpaceEntity: Entity, HasModel, HasAnchoring, HasCollision {
//    public var textModel: Entity!
//    public var isBillboarding: Bool!
//    public var arAnchor: ARAnchor!
//    public var text: String!
//
//
//    init(arAnchor: ARAnchor, isBillboarding: Bool = false, data: AnnotationData) {
//        super.init()
//        self.textModel = try! ObjectsRC.loadHeaterScene().textView as! Entity & HasCollision
//        self.addChild(textModel)
//        self.transform.matrix = arAnchor.transform
//        self.arAnchor = arAnchor
//        self.isBillboarding = isBillboarding
//        self.text = data.text
//    }
//
//    required init() {
//        fatalError("init() has not been implemented")
//    }
//}

class ScreenSpaceEntity: Entity, HasAnchoring, ObservableObject, HasScreenSpaceView {
    @Published var location: CGPoint!
    @Published var data: AnnotationData!
    
    init(worldTransform: simd_float4x4, data: AnnotationData, loc: CGPoint) {
        super.init()
        transform.matrix = worldTransform
        self.location = loc
        self.data = data
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

struct ScreenSpaceComponent: Component {
    var title: String?
    var imageName: String?
    var location: CGPoint?
}

protocol HasScreenSpaceView: Entity {
    var screenSpaceComponent: ScreenSpaceComponent { get set }
}

extension HasScreenSpaceView {
    var screenSpaceComponent: ScreenSpaceComponent {
        get { return components[ScreenSpaceComponent.self] ?? ScreenSpaceComponent() }
        set { components[ScreenSpaceComponent.self] = newValue }
    }
}

