//
//  Views.swift
//  ARAddress
//
//  Created by O'Brien, Patrick on 11/20/20.
//

import Foundation
import SwiftUI


struct ScreenSpaceView: View {
    @ObservedObject var entity: ScreenSpaceEntity
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "mappin.circle.fill").font(.system(size: 35)).padding(.leading, 10)
            VStack(alignment: .leading, spacing: 4) {
                Text(entity.data.title).font(.system(size: 14))
                Text(entity.data.subtitle).font(.system(size: 12))
            }
            Spacer()
        }
        .frame(width: 200, height: 80, alignment: .center)
        .background(Color.gray)
        .cornerRadius(25)
        .position(entity.location)
        
    }
}
