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
    
    @Published var selectedItems = [PhotosPickerItem]() {
        didSet {
            Task {
                await loadImages()
            }
        }
    }
    
    @Published var imageUI: [UIImage] = []
    
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
    
    func loadImages() async {
        var uiImages = [UIImage]()
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                uiImages.append(image)
            } else {
                logger.error("Failed to load image from selected item.")
            }
        }
        imageUI = uiImages
    }
    
    func reason() async {
        await generateOutput(prompt: "請根據這張照片中的人，專注於具體的外貌細節，如髮型、膚質、眼神或微笑，生成一段充滿正能量的誇讚語句，同時也可以帶入未來的美好可能性。例如，可以提到他可能在職場上有所成就，或是擁有幸福的家庭。語氣需溫暖且真誠，讓人感到愉快和自信。請避免過於籠統，注重具體細節，例如：「你的笑容像陽光一樣溫暖，未來你一定會成為一個帶給大家正能量的領導者。」或「你的眼神充滿希望，讓人相信你未來會擁有無限的可能性！」")
    }

    func name() async {
        await generateOutput(prompt: "繁體中文回答，請根據這張照片中的人，提供幾個提升正能量的建議。請根據照片特徵，推薦適合的活動或興趣發展方向，例如爬山、戶外運動、學習一項新技能等。語氣需溫暖鼓舞，並讓建議充滿實用性。例如：「你的陽光笑容非常適合戶外活動，不妨試試去爬山或曬曬太陽，讓自己更放鬆！」或「你的眼神透露著藝術氣質，可以試著學畫畫或拍攝自然風景，展現你的創意")
    }

    func pastLife() async {
        await generateOutput(prompt: "繁體中文回答，請根據這張照片，生成一段與照片中人相關的幽默笑話。笑話可以稍帶輕鬆的黃色幽默，但必須溫和且不冒犯，讓人開心一笑。語氣需親切、輕鬆且貼心，並帶有在地化的幽默感。笑話可以更誇張、更搞笑一些。例如，如果照片中有可愛的帽子，可以說：「這頂帽子一看就是仙女專用的，感覺下一秒就要召喚彩虹了！」或「你的微笑這麼燦爛，看起來像剛簽下五棟房子！」請確保笑話有趣但不冒犯")
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
            for image in imageUI {
                let processedImage: UIImage
                if image.size.fits(largestDimension: PhotoReasoningViewModel.largestImageDimension) {
                    processedImage = image
                } else if let resizedImage = image.preparingThumbnail(of: image.size.aspectFit(largestDimension: PhotoReasoningViewModel.largestImageDimension)) {
                    processedImage = resizedImage
                } else {
                    logger.error("Failed to resize image: \(image)")
                    continue
                }
                images.append(processedImage)
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
