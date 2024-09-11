import Foundation
import SwiftUI
import UIKit
import SwiftData

func saveImageToDisk(_ image: UIImage, withName name: String) -> String? {
    if let data = image.jpegData(compressionQuality: 0.8) {
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        try? data.write(to: filename)
        return filename.path
    }
    return nil
}

func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

enum ClothingCategory: String, CaseIterable, Identifiable {
    case headwear = "Headwear"
    case tops = "Tops"
    case bottoms = "Bottoms"
    case shoes = "Shoes"
    
    var id: String { self.rawValue }
}

@Model
class ClothingItem {
    var id: UUID = UUID() // Removed the primaryKey attribute, SwiftData will automatically manage it
    var name: String
    var descriptionText: String // Renamed to avoid conflict with Swift's `description`
    var category: String // Stored as String for compatibility with SwiftData
    var imagePath: String? // Path to the image stored on disk

    init(name: String, descriptionText: String, category: String, imagePath: String? = nil) {
        self.name = name
        self.descriptionText = descriptionText
        self.category = category
        self.imagePath = imagePath
    }
}
