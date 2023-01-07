//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 23.10.2022.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    let defaultEmojiSize: CGFloat = 50
    @State private var selectedEmojis: Set<Emoji> = []
    
    @State private var isDownloadFailed: Bool = false
    @State private var downloadUrl: URL?
    
    var body: some View {
        VStack {
            documentBody
            PaletteChooserView(defaultEmojiSize: defaultEmojiSize)
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Color.white
                UIImageView(image: document.backgroundImage)
                    .scaleEffect(magnificationFactor)
                    .position(convertFromRelativeCoordinate(from: (0, 0), in: geometry))
                    .gesture(tapToScale(in: geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(4.0)
                } else {
                    ForEach(document.emojies) { emoji in
                        Text(emoji.image)
                            .font(.system(size: CGFloat(emoji.size)))
                            .scaleEffect(isEmojiSelected(emoji) ? emojiMagnificationFactor : magnificationFactor)
                            .onTapGesture(count: 1) {
                                selectedEmojis.toggleMatching(of: emoji)
                            }
                            .overlay {
                                if isEmojiSelected(emoji) {
                                    Rectangle()
                                    .strokeBorder(lineWidth: 2)
                                    .frame(width: CGFloat(emoji.size)*magnificationFactor, height: CGFloat(emoji.size)*magnificationFactor, alignment: .center)
                                }
                            }
                            .position(position(of: emoji, in: geometry))
                    }
                }
            }
            .clipped()
            .gesture(drag().simultaneously(with: zoomByPinching()))
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return handleDroppedObject(providers, location, in: geometry)
            }
            .onChange(of: document.backgroundImageFetchStatus) { status in
                switch status {
                case .fail(let url):
                        isDownloadFailed = true
                        downloadUrl = url
                default: break
                }
            }
            .alert("Download Error", isPresented: $isDownloadFailed, presenting: downloadUrl) { _ in
                Button("OK") {
                    isDownloadFailed = false
                }
            } message: {url in
                Text("Error while downloading from \(url)")
            }
        }
    }
    
    private func isEmojiSelected(_ emoji: Emoji) -> Bool {
        selectedEmojis.contains(where: {$0.id == emoji.id}) 
    }
    
    private func zoomOnlyEmoji() -> Bool {
        !selectedEmojis.isEmpty
    }
    
    // MARK: - Gestures
    
    @State private var scalingFactor: CGFloat = 1
    @State private var emojiScalingFactor: CGFloat = 1
    private func tapToScale(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.linear(duration: 1.0)) {
                    scalingFactor = scalingFactor == 1 ? zoomToScale(document.backgroundImage, size) : 1
                    updatingOffsetSize = CGSize.zero
                }
            }
    }
    
    @GestureState var magnification: CGFloat = 1.0
    private func zoomByPinching() -> some Gesture {
        MagnificationGesture()
            .updating($magnification) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { value in
                if !zoomOnlyEmoji() {
                    scalingFactor *= value
                } else {
                    updateSelectedEmojisSize(by: emojiScalingFactor * value)
                }
            }
    }
    
    private var magnificationFactor: CGFloat {
        if zoomOnlyEmoji() {
            return scalingFactor
        } else {
            return scalingFactor * magnification
        }
    }
    private var emojiMagnificationFactor: CGFloat {
        emojiScalingFactor * scalingFactor * magnification
    }
    
    @State private var updatingOffsetSize = CGSize.zero
    @State private var updatingEmojiOffsetSize = CGSize.zero
    @GestureState var draggedSize: CGSize = CGSize.zero
    private func drag() -> some Gesture {
        DragGesture()
            .updating($draggedSize) { currentState, gestureState, _ in
                gestureState = currentState.translation
            }
            .onEnded { value in
                if !zoomOnlyEmoji() {
                    updatingOffsetSize += value.translation
                } else {
                    updateSelectedEmojiPosition(by: updatingEmojiOffsetSize + value.translation)
                }
            }
    }
    
    private var offsetSize: CGSize {
        if zoomOnlyEmoji() {
            return updatingOffsetSize
        } else {
            return updatingOffsetSize + draggedSize
        }
    }
    
    private var emojiOffsetSize: CGSize {
        updatingEmojiOffsetSize + draggedSize
    }
    
    //MARK: - Functions
    
    private func updateSelectedEmojiPosition(by offset: CGSize) {
        selectedEmojis.forEach {
            document.updatePosition(of: $0, by: offset)
        }
        updatingEmojiOffsetSize = CGSize.zero
    }
    
    private func updateSelectedEmojisSize(by factor: CGFloat) {
        selectedEmojis.forEach {
            document.updateSize(of: $0, by: factor)
        }
        emojiScalingFactor = 1
    }

    private func zoomToScale(_ image: UIImage?, _ size: CGSize) -> CGFloat {
        if let image {
            let zoomHorizantol = size.width / image.size.width
            let zoomVertical = size.height / image.size.height
            return min(zoomHorizantol, zoomVertical)
        }
        return 1.0;
    }
    
    private func handleDroppedObject(_ providers: [NSItemProvider], _ location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var loaded = false
        
        loadObject(typeof: NSURL.self, providers: providers) { url in
            if let url = url as? URL {
                loaded = true
                document.setBackground(url)
                scalingFactor = 1
            }
        }
        
        if !loaded {
            loadObject(typeof: UIImage.self, providers: providers) { image in
                if let data = image?.jpegData(compressionQuality: 1.0){
                    loaded = true
                    document.setBackground(data)
                    scalingFactor = 1
                }
            }
        }

        if !loaded {
            loadObject(typeof: NSString.self, providers: providers) { emoji in
                if let emoji = emoji as? String {
                    loaded = true
                    document.addEmoji(emoji, at: relativePosition(of: location, in: geometry), size: defaultEmojiSize)
                }
            }
        }
        
        return loaded
    }
    
    private func loadObject<T: NSItemProviderReading>(typeof: T.Type, providers: [NSItemProvider], loadHandler: @escaping (T?) -> Void) {
        var obj: T?
        if let provider = providers.first(where: {$0.canLoadObject(ofClass: typeof)}) {
            provider.loadObject(ofClass: typeof) { object, error in
                obj = object as? T
                DispatchQueue.main.async {
                    loadHandler(obj)
                }
            }
        }
    }
    
    private func relativePosition(of point: CGPoint, in geometry: GeometryProxy) -> (Int, Int) {
        let center = geometry.frame(in: .local).center
        return (x: Int((point.x - offsetSize.width - center.x) / magnificationFactor),
                y: Int((point.y - offsetSize.height - center.y) / magnificationFactor))
    }
    
    private func position(of emoji: Emoji, in geometry: GeometryProxy) -> CGPoint {
        if isEmojiSelected(emoji) {
            return convertFromRelativeCoordinate(from: (emoji.x + Int(emojiOffsetSize.width), emoji.y + Int(emojiOffsetSize.height)), in: geometry)
        } else {
            return convertFromRelativeCoordinate(from: (emoji.x, emoji.y), in: geometry)
        }
    }
    
    private func convertFromRelativeCoordinate(from coordinate: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(coordinate.x)*magnificationFactor + offsetSize.width,
                       y: center.y + CGFloat(coordinate.y)*magnificationFactor + offsetSize.height)
    }
    
}

struct UIImageView: View {
    let image: UIImage?
    
    var body: some View {
        if let image {
            Image(uiImage: image)
        } else {
            EmptyView()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
