//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 23.10.2022.
//

import Foundation

typealias Background = EmojiArtModel.Background
typealias Emoji = EmojiArtModel.Emoji

struct EmojiArtModel: Codable {
    var background = Background.blank
    var emojies = [Emoji]()
    
    struct Emoji: Identifiable, Hashable, Codable {
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
    
    init() {}
    
    var emojiIdentifier = 0
    mutating func addEmoji(_ image: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiIdentifier += 1
        emojies.append(Emoji(image: image, x: location.x, y: location.y, size: size, id: emojiIdentifier))
    }
    
    // MARK: json API
    func json() throws -> Data {
        try JSONEncoder().encode(self)
    }
    
    init(from jsonData: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: jsonData)
    }
    
    init(url: URL) throws {
        let jsonData = try Data(contentsOf: url)
        self = try EmojiArtModel(from: jsonData)
    }
    
}
