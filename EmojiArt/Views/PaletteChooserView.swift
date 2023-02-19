//
//  PaletteChooserView.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 25.12.2022.
//

import SwiftUI

struct PaletteChooserView: View {
    @EnvironmentObject var paletteStore: PaletteStore
    let defaultEmojiSize: CGFloat
    @State private var chosenPaletteIndex: Int = 0
    @State private var showManager: Bool = false
    @State private var palette: Palette?
    
    var body: some View {
        HStack {
            paletteButton
            body(for: paletteStore.palette(at: chosenPaletteIndex))
        }
        .font(.system(size: defaultEmojiSize))
        .clipped()
        .sheet(isPresented: $showManager) {
            PaletteManager()
        }

    }
    
    func body(for paletteToShow: Palette) -> some View {
        HStack {
            Text(paletteToShow.name)
            ScrollingEmojiesView(emojies: paletteToShow.emojis)
                .background(Color.green)
        }
        .id(paletteToShow.id)
        .transition(AnyTransition.asymmetric(insertion: .offset(x: 0, y: -defaultEmojiSize), removal: .offset(x:0, y: defaultEmojiSize)))
        .popover(item: $palette) { paletteItem in
            PaletteEditorView(palette: $paletteStore.palettes[paletteItem], isPopover: true)
                .wrappedInNavigationViewToMakeDismissable(by: { palette = nil })
        }
    }
    
    var paletteButton: some View {
        Button {
            withAnimation {
                chosenPaletteIndex = (chosenPaletteIndex + 1) % paletteStore.palettesCount
            }
        } label: {
            Image(systemName: "paintpalette.fill")
        }
        .contextMenu {
            contextMenuView
        }
    }
    
    @ViewBuilder
    var contextMenuView: some View {
        AnimatedButton(title: "Manage", icon: "slider.horizontal.3") {
            showManager = true
        }
        AnimatedButton(title: "Edit", icon: "pencil") {
            palette = paletteStore.palette(at: chosenPaletteIndex)
        }
        AnimatedButton(title: "Insert", icon: "plus") {
            palette = paletteStore.insertPalette(named: "New", emojis: nil, at: chosenPaletteIndex)
        }
        
        AnimatedButton(title: "Delete", icon: "minus.circle") {
            paletteStore.removePalette(at: chosenPaletteIndex)
        }
        
        gotoMenu
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach(paletteStore.palettes) { palette in
                Button("\(palette.name)") {
                    if let index = paletteStore.palettes.indexOf(matching: palette) {
                        chosenPaletteIndex = index
                    }
                }
            }
        } label: {
                Label("Goto", systemImage: "text.insert")
            }
    }
}

struct ScrollingEmojiesView: View {
    let emojies: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojies.removeDuplication().map{String($0)}, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag {
                            NSItemProvider(object: emoji as NSString)
                        }
                }
            }
        }
    }
}

struct PaletteChooserView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooserView(defaultEmojiSize: 100)
    }
}
