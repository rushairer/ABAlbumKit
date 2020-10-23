import SwiftUI
import ABSwiftKitExtension
import ASCollectionView
import Photos

extension ABAlbumView
{
    var layout: ASCollectionLayout<Int>
    {
        ASCollectionLayout(scrollDirection: .vertical, interSectionSpacing: 0)
        {
            ASCollectionLayoutSection
            {
                let gridBlockSize = NSCollectionLayoutDimension.fractionalWidth(1 / 3.0)
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: gridBlockSize,
                        heightDimension: .fractionalHeight(1.0)))
                let inset = CGFloat(1)
                item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
                
                let itemsGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: gridBlockSize),
                    subitems: [item])
                
                let section = NSCollectionLayoutSection(group: itemsGroup)
                return section
            }
        }
    }
}

public struct ABAlbumView: View {
    @State var isReady = false
    @State var showsAlbumList = false
    @EnvironmentObject var albumViewModel: ABAlbumViewModel
    @Environment(\.presentationMode) var presentationMode
    
    private var leading: AnyView?
    private var trailing: AnyView?
    
    public init() {
    }
    
    public init<L: View, T: View>(leading: L, trailing: T) {
        self.leading = AnyView(leading)
        self.trailing = AnyView(trailing)
    }
    
    public init<L: View>(leading: L) {
        self.leading = AnyView(leading)
    }
    
    public init<T: View>(trailing: T) {
        self.trailing = AnyView(trailing)
    }
    
    private typealias SectionID = Int
    
    private var section: ASCollectionViewSection<SectionID> {
        let assets = self.albumViewModel.getPhotoAssetsFromSelectedAlbum()
        return ASCollectionViewSection(
            id: 0,
            data: assets,
            dataID: \.self,
            onCellEvent: self.onCellEvent) { asset, _ in
            ABAlbumCellView(asset: asset)
        }
    }
    
    private func onCellEvent(_ event: CellEvent<PHAsset>)
    {
        switch event
        {
        case .onAppear(_):
            break;
        case .onDisappear(_):
            break;
        case let .prefetchForData(data):
            let maxLength = UIScreen.main.scale * 80.0
            let targetSize = CGSize(width: maxLength, height: maxLength)
            let option = PHImageRequestOptions()
            option.resizeMode = .fast
            option.isSynchronous = true
            option.deliveryMode = .highQualityFormat
            option.isNetworkAccessAllowed = true
            
            (PHCachingImageManager.default() as! PHCachingImageManager).allowsCachingHighQualityImages = false
            (PHCachingImageManager.default() as! PHCachingImageManager).startCachingImages(for: data, targetSize: targetSize, contentMode: .default, options: option)
            
            break;
        case .cancelPrefetchForData(_):
            break;
        }
    }
    
    private var gridView: some View {
        let assets = self.albumViewModel.getPhotoAssetsFromSelectedAlbum()
        
        if assets.count == 0 {
            return AnyView(Color
                            .clear
                            .overlay(Text("No Photos")))
        } else {
            return AnyView(ASCollectionView(section: self.section)
                            .layout(self.layout))
        }
    }
    
    private var maskView: some View {
        Color.black.opacity(self.showsAlbumList ? 0.6 : 0).onTapGesture{
            withAnimation {
                self.showsAlbumList.toggle()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var emptyView: some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80, alignment: .center)
            HStack {
                Spacer()
                Text("Unable to access photos in album")
                    .font(.headline)
                Spacer()
            }
            .padding()
            HStack {
                Spacer()
                let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
                Text("No access to photos. Go to system setting and allow \(appName) to access all photos in album.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            Button("Go to system settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                          options: [:],
                                          completionHandler: nil)
            }
            .foregroundColor(.accentColor)
            Button("Go back") {
                self.presentationMode.wrappedValue.dismiss()
            }
            .font(.caption)
            .padding()
            Spacer()
        }
    }
    
    private var navbarView: some View {
        HStack {
            if self.leading != nil {
                self.leading
            }
            Spacer()
            VStack {
                Button(action: {
                    withAnimation {
                        self.showsAlbumList.toggle()
                    }
                }) {
                    Text("Album")
                    Image(systemName: "chevron.down.circle.fill")
                        .rotationEffect(Angle(degrees: self.showsAlbumList ? 180 : 0), anchor: .center)
                        .animation(.easeInOut(duration: 0.2), value: self.showsAlbumList)
                }
                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                .background(ABAlbumVisualEffectBlurView(blurStyle: .systemChromeMaterial, vibrancyStyle: .secondaryFill) {Color.secondary})
                .clipRounded(.xxl)
                
            }
            .pickerStyle(SegmentedPickerStyle())
            .modifier(HiddenModifier(isHidden: !self.albumViewModel.isAuthorized))

            Spacer()
            if self.trailing != nil {
                self.trailing
            }
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Color(.systemBackground)
                .navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarItems(
                    leading:
                        navbarView
                        .frame(width: geometry.size.width)
                )
            gridView
                .modifier(HiddenModifier(isHidden: !self.albumViewModel.isAuthorized))
            
            maskView
                .modifier(HiddenModifier(isHidden: !self.albumViewModel.isAuthorized))
            ABAlbumListView()
                .modifier(HiddenModifier(isHidden: !self.albumViewModel.isAuthorized))
                .frame(width: geometry.size.width, height: geometry.size.height * 0.75, alignment: .center)
                .offset(x: 0, y: self.showsAlbumList ? 0 : -geometry.size.height * 0.75 - geometry.safeAreaInsets.top)
                .animation(.easeInOut(duration: 0.2), value: self.showsAlbumList)
            emptyView
                .modifier(HiddenModifier(isHidden: self.albumViewModel.isAuthorized))
            
        }
        .environmentObject(self.albumViewModel)
        .foregroundColor(.primary)
    }
}

struct ABAlbumView_Previews: PreviewProvider {
    static let albumViewModel = ABAlbumViewModel()
    
    static var previews: some View {
        let backButton = Button (action: {
            
        }) {
            Image(systemName: "chevron.left")
                .padding()
        }
        
        let cameraButton = Button (action: {
            
        }) {
            Image(systemName: "camera.fill")
                .padding()
        }
        
        return Group {
            NavigationView {
                ABAlbumView(leading: backButton, trailing: cameraButton)
            }
            .onAppear{
                albumViewModel.isAuthorized = true
            }
            
            NavigationView {
                ABAlbumView()
            }
            .onAppear{
                albumViewModel.isAuthorized = false
            }
        }
        .environmentObject(albumViewModel)
        .preferredColorScheme(.dark)
        .environment(\.locale, .init(identifier: "zh-Hant"))
    }
}
