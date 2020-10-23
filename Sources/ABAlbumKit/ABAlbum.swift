import Foundation
import Photos

public struct ABAlbum: Hashable {
    public let title: String
    public let result: PHFetchResult<PHAsset>
    public var coverImage: CGImage?
}
