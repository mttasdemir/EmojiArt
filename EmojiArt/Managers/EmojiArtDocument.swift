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
            if autoSaveTimer == nil {
                scheduledAutoSave()
            }
            if emojiArtModel.background != oldValue.background {
                updateBackgroundImage()
            }
        }
    }
    
    private var autoSaveTimer: Timer?
    private func scheduledAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: AutoSave.autosaveInterval, repeats: false) { _ in
            self.autosave()
            self.autoSaveTimer = nil
        }
    }
    
    private struct AutoSave {
        static let autosaveInterval = 10.0
        static let autosaveFileName = "EmojiArt.json"
        
        static var autoSaveUrl: URL? {
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                return url.appending(path: autosaveFileName)
            } else {
                return nil
            }
        }
    }
    
    private func autosave() {
        if let url = AutoSave.autoSaveUrl {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArtModel.json()
            try data.write(to: url)
            print("\(thisFunction) Saved successfully")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) couldn't encode EmojiArtModel as JSON because \(encodingError.localizedDescription)")
        } catch {
            print("\(thisFunction) has error: \(error)")
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
            Task {
                await downloadBackgroundImageFromUrl(url)
            }

//            backgroundImageFetchStatus = .fetching
//            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//                let data = try? Data(contentsOf: url)
//                if Background.url(url) == self?.emojiArtModel.background {
//                    DispatchQueue.main.async {
//                        self?.backgroundImage = UIImage(data: data!)
//                        self?.backgroundImageFetchStatus = .idle
//                    }
//                }
//            }

        case .imageData(let data):
            backgroundImageFetchStatus = .fetching
            backgroundImage = UIImage(data: data)
            backgroundImageFetchStatus = .idle
        }
    }
    
    private func downloadBackgroundImageFromUrl(_ url: URL) async {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                DispatchQueue.main.async { [weak self] in
                    if Background.url(url) == self?.emojiArtModel.background {
                        self?.backgroundImage = UIImage(data: data)
                        self?.backgroundImageFetchStatus = .idle
                    }
                }
            }
        }
        catch { }
    }
    
    var emojies: [Emoji] {
        emojiArtModel.emojies
    }
    
    init() {
        if let url = AutoSave.autoSaveUrl, let emojiArt = try? EmojiArtModel(url: url) {
            self.emojiArtModel = emojiArt
        } else {
            emojiArtModel.addEmoji("🛩", at: (-300, -150), size: 200)
        }
    }
    
    // MARK: - intents
    func addEmoji(_ emoji: String, at location: (Int, Int), size: CGFloat) {
        emojiArtModel.addEmoji(emoji, at: location, size: size)
    }
    
    func setBackground(_ url: URL) {
        emojiArtModel.background = Background.url(url)
    }
    func setBackground(_ data: Data) {
        emojiArtModel.background = Background.imageData(data)
    }
    func updateSize(of emoji: Emoji, by factor: CGFloat) {
        if let index = emojiArtModel.emojies.index(matching: emoji) {
            emojiArtModel.emojies[index].size *= factor
        }
    }
    func updatePosition(of emoji: Emoji, by offset: CGSize) {
        if let index = emojiArtModel.emojies.index(matching: emoji) {
            emojiArtModel.emojies[index].x += Int(offset.width)
            emojiArtModel.emojies[index].y += Int(offset.height)
        }
    }
}

