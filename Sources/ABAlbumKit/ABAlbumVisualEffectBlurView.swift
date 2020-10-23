import SwiftUI

// MARK: - ABAlbumVisualEffectBlurView

public struct ABAlbumVisualEffectBlurView<Content: View>: View {
    var blurStyle: UIBlurEffect.Style
    var vibrancyStyle: UIVibrancyEffectStyle?
    var content: Content
    
    init(blurStyle: UIBlurEffect.Style = .systemMaterial, vibrancyStyle: UIVibrancyEffectStyle? = nil, @ViewBuilder content: () -> Content) {
        self.blurStyle = blurStyle
        self.vibrancyStyle = vibrancyStyle
        self.content = content()
    }
    
    public var body: some View {
        VisualEffectView(blurStyle: self.blurStyle, vibrancyStyle: self.vibrancyStyle) {
            ZStack { self.content }
        }
        .accessibility(hidden: Content.self == EmptyView.self)
    }
}

struct VisualEffectView<Content: View>: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    var vibrancyStyle: UIVibrancyEffectStyle?
    var content: Content
    
    init(blurStyle: UIBlurEffect.Style = .systemMaterial, vibrancyStyle: UIVibrancyEffectStyle? = nil, @ViewBuilder content: () -> Content) {
        self.blurStyle = blurStyle
        self.vibrancyStyle = vibrancyStyle
        self.content = content()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self.content)
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return context.coordinator.blurView
    }
    
    func updateUIView(_ view: UIVisualEffectView, context: Context) {
        context.coordinator.update(content: content, blurStyle: blurStyle, vibrancyStyle: vibrancyStyle)
    }
    
    class Coordinator: NSObject {
        let blurView: UIVisualEffectView
        let vibrancyView: UIVisualEffectView
        let hostingController: UIHostingController<Content>
        
        init(_ content: Content) {
            self.blurView = UIVisualEffectView()
            self.vibrancyView = UIVisualEffectView()
            self.hostingController = UIHostingController(rootView: content)
            self.hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.hostingController.view.backgroundColor = nil
            self.blurView.contentView.addSubview(vibrancyView)
            self.blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.vibrancyView.contentView.addSubview(hostingController.view)
            self.vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        func update(content: Content, blurStyle: UIBlurEffect.Style, vibrancyStyle: UIVibrancyEffectStyle?) {
            self.hostingController.rootView = content
            let blurEffect = UIBlurEffect(style: blurStyle)
            self.blurView.effect = blurEffect
            if let vibrancyStyle = vibrancyStyle {
                self.vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancyStyle)
            } else {
                self.vibrancyView.effect = nil
            }
            self.hostingController.view.setNeedsDisplay()
        }
    }
}

// MARK: - Content-less Initializer

extension ABAlbumVisualEffectBlurView where Content == EmptyView {
    init(blurStyle: UIBlurEffect.Style = .systemMaterial) {
        self.init( blurStyle: blurStyle, vibrancyStyle: nil) {
            EmptyView()
        }
    }
}

// MARK: - Previews

struct ABAlbumVisualEffectBlurView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.red, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            ABAlbumVisualEffectBlurView(blurStyle: .systemUltraThinMaterial, vibrancyStyle: .fill) {
                Text("Hello World!")
                    .frame(width: 200, height: 100)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
