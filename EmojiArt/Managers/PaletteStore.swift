//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 3.12.2022.
//

import SwiftUI

class PaletteStore: ObservableObject {
    var name: String
    private var palettes = Array<Palette>() {
        didSet {
            store()
        }
    }
    
    var paletteStoreKey: String {
        "PaletteStore" + name
    }
    
    private func store() {
        if let palettesAsJson = try? JSONEncoder().encode(palettes) {
            UserDefaults.standard.set(palettesAsJson, forKey: paletteStoreKey)
        }
    }
    
    private func load() {
        if let palettesAsData = UserDefaults.standard.data(forKey: paletteStoreKey),
           let palettes = try? JSONDecoder().decode([Palette].self, from: palettesAsData) {
               self.palettes = palettes
        }
    }
    
    init(name: String) {
        self.name = name
        self.load()
        if palettes.isEmpty {
            print("Loading default palettes")
            palettes = [
                Palette(name: "Animals", emojis: "🐶🦊🐻‍❄️🐨🐵🦋🦄", id: 1),
                Palette(name: "Vehicles", emojis: "🚗🚕🚌🚜🛺🚒", id: 2),
                Palette(name: "Smileys", emojis: "😀😂😛🥱🤔🤗", id: 3),
                Palette(name: "Fruits", emojis: "🍎🍋🍓🌽🍊🍇", id: 4)
            ]
        } else {
            print("Palettes loaded from user defaults: \(palettes)")
        }
    }
    
    // MARK: Intents

}
