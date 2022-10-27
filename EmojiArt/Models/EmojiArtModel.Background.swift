//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 23.10.2022.
//

import Foundation

extension EmojiArtModel {
    
    enum Background {
        case blank
        case url(URL)
        case imageData(Data)
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
    }
}