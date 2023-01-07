//
//  PaletteEditorView.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 28.12.2022.
//

import SwiftUI

struct PaletteEditorView: View {
    @Binding var palette: Palette
    @State private var addedEmojis: String = ""
    let isPopover: Bool
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Emoji palette name", text: $palette.name)
                    .autocorrectionDisabled(true)
            }
            
            Section("Add Emojis") {
                TextField("", text: $addedEmojis)
                    .onChange(of: addedEmojis) { emoji in
                        addEmojis(emoji)
                    }
            }
            
            emojiRemoveSection
                .font(.largeTitle)
            
        }
        .font(.largeTitle)
        .asPopover(isPopover, size: CGSize(width: 400, height: 500))
        .navigationTitle(Text("Managing \(palette.name)"))
    }
    
    var emojiRemoveSection: some View {
        Section("Remove Emojis") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.map({ $0 }), id: \.self) { chr in
                    Text(String(chr))
                        .onTapGesture {
                            palette.emojis.removeAll { $0 == chr }
                        }
                }
            }
            .font(.system(size: 40))
        }
    }
    
    private func addEmojis(_ emojis: String) {
        withAnimation {
            palette.emojis = (emojis + palette.emojis)
                .filter { $0.isEmoji }
                .removeDuplication()
        }
    }
    
}

struct PaletteEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditorView(palette: .constant(PaletteStore(name: "Preview").palette(at: 2)), isPopover: false)
            .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/400.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/500.0/*@END_MENU_TOKEN@*/))
        PaletteEditorView(palette: .constant(PaletteStore(name: "Preview").palette(at: 3)), isPopover: false)
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/400.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/500.0/*@END_MENU_TOKEN@*/))
    }
}
