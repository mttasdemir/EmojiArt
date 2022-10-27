//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 23.10.2022.
//

import Foundation

typealias Background = EmojiArtModel.Background
typealias Emoji = EmojiArtModel.Emoji

struct EmojiArtModel {
    let background = Background.blank
    var emojies = [Emoji]()
    
    struct Emoji: Identifiable {
        let image: String
        let x: Int
        let y: Int
        let size: Int
        let id: Int
        
        fileprivate init(image: String, x: Int, y: Int, size: Int, id: Int) {
            self.image = image
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    
    }
    
    var emojiIdentifier = 0
    mutating func addEmoji(_ image: String, at location: (x: Int, y: Int), size: Int) {
        emojiIdentifier += 1
        emojies.append(Emoji(image: image, x: location.x, y: location.y, size: size, id: emojiIdentifier))
    }
}
