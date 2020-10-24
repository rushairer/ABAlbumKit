import SwiftUI
import ABSwiftKitExtension
import ASCollectionView
import Photos

public typealias AssetSelectedHandler<PHAsset> = ((PHAsset) -> Void)

public struct ABAlbumView: View {
    @EnvironmentObject var albumViewModel: ABAlbumViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var assets: [PHAsset] = []
    @State var showsAlbumList = false
    
    private typealias SectionID = Int

    private var leading: AnyView?
    private var trailing: AnyView?
    
    private var contextMenuProvider: ContextMenuProvider<PHAsset>?
    private var assetSelectedHandler: AssetSelectedHandler<PHAsset>?
    
    public init(contextMenuProvider: ContextMenuProvider<PHAsset>? = nil,
                assetSelectedHandler: AssetSelectedHandler<PHAsset>? = nil) {
        self.initHandlers(contextMenuProvider, assetSelectedHandler)
    }
    
    public init<L: View, T: View>(leading: L,
                                  trailing: T,
                                  contextMenuProvider: ContextMenuProvider<PHAsset>? = nil,
                                  assetSelectedHandler: AssetSelectedHandler<PHAsset>? = nil) {
        self.leading = AnyView(leading)
        self.trailing = AnyView(trailing)
        
        self.initHandlers(contextMenuProvider, assetSelectedHandler)
    }
    
    public init<L: View>(leading: L,
                         contextMenuProvider: ContextMenuProvider<PHAsset>? = nil,
                         assetSelectedHandler: AssetSelectedHandler<PHAsset>? = nil) {
        self.leading = AnyView(leading)
        
        self.initHandlers(contextMenuProvider, assetSelectedHandler)
    }
    
    public init<T: View>(trailing: T,
                         contextMenuProvider: ContextMenuProvider<PHAsset>? = nil,
                         assetSelectedHandler: AssetSelectedHandler<PHAsset>? = nil) {
        self.trailing = AnyView(trailing)
        
        self.initHandlers(contextMenuProvider, assetSelectedHandler)
    }
    
    private mutating func initHandlers(_ contextMenuProvider: ContextMenuProvider<PHAsset>? = nil,
                                       _ assetSelectedHandler: AssetSelectedHandler<PHAsset>? = nil) {
        if contextMenuProvider != nil {
            self.contextMenuProvider = contextMenuProvider
        }
        
        if assetSelectedHandler != nil {
            self.assetSelectedHandler = assetSelectedHandler
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Color(.systemBackground)
                .navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarItems(
                    leading:
                        self.navbarView
                        .frame(width: geometry.size.width)
                )
            ZStack(alignment: .top) {
                self.gridView
                    .onReceive(self.albumViewModel.$selectedAlbumIndex) { index in
                        self.assets = self.albumViewModel.getPhotoAssetsFromSelectedAlbum()
                        self.showsAlbumList = false
                    }
                self.maskView
                ABAlbumListView()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.75, alignment: .center)
                    .offset(x: 0, y: self.showsAlbumList ? 0 : -geometry.size.height * 0.75 - geometry.safeAreaInsets.top)
                    .animation(.easeInOut, value: self.showsAlbumList)
            }
            .modifier(HiddenModifier(isHidden: !self.albumViewModel.isAuthorized))
            
            self.emptyView
                .modifier(HiddenModifier(isHidden: self.albumViewModel.isAuthorized))
        }
        .environmentObject(self.albumViewModel)
        .foregroundColor(.primary)
    }
}

extension ABAlbumView
{
    private var gridView: some View {
        if self.assets.count == 0 {
            return AnyView(Color
                            .clear
                            .overlay(Text("No Photos")))
        } else {
            return AnyView(ASCollectionView(section: self.section)
                            .layout(self.layout))
        }
    }
    
    private var maskView: some View {
        Color.black.opacity(self.showsAlbumList ? 0.8 : 0).onTapGesture {
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
                    Text(self.albumViewModel.selectedAlbum()?.title ?? "Album")
                        .animation(nil)
                    Image(systemName: "chevron.down.circle.fill")
                        .foregroundColor(Color(.secondaryLabel))
                        .rotationEffect(Angle(degrees: self.showsAlbumList ? 180 : 0), anchor: .center)
                        .animation(.easeInOut, value: self.showsAlbumList)
                }
                .animation(.easeOut, value: self.albumViewModel.selectedAlbumIndex)
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
    
    private var section: ASCollectionViewSection<SectionID> {
        ASCollectionViewSection(
            id: 0,
            data: self.assets,
            dataID: \.self,
            onCellEvent: self.onCellEvent,
            contextMenuProvider: self.contextMenuProvider) { asset, _ in
            ABAlbumCellView(asset: asset).onTapGesture {
                guard self.assetSelectedHandler != nil else { return }
                self.assetSelectedHandler!(asset)
            }
        }
    }
    
    private func onCellEvent(_ event: CellEvent<PHAsset>) {
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
    
    private func cellNumber() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, windowScene.activationState == .foregroundActive || windowScene.activationState == .background, let _ = windowScene.windows.first else { return 3.0 }
        
        if windowScene.interfaceOrientation == .landscapeLeft || windowScene.interfaceOrientation == .landscapeRight {
            if UIDevice.current.type == .iPad {
                return 7.0
            } else {
                return 6.0
            }
        } else {
            if UIDevice.current.type == .iPad {
                return 5.0
            } else {
                return 3.0
            }
        }
    }
    
    private var layout: ASCollectionLayout<Int> {
        ASCollectionLayout(scrollDirection: .vertical, interSectionSpacing: 0) {
            ASCollectionLayoutSection {
                let fractionalWidth = 1 / self.cellNumber()
                let gridBlockSize = NSCollectionLayoutDimension.fractionalWidth(fractionalWidth)
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
