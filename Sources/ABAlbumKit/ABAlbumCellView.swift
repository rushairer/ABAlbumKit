//
//  ABAlbumCellView.swift
//  ABAlbumKit
//
//  Created by Abenx on 2020/10/19.
//

import SwiftUI
import Photos


struct ABAlbumCellView: View {
    
    var asset: PHAsset
    
    @ObservedObject var albumCellViewModel: ABAlbumCellViewModel
    
    init(asset: PHAsset) {
        self.asset = asset
        self.albumCellViewModel = ABAlbumCellViewModel(asset: asset)
    }
    
    var body: some View {
        if self.albumCellViewModel.coverImage != nil {
            Color.clear.background(
                Image(uiImage: UIImage(cgImage: self.albumCellViewModel.coverImage!))
                    .resizable()
                    .scaledToFill()
            )
            .clipped()
        } else {
            Color.clear
        }
    }
}

struct ABAlbumCellView_Previews: PreviewProvider {
    static var previews: some View {
        ABAlbumCellView(asset: PHAsset())
    }
}
