//
//  Palette.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 3.12.2022.
//

import Foundation

struct Palette: Identifiable, Codable, Hashable {
    var name: String
    var emojis: String
    let id: Int
}
