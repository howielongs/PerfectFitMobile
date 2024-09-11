//
//  ClothingDetailView.swift
//  Perfect Fit
//
//  Created by Howie Long on 9/3/24.
//

import Foundation
import SwiftUI
import SwiftData

struct ClothingDetailView: View {
    @Binding var item: ClothingItem
    @ObservedObject var viewModel: ClothingListViewModel
    @State private var isEditing = false
    @State private var showImagePicker = false
    @State private var imageSourceType: ImagePickerSource = .photoLibrary // Default source type
    @State private var tempImage: UIImage? = nil // Temporary storage for the image

    @State private var tempName: String = ""
    @State private var tempDescription: String = ""
    @State private var tempCategory: ClothingCategory = .headwear

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Image or placeholder
            if let image = tempImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(10)
            } else if let imagePath = item.imagePath, let savedImage = UIImage(contentsOfFile: imagePath) {
                Image(uiImage: savedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Text("Tap to add image")
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(10)
                    .onTapGesture {
                        showImagePicker = true
                    }
            }

            // Editable fields for item name and description
            if isEditing {
                TextField("Item Name", text: $tempName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Description", text: $tempDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(item.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(item.descriptionText) // Updated to descriptionText
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            // Picker for editing the clothing category
            if isEditing {
                Picker("Category", selection: $tempCategory) {
                    ForEach(ClothingCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            } else {
                Text("Category: \(item.category)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            Spacer()

            // Save or Edit buttons
            if isEditing {
                Button(action: {
                    // Commit changes to the actual item only when Save is pressed
                    item.name = tempName
                    item.descriptionText = tempDescription
                    item.category = tempCategory.rawValue
                    if let image = tempImage {
                        let imageName = UUID().uuidString + ".jpg"
                        if let imagePath = saveImageToDisk(image, withName: imageName) {
                            item.imagePath = imagePath
                        }
                    }
                    viewModel.updateItem(item: item)
                    isEditing.toggle()
                }) {
                    Text("Save")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Button(action: {
                    // Initialize temp variables with the current values when entering edit mode
                    tempName = item.name
                    tempDescription = item.descriptionText
                    tempCategory = ClothingCategory(rawValue: item.category) ?? .headwear
                    isEditing.toggle()
                }) {
                    Text("Edit")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $tempImage, sourceType: imageSourceType)
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ClothingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: ClothingItem.self) // Create ModelContainer
        let viewModel = ClothingListViewModel(context: container.mainContext)
        
        return ClothingDetailView(
            item: .constant(ClothingItem(name: "T-shirt", descriptionText: "A comfortable cotton T-shirt.", category: "Tops")),
            viewModel: viewModel
        )
        .modelContainer(container)
    }
}
