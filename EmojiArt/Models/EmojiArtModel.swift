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
    var background = Background.blank
    var emojies = [Emoji]()
    
    struct Emoji: Identifiable, Hashable{
        let image: String
        var x: Int
        var y: Int
        var size: CGFloat
        let id: Int
        
        fileprivate init(image: String, x: Int, y: Int, size: CGFloat, id: Int) {
            self.image = image
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    
    }
    
    var emojiIdentifier = 0
    mutating func addEmoji(_ image: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiIdentifier += 1
        emojies.append(Emoji(image: image, x: location.x, y: location.y, size: size, id: emojiIdentifier))
    }
}
