//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 23.10.2022.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var document = EmojiArtDocument()
    var paletteStore = PaletteStore(name: "EmojiPalettes")
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
                .environmentObject(paletteStore)
        }
    }
}
