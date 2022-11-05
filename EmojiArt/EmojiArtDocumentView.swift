//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 23.10.2022.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    let defaultEmojiSize: CGFloat = 100
    
    var body: some View {
        VStack {
            documentBody
            palette
        }
        .padding()
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
                            .scaleEffect(magnificationFactor)
                            .position(position(of: emoji, in: geometry))
                    }
                }
            }
            .clipped()
            .gesture(drag().simultaneously(with: zoomByPinching()))
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return handleDroppedObject(providers, location, in: geometry)
            }
        }
    }
    
    // MARK: - Gestures
    @State var scalingFactor: CGFloat = 1
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
        MagnificationGesture(minimumScaleDelta: 0.1)
            .updating($magnification) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { value in
                scalingFactor *= value
            }
    }
    
    private var magnificationFactor: CGFloat {
        scalingFactor * magnification
    }
    
    @State private var updatingOffsetSize = CGSize.zero
    @GestureState var draggedSize: CGSize = CGSize.zero
    private func drag() -> some Gesture {
        DragGesture()
            .updating($draggedSize) { currentState, gestureState, _ in
                gestureState = currentState.translation
            }
            .onEnded { value in
                updatingOffsetSize += value.translation
            }
    }
    
    private var offsetSize: CGSize {
        updatingOffsetSize + draggedSize
    }
    //MARK: - Functions
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
                    document.addEmoji(emoji, at: relativePosition(of: location, in: geometry), size: Int(defaultEmojiSize))
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
        return (x: Int((point.x - offsetSize.width - center.x) / scalingFactor),
                y: Int((point.y - offsetSize.height - center.y) / scalingFactor))
    }
    
    private func position(of emoji: Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromRelativeCoordinate(from: (emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromRelativeCoordinate(from coordinate: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(coordinate.x)*magnificationFactor + offsetSize.width,
                       y: center.y + CGFloat(coordinate.y)*magnificationFactor + offsetSize.height)
    }
    
    var palette: some View {
        ScrollingEmojiesView(emojies: testEmojies)
            .font(.system(size: defaultEmojiSize))
            .background(Color.green)
    }
    
    let testEmojies = "😀😛🫡🤫🤔🐶🦄🐏🦃🦚🍓🍅🍺🚗🚕🚙🚌🚎🏎🚓🚑🚒🚐🛻🚚🚛🚜🛵🏍🛺🚔🚖🚠🚟✈️🛫🛩🛶🚁"
    
}

struct ScrollingEmojiesView: View {
    let emojies: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojies.map{String($0)}, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag {
                            NSItemProvider(object: emoji as NSString)
                        }
                }
            }
        }
    }
}



struct UIImageView: View {
    let image: UIImage?
    
    var body: some View {
        if let image {
            Image(uiImage: image)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
