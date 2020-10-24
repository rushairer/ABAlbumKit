import SwiftUI
import Photos

let ABAlbumViewModelWorkQueueLabel = "ABAlbumViewModel.Work"

public final class ABAlbumViewModel: ObservableObject {
    @Published var albums:[ABAlbum] = []
    @Published var isAuthorized: Bool = true
    @Published var selectedAlbumIndex = 0
    
    private var mediaType:PHAssetMediaType
    private let workQueue = DispatchQueue(label: ABAlbumViewModelWorkQueueLabel, qos: .userInitiated)
    
    private var fetchOption:PHFetchOptions {
        get {
            let option = PHFetchOptions()
            if self.mediaType != PHAssetMediaType.unknown {
                option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
            }
            option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            return option
        }
    }
    
    public init(_ mediaType:PHAssetMediaType = PHAssetMediaType.unknown) {
        self.mediaType = mediaType
        
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                self.isAuthorized = status == .authorized
            }
            
            if status == .authorized {
                self.reloadAlbumData()
            }
        }
        
    }
    
    public func selectedAlbum() -> ABAlbum? {
        guard self.albums.count > self.selectedAlbumIndex else { return nil }
        return self.albums[self.selectedAlbumIndex]
    }
    
    public func reloadAlbumData() {
        self.workQueue.async { [weak self] in
            guard let self = self else { return }
            let albumArray = self.albumArray()
            DispatchQueue.main.async {
                self.albums = albumArray
            }
        }
    }
    
    public func getPhotoAssetsFromSelectedAlbum() -> [PHAsset] {
        guard self.albums.count > self.selectedAlbumIndex else { return [] }

        let result: PHFetchResult = self.albums[self.selectedAlbumIndex].result
        var photoAssets = [PHAsset]()
        result.enumerateObjects { (asset, index, stop) in
            photoAssets.append(asset)
        }
        return photoAssets
    }
    
    private func albumArray() -> [ABAlbum] {
        var albums:[ABAlbum] = []
        
        let userAlbums = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .albumRegular,
                                                                  options: nil)
        
        let syncedAlbums = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                   subtype: .albumSyncedAlbum,
                                                                   options: nil)
        
        let streamAlbums = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                   subtype: .albumMyPhotoStream,
                                                                   options: nil)
        
        let sharedAlbums = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                   subtype: .albumCloudShared,
                                                                   options: nil)
        
        let allAlbums = [userAlbums,
                         smartAlbums,
                         syncedAlbums,
                         streamAlbums,
                         sharedAlbums]
        
        var imageCacheRequestID: PHImageRequestID = 0
        
        allAlbums.forEach { fetchResult in
            (fetchResult as! PHFetchResult<PHAssetCollection>).enumerateObjects { (collection, index, stop) in
                guard collection.isKind(of: PHAssetCollection.self) else { return }
                guard collection.estimatedAssetCount > 0 else { return }
                guard collection.assetCollectionSubtype.rawValue != 1000000201
                        && collection.assetCollectionSubtype != PHAssetCollectionSubtype.smartAlbumAllHidden else { return }
                
                let result = PHAsset.fetchAssets(in: collection, options: self.fetchOption)
                guard result.count > 0 else { return }
                
                var album = ABAlbum(title: collection.localizedTitle ?? "",
                                    result: result,
                                    coverImage: UIImage(systemName: "photo.fill")?.cgImage)
                
                let maxLength = UIScreen.main.scale * 80.0
                let targetSize = CGSize(width: maxLength, height: maxLength)

                let option = PHImageRequestOptions()
                option.resizeMode = .fast
                option.isSynchronous = true
                option.deliveryMode = .highQualityFormat
                option.isNetworkAccessAllowed = true
                
                (PHCachingImageManager.default() as! PHCachingImageManager).allowsCachingHighQualityImages = false
                (PHCachingImageManager.default() as! PHCachingImageManager).startCachingImages(for: [result.firstObject!], targetSize: targetSize, contentMode: .default, options: option)
                
                let imageRequestID = PHCachingImageManager.default().requestImage(for: result.firstObject!, targetSize: targetSize, contentMode: .default, options: option) { image, info in
                    album.coverImage = image?.cgImage
                }
                
                if imageRequestID != 0 && imageCacheRequestID != 0 && imageCacheRequestID != imageRequestID {
                    PHCachingImageManager.default().cancelImageRequest(imageCacheRequestID)
                }
                imageCacheRequestID = imageRequestID
                
                if collection.assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumUserLibrary {
                    albums.insert(album, at: 0)
                } else if collection.localizedTitle == Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String {
                    albums.insert(album, at: (albums.count > 0 ? 1 : 0))
                } else {
                    albums.append(album)
                }
            }
        }
        
        return albums
    }
}
