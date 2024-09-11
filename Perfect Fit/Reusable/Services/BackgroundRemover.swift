import UIKit
import Vision
import CoreML

class BackgroundRemover {
    
    private let model: VNCoreMLModel
    
    init() {
        // Initialize the DeepLabV3 model
        guard let deepLabModel = try? DeepLabV3(configuration: .init()).model else {
            fatalError("Failed to load DeepLabV3 model")
        }
        guard let visionModel = try? VNCoreMLModel(for: deepLabModel) else {
            fatalError("Failed to create VNCoreMLModel")
        }
        self.model = visionModel
    }

    func removeBackground(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        // Resize the image to 513x513 with padding
        guard let resizedImage = resizeImage(image, to: CGSize(width: 513, height: 513)) else {
            print("Failed to resize image.")
            completion(nil)
            return
        }

        guard let ciImage = CIImage(image: resizedImage) else {
            print("Failed to create CIImage from input image.")
            completion(nil)
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Error during CoreML request: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Check if the model output is a MultiArray
            guard let results = request.results as? [VNCoreMLFeatureValueObservation], let result = results.first else {
                print("No results from the model.")
                completion(nil)
                return
            }

            print("Received MultiArray result from the model")

            // Convert the MultiArray to a binary mask
            if let multiArray = result.featureValue.multiArrayValue {
                let mask = self.createMask(from: multiArray)
                let maskedImage = self.applyMask(mask, to: resizedImage)
                completion(maskedImage)
            } else {
                print("No MultiArray found in the model output.")
                completion(nil)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error processing the image: \(error.localizedDescription)")
            completion(nil)
        }
    }

    // Convert MultiArray to a binary mask
    private func createMask(from multiArray: MLMultiArray) -> UIImage? {
        let width = multiArray.shape[0].intValue
        let height = multiArray.shape[1].intValue

        var pixelData = [UInt8](repeating: 0, count: width * height)

        // The multiArray contains segmentation class labels. We are interested in foreground vs background.
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let classValue = multiArray[index].intValue

                // Assuming class 0 is background and class 1 is foreground.
                if classValue == 1 {
                    pixelData[index] = 255 // Foreground (white)
                } else {
                    pixelData[index] = 0   // Background (black)
                }
            }
        }

        // Create a CGImage from the pixel data
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo: CGBitmapInfo = []

        guard let providerRef = CGDataProvider(data: Data(pixelData) as CFData),
              let cgImage = CGImage(
                  width: width,
                  height: height,
                  bitsPerComponent: 8,
                  bitsPerPixel: 8,
                  bytesPerRow: width,
                  space: colorSpace,
                  bitmapInfo: bitmapInfo,
                  provider: providerRef,
                  decode: nil,
                  shouldInterpolate: false,
                  intent: .defaultIntent) else {
            print("Failed to create mask CGImage.")
            return nil
        }

        return UIImage(cgImage: cgImage)
    }


    // Apply the binary mask to the original image
    private func applyMask(_ mask: UIImage?, to image: UIImage) -> UIImage? {
        guard let mask = mask else {
            print("No mask to apply.")
            return nil
        }
        
        // Convert both the mask and image to CGImage
        guard let cgImage = image.cgImage, let maskCGImage = mask.cgImage else {
            print("Failed to get CGImage from UIImage.")
            return nil
        }

        let width = image.size.width
        let height = image.size.height

        // Begin a new image context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Failed to get graphics context.")
            return nil
        }

        // Flip the context vertically to fix the upside-down issue
        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)

        // Draw the image first
        let rect = CGRect(origin: .zero, size: image.size)
        context.draw(cgImage, in: rect)

        // Create a mask with the alpha channel based on the mask
        context.clip(to: rect, mask: maskCGImage)

        // Set the fill color to clear (for background)
        context.setBlendMode(.clear)
        context.fill(rect)

        // Retrieve the resulting image
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage
    }


    // Resize the image to exactly 513x513 by adding padding if needed
    private func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage? {
        let aspectWidth = targetSize.width / image.size.width
        let aspectHeight = targetSize.height / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)

        // Calculate the size based on the aspect ratio
        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)

        // Create a white background of size 513x513
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let paddedImage = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))

            let origin = CGPoint(x: (targetSize.width - newSize.width) / 2, y: (targetSize.height - newSize.height) / 2)
            image.draw(in: CGRect(origin: origin, size: newSize))
        }

        return paddedImage
    }
}
