//
//  ContentView.swift
//  ABAlbumKitExample
//
//  Created by Abenx on 2020/10/20.
//

import SwiftUI
import ABAlbumKit
import Photos

struct ContentView: View {
    @State private var mediaType: Int = 0
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                
                List {
                    Section {
                        NavigationLink(destination: AlbumView().environmentObject(ABAlbumViewModel(PHAssetMediaType(rawValue: self.mediaType)!))
) {
                            HStack {
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                Text("Album")
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationBarTitle(Text("ABAlbumKit"))
                
                
                Toggle("Multiple choice", isOn: .constant(true))
                    .padding(.horizontal)
                Divider()

                HStack {
                Text("Media type").padding(.horizontal)
                Picker("Media type", selection: self.$mediaType) {
                    Image(systemName: "rectangle.stack.person.crop").tag(0)
                    Image(systemName: "photo.fill").tag(1)
                    Image(systemName: "video.fill").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                }
                
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
