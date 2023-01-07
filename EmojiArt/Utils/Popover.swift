//
//  Popover.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 5.01.2023.
//

import Foundation
import SwiftUI

struct Popover: ViewModifier {
    let isPopover: Bool
    var size: CGSize?
    
    func body(content: Content) -> some View {
        if isPopover {
            content
                .frame(width: size?.width, height: size?.height)
        } else {
            content
        }
    }
    
}

extension View {
    func asPopover(_ isPopover: Bool, size: CGSize? = nil) -> some View {
        modifier(Popover(isPopover: isPopover, size: size))
    }
}
