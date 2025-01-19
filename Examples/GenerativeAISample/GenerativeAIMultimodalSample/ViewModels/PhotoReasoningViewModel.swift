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
        await generateOutput(prompt: """
        繁體中文回答，基於照片提供幽默且趣味化的性格解讀，整體內容需要：
        1. 強調內容純屬虛構、僅供娛樂用途；
        2. 誇張但合理，避免使用如「神秘莫測」、「深度學習」等容易讓用戶誤解為真實分析的字眼；
        3. 描述需突出「AI 趣味模擬」的定位，減少暗示真實性或過於擬人化的表述；
        4. 必須避免任何可能被聯想到「迷信」或「命運預測」的語句，僅用輕鬆、幽默的方式描述性格特點。
        """)
    }


    func name() async {
        await generateOutput(prompt: """
        繁體中文回答，根據照片中的人物特徵，生成一個幽默且有創意的綽號，內容需要：
        1. 突出趣味性和娛樂性，避免讓人聯想到真實分析或深度技術；
        2. 綽號需帶有親和力與幽默感，但不能使用帶有攻擊性或可能引起誤會的詞語；
        3. 描述需強調 AI 技術的趣味模擬特點，並表明結果僅供娛樂用途。
        """)
    }

    func pastLife() async {
        await generateOutput(prompt: """
        繁體中文回答，根據照片中的人物特徵，編造一個幽默且誇張的前世身份和故事，內容需要：
        1. 故事必須完全虛構，並強調「僅供娛樂用途」；
        2. 描述應輕鬆、誇張但不脫離現實，避免使用「深層挖掘」、「命運預測」等容易引發誤解的詞語；
        3. 必須減少任何可能暗示真實性的語句，突出 AI 趣味模擬的定位；
        4. 避免提及與宗教、迷信相關的內容，將焦點放在趣味與創意上。
        """)
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
