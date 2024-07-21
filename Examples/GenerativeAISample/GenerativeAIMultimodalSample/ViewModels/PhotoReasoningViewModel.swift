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

import Foundation
import GoogleGenerativeAI
import OSLog
import PhotosUI
import SwiftUI

@MainActor
class PhotoReasoningViewModel: ObservableObject {
  // Maximum value for the larger of the two image dimensions (height and width) in pixels. This is
  // being used to reduce the image size in bytes.
  private static let largestImageDimension = 768.0

  private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "generative-ai")

  @Published
  var userInput: String = ""

  @Published
  var selectedItems = [PhotosPickerItem]()

  @Published
  var outputText: String? = nil

  @Published
  var errorMessage: String?

  @Published
  var inProgress = false

  private var model: GenerativeModel?

  init() {
    model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: APIKey.default)
  }

  func reason() async {
    await generateOutput(prompt: "中文回答,幫我算此人命相,並用幽默誇張的方法回覆,如果不知道怎麼算就亂掰即可,如果不是人像也就假裝有個人亂掰即可,但回答的時候不要透露出,問題有打亂掰跟把幽默誇張")
  }

  func name() async {
    await generateOutput(prompt: "中文回答,幫我給此人一個命名,並用幽默誇張的方法回覆,如果不知道怎麼命名就亂掰即可,如果不是人像也就假裝有個人亂掰即可,但回答的時候不要透露出,問題有打亂掰跟把幽默誇張")
  }
    
  func pastLife() async {
    await generateOutput(prompt: "中文回答,幫我給此人推測他上輩子是什麼,如宮裡的宮女還是路邊上的小狗之類的....,並用幽默誇張的方法回覆,如果不知道怎麼命名就亂掰即可,如果不是人像也就假裝有個人亂掰即可,但回答的時候不要透露出,問題有打亂掰跟把幽默誇張")
  }

  private func generateOutput(prompt: String) async {
    defer {
      inProgress = false
    }
    guard let model else {
      return
    }

    do {
      inProgress = true
      errorMessage = nil
      outputText = ""

      var images = [any ThrowingPartsRepresentable]()
      for item in selectedItems {
        if let data = try? await item.loadTransferable(type: Data.self) {
          guard let image = UIImage(data: data) else {
            logger.error("Failed to parse data as an image, skipping.")
            continue
          }
          if image.size.fits(largestDimension: PhotoReasoningViewModel.largestImageDimension) {
            images.append(image)
          } else {
            guard let resizedImage = image
              .preparingThumbnail(of: image.size
                .aspectFit(largestDimension: PhotoReasoningViewModel.largestImageDimension)) else {
              logger.error("Failed to resize image: \(image)")
              continue
            }

            images.append(resizedImage)
          }
        }
      }

      let outputContentStream = model.generateContentStream(prompt, images)

      // stream response
      for try await outputContent in outputContentStream {
        guard let line = outputContent.text else {
          return
        }

        outputText = (outputText ?? "") + line
      }
    } catch {
      logger.error("\(error.localizedDescription)")
      errorMessage = error.localizedDescription
    }
  }
}

private extension CGSize {
  func fits(largestDimension length: CGFloat) -> Bool {
    return width <= length && height <= length
  }

  func aspectFit(largestDimension length: CGFloat) -> CGSize {
    let aspectRatio = width / height
    if width > height {
      let width = min(self.width, length)
      return CGSize(width: width, height: round(width / aspectRatio))
    } else {
      let height = min(self.height, length)
      return CGSize(width: round(height * aspectRatio), height: height)
    }
  }
}
