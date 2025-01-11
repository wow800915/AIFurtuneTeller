// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import PhotosUI
import SwiftUI
import UIKit
import AVFoundation

struct MultimodalInputFieldSubmitHandler: EnvironmentKey {
    static var defaultValue: (() -> Void)?
}

extension EnvironmentValues {
    var submitHandler: (() -> Void)? {
        get { self[MultimodalInputFieldSubmitHandler.self] }
        set { self[MultimodalInputFieldSubmitHandler.self] = newValue }
    }
}

public extension View {
    func onSubmit(submitHandler: @escaping () -> Void) -> some View {
        environment(\.submitHandler, submitHandler)
    }
}

public struct MultimodalInputField: View {
    @Binding public var text: String
    @Binding public var selection: [PhotosPickerItem]
    
    var onImagesSelected: ([UIImage]) -> Void  // 閉包來傳遞圖片
    
    @Environment(\.submitHandler) var submitHandler
    var submitNamingHandler: (() -> Void)?
    var submitPastLifeHandler: (() -> Void)?
    
    @State private var selectedImage: Image?
    
    @State private var isChooseAttachmentTypePickerShowing = false
    @State private var isAttachmentPickerShowing = false
    @State private var isCameraPickerShowing = false
    @State private var isAlertPresented = false
    @State private var alertMessage = ""
    
    private func showChooseAttachmentTypePicker() {
        isChooseAttachmentTypePickerShowing.toggle()
    }
    
    private func showAttachmentPicker() {
        isAttachmentPickerShowing.toggle()
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            showCameraPicker()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showCameraPicker()
                    } else {
                        alertMessage = "Camera access is required to take photos."
                        isAlertPresented = true
                    }
                }
            }
        case .denied, .restricted:
            alertMessage = "Camera access is denied or restricted. Please enable it in settings."
            isAlertPresented = true
        @unknown default:
            break
        }
    }
    
    private func showCameraPicker() {
        isCameraPickerShowing.toggle()
    }
    
    private func submit() {
        if let submitHandler {
            submitHandler()
        }
    }
    
    private func submitPastLife() {
        if let submitPastLifeHandler {
            submitPastLifeHandler()
        }
    }
    
    private func submitNaming() {
        if let submitNamingHandler {
            submitNamingHandler()
        }
    }
    
    public init(text: Binding<String>,
                selection: Binding<[PhotosPickerItem]>,
                onImagesSelected: @escaping ([UIImage]) -> Void,
                submitNamingHandler: @escaping () -> Void,
                submitPastLifeHandler: @escaping () -> Void) {
        _text = text
        _selection = selection
        self.onImagesSelected = onImagesSelected
        self.submitNamingHandler = submitNamingHandler
        self.submitPastLifeHandler = submitPastLifeHandler
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let selectedImage {
                selectedImage
                    .resizable()
                    .scaledToFit() // 確保圖片按比例縮放
                    .frame(width: 150, height: 150)
                    .cornerRadius(8)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .center) // 水平置中
            }
            HStack(alignment: .top) {
                Button(action: showChooseAttachmentTypePicker) {
                    Image(systemName: "plus")
                        .background(Circle().fill(Color.blue.opacity(0.1)))
                }
                .padding(.top, 10)
                
                VStack(alignment: .leading) {
                    Text("上傳您的照片，透過我們的 AI 技術分析，獲取個性化的洞察與建議")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 8,
                        style: .continuous
                    )
                    .stroke(Color(UIColor.systemFill), lineWidth: 1)
                }
            }
            
            HStack {
                Button(action: submit) {
                    Text("AI 洞察")
                        .frame(maxWidth: .infinity, alignment: .center) // 改為置中對齊
                        .frame(height: 40)
                        .font(.body) // 調整字體大小
                }
                .padding(.horizontal, 4)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.2)))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .padding(.top, 8)
                
                Button(action: submitPastLife) {
                    Text("探索記憶")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 40)
                        .font(.body)
                }
                .padding(.horizontal, 4)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.2)))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .padding(.top, 8)
                
                Button(action: submitNaming) {
                    Text("靈韻起名")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 40)
                        .font(.body)
                }
                .padding(.horizontal, 4)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.2)))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .padding(.top, 8)
            }
        }
        .padding(.horizontal)
        .confirmationDialog(
            "選擇上傳方式",
            isPresented: $isChooseAttachmentTypePickerShowing,
            titleVisibility: .visible // 顯示標題
        ) {
            Button(action: showAttachmentPicker) {
                Text("從相簿選擇")
            }
            Button(action: checkCameraPermission) {
                Text("使用相機")
            }
        }
        .photosPicker(isPresented: $isAttachmentPickerShowing, selection: $selection, maxSelectionCount: 1)
        .fullScreenCover(isPresented: $isCameraPickerShowing) {
            ImagePicker(selectedImage: $selectedImage){ image in
                onImagesSelected([image])
            }
            .edgesIgnoringSafeArea(.all) // 确保全屏
        }
        .onChange(of: selection) { _ in
            Task {
                selectedImage = nil
                
                if let item = selection.first {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            let image = Image(uiImage: uiImage)
                            selectedImage = image
                        }
                    }
                }
            }
        }
        .alert(isPresented: $isAlertPresented) {
            Alert(title: Text("需要相機權限"), message: Text(alertMessage), dismissButton: .default(Text("確定")))
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: Image?
    var onImagePicked: (UIImage) -> Void  // 使用閉包來回傳圖片
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.modalPresentationStyle = .fullScreen // Ensure fullscreen presentation
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = Image(uiImage: uiImage)//位置A
                parent.onImagePicked(uiImage)  // 將圖片回傳到閉包
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    struct Wrapper: View {
        @State var userInput: String = ""
        @State var selectedItems = [PhotosPickerItem]()
        
        @State private var selectedImage: Image?
        
        var body: some View {
            MultimodalInputField(
                text: $userInput,
                selection: $selectedItems,
                onImagesSelected: { images in
                },
                submitNamingHandler: {
                    print("Submit Naming pressed")
                },
                submitPastLifeHandler: {
                    print("Submit Past Life pressed")
                }
            )
            .onSubmit {
                print("Submit pressed")
            }
            .onChange(of: selectedItems) { _ in
                Task {
                    selectedImage = nil
                    
                    if let item = selectedItems.first {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                let image = Image(uiImage: uiImage)
                                selectedImage = image
                            }
                        }
                    }
                }
            }
            
            if let selectedImage {
                selectedImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: .infinity)
                    .cornerRadius(8)
            }
        }
    }
    
    return Wrapper()
}
