//
//  ContentView.swift
//  Instasquare
//
//  Created by iakalann on 22/02/2023.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var image: UIImage?
    @State private var isPresentingImagePicker = false
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                Text("Select an image")
            }
            
            Button("Select Image") {
                isPresentingImagePicker = true
            }
            
            Button("Save Image") {
                if let image = image {
                    saveImageToPhotos(image: image)
                }
            }
        }
        .sheet(isPresented: $isPresentingImagePicker) {
            ImagePickerView(image: $image)
        }
    }
    
    func saveImageToPhotos(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        @State var parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let image = image as? UIImage {
                        let squareImage = self?.addWhiteSpace(to: image)
                        self?.parent.image = squareImage
                    }
                }
            }
        }
        
        func addWhiteSpace(to image: UIImage) -> UIImage {
            let imageSize = image.size
            let maxWidth = max(imageSize.width, imageSize.height)
            let canvasSize = CGSize(width: maxWidth, height: maxWidth)
            let renderer = UIGraphicsImageRenderer(size: canvasSize)
            let whiteRect = CGRect(origin: .zero, size: imageSize)
            let whiteImage = renderer.image { context in
                UIColor.white.setFill()
                context.fill(whiteRect)
                image.draw(in: whiteRect)
            }
            return whiteImage
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
