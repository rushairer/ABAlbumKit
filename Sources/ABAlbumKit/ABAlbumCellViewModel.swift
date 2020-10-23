//
//  ABAlbumCellViewModel.swift
//  ABAlbumKit
//
//  Created by Abenx on 2020/10/22.
//

import SwiftUI
import Photos

let ABAlbumCellViewModelWorkQueueLabel = "ABAlbumCellViewModel.Work"

public final class ABAlbumCellViewModel: ObservableObject {
    
    @Published var asset: PHAsset
    @Published var coverImage: CGImage = UIImage(systemName: "photo.fill")!.cgImage!
    private var imageRequestID = PHImageRequestID(0)
    
    var representedAssetIdentifier = ""
    
    private let workQueue = DispatchQueue(label: ABAlbumCellViewModelWorkQueueLabel, qos: .userInteractive)
    
    public init(asset: PHAsset) {
        self.asset = asset
        self.representedAssetIdentifier = asset.localIdentifier

        let maxLength = UIScreen.main.scale * 80.0
        let targetSize = CGSize(width: maxLength, height: maxLength)
        let option = PHImageRequestOptions()
        option.resizeMode = .fast
        option.isSynchronous = true
        option.deliveryMode = .highQualityFormat
        option.isNetworkAccessAllowed = true
        
        self.workQueue.async {
            let imageRequestID = PHCachingImageManager.default().requestImage(for: self.asset, targetSize: targetSize, contentMode: .default, options: option) { image, info in
                if self.representedAssetIdentifier == self.asset.localIdentifier {
                    DispatchQueue.main.async {
                        self.coverImage = (image?.cgImage)!
                    }
                } else {
                    PHCachingImageManager.default().cancelImageRequest(self.imageRequestID)
                }
            }
            
            if (imageRequestID != 0) && (self.imageRequestID != 0) && imageRequestID != self.imageRequestID {
                PHCachingImageManager.default().cancelImageRequest(self.imageRequestID)
            }
            
            DispatchQueue.main.async {
                self.imageRequestID = imageRequestID
            }
        }
    }
}
