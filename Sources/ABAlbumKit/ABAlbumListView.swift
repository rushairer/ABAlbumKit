import SwiftUI
import Photos
import ABSwiftKitExtension

public struct ABAlbumListView: View {
    @EnvironmentObject var albumViewModel: ABAlbumViewModel
    
    public init() {
    }
    
    public var body: some View {
        if self.albumViewModel.albums.count > 0 {
            List {
                ForEach(self.albumViewModel.albums.indices, id: \.self) { index in
                    let album = self.albumViewModel.albums[index]
                    HStack {
                        Image(album.coverImage!, scale: 1.0, label: Text(album.title))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60, alignment: .center)
                            .clipped()
                        
                        Text(album.title)
                            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                        
                        Text("(" + album.result.count.description + ")")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(UIColor(named: "AccentColor", in: Bundle.main, compatibleWith: nil)!))
                            .padding()
                            .modifier(HiddenModifier(isHidden: index != self.albumViewModel.selectedAlbumIndex))
                    }
                    .background(Color(.systemBackground))
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        
                        withAnimation{
                            self.albumViewModel.selectedAlbumIndex = index
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .edgesIgnoringSafeArea(.horizontal)
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
