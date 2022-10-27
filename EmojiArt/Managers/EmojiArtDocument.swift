//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 23.10.2022.
//

import Foundation

class EmojiArtDocument: ObservableObject {

    @Published var emojiArtModel: EmojiArtModel = EmojiArtModel()
    
    var emojies: [Emoji] {
        emojiArtModel.emojies
    }
    
    init() {
        emojiArtModel.addEmoji("😀", at: (200, -100), size: 80)
        emojiArtModel.addEmoji("😂", at: (100, 100), size: 40)
        emojiArtModel.addEmoji("🛩", at: (-300, -150), size: 200)
    }
}

