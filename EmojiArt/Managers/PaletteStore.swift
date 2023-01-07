//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 3.12.2022.
//

import SwiftUI

class PaletteStore: ObservableObject {
    var name: String
    @Published var palettes = Array<Palette>() {
        didSet {
            store()
        }
    }
    
    var paletteStoreKey: String {
        "PaletteStore001" + name
    }
    
    var palettesCount: Int {
        return palettes.count
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
//            print("Loading default palettes")
            palettes = [
                Palette(name: "Animals", emojis: "🐶🦊🐻‍❄️🐨🐵🦋🦄", id: 1),
                Palette(name: "Vehicles", emojis: "🚗🚕🚌🚜🛺🚒", id: 2),
                Palette(name: "Smileys", emojis: "😀😂😛🥱🤔🤗", id: 3),
                Palette(name: "Fruits", emojis: "🍎🍎🍋🍇🍓🌽🍎🍊🍇", id: 4)
            ]
        }
//        else {
//            print("Palettes loaded from user defaults: \(palettes)")
//        }
    }
    
    // MARK: Intents
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) -> Palette {
        let uniqueId = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let safeIndex = min(max(index, 0), palettes.count - 1)
        let palette = Palette(name: name, emojis: emojis ?? "", id: uniqueId)
        palettes.insert(palette, at: safeIndex)
        return palette
    }
}




