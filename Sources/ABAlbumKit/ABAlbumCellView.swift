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
    
    private func timeFormat(second: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: second)
    }
    
    var body: some View {
        if self.albumCellViewModel.coverImage != nil {
            ZStack (alignment: .bottom) {
                Color.clear.background(
                    Image(uiImage: UIImage(cgImage: self.albumCellViewModel.coverImage!))
                        .resizable()
                        .scaledToFill()
                )
                .clipped()
                if self.asset.mediaType == .video {
                    HStack {
                        Image(systemName: "video")
                        Spacer()
                        Text(self.timeFormat(second: self.asset.duration.rounded())!)
                        
                    }
                    .padding(6)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                    .font(.caption)
                }
            }
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
