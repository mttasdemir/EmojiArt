//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 23.10.2022.
//

import Foundation
import SwiftUI

class EmojiArtDocument: ObservableObject {

    @Published var emojiArtModel: EmojiArtModel = EmojiArtModel() {
        didSet {
            if emojiArtModel.background != oldValue.background {
                updateBackgroundImage()
            }
        }
    }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = FetchStatus.idle
    
    enum FetchStatus {
        case idle
        case fetching
    }
    
    private func updateBackgroundImage() {
        switch emojiArtModel.background {
        case .blank: break
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let data = try? Data(contentsOf: url)
                if Background.url(url) == self?.emojiArtModel.background {
                    DispatchQueue.main.async {
                        self?.backgroundImage = UIImage(data: data!)
                        self?.backgroundImageFetchStatus = .idle
                    }
                }
            }

        case .imageData(let data):
            backgroundImageFetchStatus = .fetching
            backgroundImage = UIImage(data: data)
            backgroundImageFetchStatus = .idle
        }
    }
    
    var emojies: [Emoji] {
        emojiArtModel.emojies
    }
    
    init() {
        emojiArtModel.addEmoji("🛩", at: (-300, -150), size: 200)
    }
    
    // MARK: - intents
    func addEmoji(_ emoji: String, at location: (Int, Int), size: Int) {
        emojiArtModel.addEmoji(emoji, at: location, size: size)
    }
    
    func setBackground(_ url: URL) {
        emojiArtModel.background = Background.url(url)
    }
    func setBackground(_ data: Data) {
        emojiArtModel.background = Background.imageData(data)
    }
}

