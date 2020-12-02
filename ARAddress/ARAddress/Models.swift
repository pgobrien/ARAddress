//
//  Model.swift
//  ARAddress
//
//  Created by O'Brien, Patrick on 11/20/20.
//

import Foundation
import UIKit


class AnnotationData: Identifiable {
    var id: UUID
    var title: String
    var subtitle: String
    var location: CGPoint
    var type: AnnotationType
    
    init(id: UUID, title: String, subtitle: String, location: CGPoint, type: AnnotationType) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.location = location
        self.type = type
    }
}

enum AnnotationType {
    case worldspace
    case screenspace
}
