//
//  SearchList.swift
//  ARAddress
//
//  Created by O'Brien, Patrick on 11/21/20.
//

import SwiftUI
import Snap
import MapKit

struct SearchList: View  {
    @Binding var searchTerm: String
    @Binding var nearbyAddress: [Address]
    var drawerState: AppleMapsSnapState.Visible
    var onChangeHandler: ((String) ->())?
    var onTapHandler: ((Address) ->())?
    
    var body: some View {
        VStack {
            if drawerState == .large {
                SearchBar(searchTerm: $searchTerm, drawerState: drawerState, onTypeing: onChangeHandler)
            }
            ScrollView {
                ForEach(nearbyAddress, id: \.self) { row in
                    MapRow(firstRow: row.title, secondRow: row.subtitle)
                        .onTapGesture {
                            onTapHandler?(row)
                        }
                    Divider()
                        .background(Color(.systemGray4))
                        .padding(.leading)
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var searchTerm: String
    @State var isSearching: Bool = false
    var drawerState: AppleMapsSnapState.Visible
    var onTypeing: ((String) ->())?
    
    var body: some View {
        HStack(spacing: 0) {
            HStack {
                TextField("Search an address...", text: $searchTerm)
                    .padding(.leading, 24)
                    .onChange(of: searchTerm) {
                        onTypeing?($0)
                    }
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(6)
            .padding(.horizontal)
            .onTapGesture {
                isSearching = true
            }.overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                    Spacer()
                    
                    if isSearching {
                        Button { searchTerm = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.vertical)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .foregroundColor(.gray)
            )

            if isSearching {
                Button(action: {
                    isSearching = false
                    searchTerm = ""
                    
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }, label: {
                    Text("Cancel")
                        .padding(.trailing)
                        .padding(.leading, 0)
                })
            }
        }
    }
}

struct MapRow: View {
    var firstRow: String
    var secondRow: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "mappin.circle.fill").font(.system(size: 45)).padding(.leading, 35)
            VStack(alignment: .leading, spacing: 4) {
                Text(firstRow).font(.system(size: 18))
                Text(secondRow).font(.system(size: 14))
            }
            Spacer()
        }.padding(.vertical, 5)
    }
}

struct Address: Identifiable, Hashable {
    var id: UUID
    var title: String
    var subtitle: String
}
