import SwiftUI
import Photos

public struct ABAlbumListView: View {
    @EnvironmentObject var albumViewModel: ABAlbumViewModel
    
    public init() {
    }
    
    public var body: some View {
        if self.albumViewModel.albums.count > 0 {
            List(self.albumViewModel.albums.indices, id: \.self) { index in
                let album = self.albumViewModel.albums[index]
                Image(album.coverImage!, scale: 1.0, label: Text(album.title))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60, alignment: .center)
                    .clipped()
                
                Text(album.title)
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                
                Text("(" + album.result.count.description + ")")
                    .foregroundColor(.secondary)
            }
            .listStyle(PlainListStyle())
        } else {
            Text("No Photos")
        }
    }
}

struct ABAlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        ABAlbumListView()
            .environmentObject(ABAlbumViewModel())
    }
}
