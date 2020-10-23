//
//  AlbumView.swift
//  ABAlbumKitExample
//
//  Created by Abenx on 2020/10/19.
//

import SwiftUI
import ABAlbumKit

struct AlbumView: View {
    @Environment(\.presentationMode) var presentationMode
    private var albumViewModel = ABAlbumViewModel()
    
    var body: some View {
        let backButton = Button (action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .padding()
        }
        
        let cameraButton = Button (action: {
            
        }) {
            Image(systemName: "camera.fill")
                .padding()
        }
        
        ABAlbumView(leading: backButton,
                    trailing: cameraButton)
            .navigationBarBackButtonHidden(true)
            .environmentObject(self.albumViewModel)
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView()
    }
}
