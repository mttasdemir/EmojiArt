//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 3.01.2023.
//

import SwiftUI

struct PaletteManager: View {
    @EnvironmentObject var paletteStore: PaletteStore
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    @State private var isEditing: EditMode = .inactive
    @State private var cs: ColorScheme = .dark

    var body: some View {
        NavigationStack {
            List {
                ForEach(paletteStore.palettes) { palette in
                    NavigationLink {
                        PaletteEditorView(palette: $paletteStore.palettes[palette], isPopover: false)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(palette.name).font(colorScheme == .dark ? .largeTitle : .title2)
                            Text(palette.emojis).font(.largeTitle)
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            paletteStore.removePalette(at: paletteStore.palettes.indexOf(matching: palette)!)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                .onMove { index, offset in
                    paletteStore.palettes.move(fromOffsets: index, toOffset: offset)
                }
            }
            .gesture(isEditing == .active ? TapGesture() : nil)
            .environment(\.editMode, $isEditing)
            .environment(\.colorScheme, cs)
            .navigationTitle(Text("Palette Manager"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        if isPresented {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing == .active ? "Done" : "Edit") {
                        isEditing = isEditing == .active ? .inactive : .active
                    }
                }
            }
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .preferredColorScheme(.light)
            .previewDevice("iPhone 14")
            .environmentObject(PaletteStore(name: "Preview"))
        PaletteManager()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 14")
            .environmentObject(PaletteStore(name: "Preview"))

    }
}
