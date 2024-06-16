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

  @State private var selectedImage: Image?

  @State private var isChooseAttachmentTypePickerShowing = false
  @State private var isAttachmentPickerShowing = false

  private func showChooseAttachmentTypePicker() {
    isChooseAttachmentTypePickerShowing.toggle()
  }

  private func showAttachmentPicker() {
    isAttachmentPickerShowing.toggle()
  }

  private func submit() {
    if let submitHandler {
      submitHandler()
    }
  }

  private func submitNaming() {
    if let submitNamingHandler {
      submitNamingHandler()
    }
  }

  public init(text: Binding<String>,
              selection: Binding<[PhotosPickerItem]>,
              submitNamingHandler: @escaping () -> Void) {
    _text = text
    _selection = selection
    self.submitNamingHandler = submitNamingHandler
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
    }
    .photosPicker(isPresented: $isAttachmentPickerShowing, selection: $selection, maxSelectionCount: 1)
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
