
import SwiftUI
import Combine

@available(iOS 14, *)

/// This is a view for download image from url,
public struct AsyncImageView: View {
    @ObservedObject private var downloader: ImageDownloader
    
    private var image: some View {
        Group {
            if downloader.image != nil {
                Image(uiImage: downloader.image!).resizable().scaledToFit()
            } else {
                ProgressView()
            }
        }
    }
    
    public init(url: URL) {
        downloader = ImageDownloader(url: url)
    }
    public var body: some View {
        image.onAppear {
            downloader.start()
        }
    }
}

class ImageDownloader: ObservableObject {
    @Published private(set) var image: UIImage?
    private let url: URL
    private var cancellable: AnyCancellable?
    
    init(url: URL) {
        self.url = url
    }
    
    func start() {
        cancellable = URLSession(configuration: .default)
            .dataTaskPublisher(for: url)
            .map {UIImage(data: $0.data)}
            .replaceError(with: UIImage(systemName: "xmark.circle"))
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    func stop()  {
        cancellable?.cancel()
    }
    
    deinit {
        stop()
    }
}
