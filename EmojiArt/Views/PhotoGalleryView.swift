//
//  PhotoGalleryView.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 18.02.2023.
//

import SwiftUI
import PhotosUI

struct PhotoGalleryView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    
    let handler: (UIImage?) -> Void
    
    func makeCoordinator() -> PHPickerViewControllerDelegate {
        PhotoHandler(handler)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var pickerCongif = PHPickerConfiguration()
        pickerCongif.filter = .images
        let phPicker = PHPickerViewController(configuration: pickerCongif)
        phPicker.isEditing = true
        phPicker.delegate = context.coordinator
        return phPicker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // no update for photo gallery view
    }
    
    class PhotoHandler: PHPickerViewControllerDelegate {
        let handler: (UIImage?) -> Void
        
        init(_ handler: @escaping (UIImage?) -> Void) {
            self.handler = handler
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let provider = results.first?.itemProvider,
               provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self, completionHandler: { image, error in
                    Task { @MainActor in
                        if let image = image as? UIImage, error != nil {
                            self.handler(image)
                        } else {
                            self.handler(nil)
                        }
                    }
                })
            } else {
                handler(nil)
            }
        }
    }
}
