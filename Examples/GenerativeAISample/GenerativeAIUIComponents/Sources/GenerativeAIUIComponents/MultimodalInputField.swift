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
              submitNamingHandler: @escaping () -> Void,
              submitPastLifeHandler: @escaping () -> Void) {
    _text = text
    _selection = selection
    self.submitNamingHandler = submitNamingHandler
    self.submitPastLifeHandler = submitPastLifeHandler
  }

  public var body: some View {
    VStack(alignment: .leading) {
      if let selectedImage {
        selectedImage
          .resizable()
          .scaledToFit() // 使用scaledToFit确保图片按比例缩放
          .frame(width: 150, height: 150) // 增大显示大小
          .cornerRadius(8)
          .padding(.bottom, 8) // 添加底部填充
          .frame(maxWidth: .infinity, alignment: .center) // 水平置中
      }
      HStack(alignment: .top) {
        Button(action: showChooseAttachmentTypePicker) {
          Image(systemName: "plus")
        }
        .padding(.top, 10)

        VStack(alignment: .leading) {
          Text("請新增照片")
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading) // 水平填滿畫面
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
          Text("占卜測算")
            .frame(maxWidth: .infinity, alignment: .leading) // 向左靠齊
            .frame(height: 30)
        }
        .padding(.horizontal, 12)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.blue, lineWidth: 2)
        )
        .padding(.top, 8)
          
        Button(action: submitPastLife) {
          Text("前世今生")
            .frame(maxWidth: .infinity, alignment: .leading) // 向左靠齊
            .frame(height: 30)
        }
        .padding(.horizontal, 12)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.blue, lineWidth: 2)
        )
        .padding(.top, 8)

        Button(action: submitNaming) {
          Text("改名易姓")
            .frame(maxWidth: .infinity, alignment: .leading) // 向左靠齊
            .frame(height: 30)
        }
        .padding(.horizontal, 12)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.blue, lineWidth: 2)
        )
        .padding(.top, 8)
      }
    }
    .padding(.horizontal)
    .confirmationDialog(
      "Select an image",
      isPresented: $isChooseAttachmentTypePickerShowing,
      titleVisibility: .hidden
    ) {
      Button(action: showAttachmentPicker) {
        Text("Photo & Video Library")
      }
      Button(action: checkCameraPermission) {
        Text("Camera")
      }
    }
    .photosPicker(isPresented: $isAttachmentPickerShowing, selection: $selection, maxSelectionCount: 1)
    .fullScreenCover(isPresented: $isCameraPickerShowing) {
      ImagePicker(selectedImage: $selectedImage)
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
      Alert(title: Text("Camera Permission"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
    }
  }
}

struct ImagePicker: UIViewControllerRepresentable {
  @Binding var selectedImage: Image?

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
        parent.selectedImage = Image(uiImage: uiImage)
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
