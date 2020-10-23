//
//  ContentView.swift
//  ABAlbumKitExample
//
//  Created by Abenx on 2020/10/20.
//

import SwiftUI
import ABAlbumKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: AlbumView()) {
                        HStack {
                            Image(systemName: "photo.fill.on.rectangle.fill")
                            Text("Album")
                        }
                    }
                }
            }
            .listStyle(
                GroupedListStyle()
            )
            .navigationBarTitle(Text("ABAlbumKit Example"))
        }
        .navigationViewStyle(
            StackNavigationViewStyle()
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
