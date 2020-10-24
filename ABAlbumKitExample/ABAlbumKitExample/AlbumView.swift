//
//  AlbumView.swift
//  ABAlbumKitExample
//
//  Created by Abenx on 2020/10/19.
//

import SwiftUI
import ABAlbumKit

struct AlbumView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private var albumViewModel = ABAlbumViewModel()
    
    public init() {
        print("Init AlbumView")
    }
    
    var backButton: some View {
        Button (action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .padding()
        }
    }
    
    var cameraButton: some View {
        Button (action: {
            
        }) {
            Image(systemName: "camera.fill")
                .padding()
        }
    }
    
    var body: some View {
        ABAlbumView(leading: self.backButton,
                    trailing: self.cameraButton,
                    contextMenuProvider: { index, asset -> UIContextMenuConfiguration? in
                        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
                            let testAction = UIAction(title: "Do nothing") { _ in
                                //
                            }
                            let testAction2 = UIAction(title: "Do something") { _ in
                                //
                            }
                            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [testAction, testAction2])
                        }
                        return configuration
                    },
                    assetSelectedHandler: { asset in
                        print(asset.localIdentifier)
                    })
        .navigationBarBackButtonHidden(true)
        .environmentObject(self.albumViewModel)
    }
    
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView()
    }
}
