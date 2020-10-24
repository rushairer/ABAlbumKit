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
                    trailing: self.cameraButton)
            .navigationBarBackButtonHidden(true)
            .environmentObject(self.albumViewModel)
    }
    
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView()
    }
}
