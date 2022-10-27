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
                Color.green
                ForEach(document.emojies) { emoji in
                    Text(emoji.image)
                        .font(.system(size: CGFloat(emoji.size)))
                        .position(position(of: emoji, in: geometry))
                }
            }
            .onDrop(of: [.plainText], isTargeted: nil) { providers, location in
                return handleDroppedObject(providers, location, in: geometry)
            }
        }
    }
    
    private func handleDroppedObject(_ providers: [NSItemProvider], _ location: CGPoint, in geometry: GeometryProxy) -> Bool {
        if let provider = providers.first(where: { $0.canLoadObject(ofClass: NSString.self)}) {
            provider.loadObject(ofClass: NSString.self) { object, error in
                let emoji = object as? String
                DispatchQueue.main.async {
                    document.emojiArtModel.addEmoji(emoji!, at: relativePosition(of: location, in: geometry), size: Int(defaultEmojiSize))
                }
            }
            return true
        }
        return false
    }
    
    private func relativePosition(of point: CGPoint, in geometry: GeometryProxy) -> (Int, Int) {
        let center = geometry.frame(in: .local).center
        return (x: Int(point.x - center.x),
                y: Int(point.y - center.y))
    }
    
    private func position(of emoji: Emoji, in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(emoji.x),
                       y: center.y + CGFloat(emoji.y))
    }
    
    var palette: some View {
        ScrollingEmojiesView(emojies: testEmojies)
            .font(.system(size: defaultEmojiSize))
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




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
