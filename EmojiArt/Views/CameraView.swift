//
//  CameraView.swift
//  EmojiArt
//
//  Created by Mustafa Taşdemir on 18.02.2023.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    
    let handler: (UIImage?) -> Void
    
    static var isAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }
    
    func makeCoordinator() -> CameraHandler {
        CameraHandler(handler)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let camera = UIImagePickerController()
        camera.title = "Take a picture for background"
        camera.allowsEditing = true
        camera.sourceType = .camera
        camera.delegate = context.coordinator
        return camera
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // no need to update this view
    }
    

    class CameraHandler: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        let handler: (UIImage?) -> Void
        
        init(_ handler: @escaping (UIImage?) -> Void) {
            self.handler = handler
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            handler(nil)
        }
        
        typealias Keys = UIImagePickerController.InfoKey
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            handler((info[Keys.editedImage] ?? info[Keys.originalImage]) as? UIImage)
        }
    }
}
