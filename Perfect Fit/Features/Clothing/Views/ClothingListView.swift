import SwiftUI
import SwiftData
import CoreML
import Vision

struct ClothingListView: View {
    @ObservedObject var viewModel: ClothingListViewModel
    @State private var newItemName: String = ""
    @State private var selectedCategory: ClothingCategory = .headwear
    @State private var showImagePicker = false
    @State private var imageSourceType: ImagePickerSource = .photoLibrary
    @State private var tempImage: UIImage? = nil
    @State private var showOutfitGenerator = false // State to navigate to outfit generation view
    let backgroundRemover = BackgroundRemover() // Background removal instance

    var body: some View {
        NavigationView {
            VStack {
                // Picker for category
                Picker("Select Category", selection: $selectedCategory) {
                    ForEach(ClothingCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // List of clothing items
                List {
                    let filteredItems = viewModel.clothingItems.filter { $0.category == selectedCategory.rawValue }
                    
                    ForEach(filteredItems) { item in
                        NavigationLink(destination: ClothingDetailView(item: Binding(
                            get: { item },
                            set: { updatedItem in
                                if let index = viewModel.clothingItems.firstIndex(where: { $0.id == item.id }) {
                                    viewModel.clothingItems[index] = updatedItem
                                }
                            }
                        ), viewModel: viewModel)) {
                            HStack {
                                if let imagePath = item.imagePath, let uiImage = UIImage(contentsOfFile: imagePath) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(10)
                                }
                                Text(item.name)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }

                // HStack for adding new item
                HStack {
                    TextField("Add new item", text: $newItemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: {
                        if newItemName.isEmpty { return }
                        showImagePickerOptions()
                    }) {
                        Text("Add")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()

                // Button to navigate to outfit generator
                Button(action: {
                    showOutfitGenerator = true
                }) {
                    Text("Generate Outfit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                // NavigationLink to the OutfitGeneratorView
                NavigationLink(destination: OutfitGeneratorView(viewModel: viewModel), isActive: $showOutfitGenerator) {
                    EmptyView()
                }
            }
            .navigationBarTitle("Clothing List")
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $tempImage, sourceType: imageSourceType)
                    .onDisappear {
                        addItemWithImage()
                    }
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for offset in offsets {
            let item = viewModel.clothingItems[offset]
            viewModel.deleteItem(item: item)
        }
    }

    private func showImagePickerOptions() {
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.imageSourceType = .camera
            self.showImagePicker = true
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.imageSourceType = .photoLibrary
            self.showImagePicker = true
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    }

    // Method to handle background removal and saving the image
    private func addItemWithImage() {
        if let image = tempImage {
            backgroundRemover.removeBackground(from: image) { processedImage in
                guard let processedImage = processedImage else {
                    print("Background removal failed")
                    return
                }

                let imageName = UUID().uuidString + ".jpg"
                if let imagePath = saveImageToDisk(processedImage, withName: imageName) {
                    print("Image saved at path: \(imagePath)")
                    viewModel.addItem(name: newItemName, category: selectedCategory.rawValue, imagePath: imagePath)
                } else {
                    print("Failed to save image")
                }
            }
        } else {
            viewModel.addItem(name: newItemName, category: selectedCategory.rawValue, imagePath: nil)
        }
        newItemName = ""
        tempImage = nil
    }


    // Function to save the image to disk
    private func saveImageToDisk(_ image: UIImage, withName imageName: String) -> String? {
        guard let data = image.pngData() else { return nil } // Use PNG for transparency support
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documents.appendingPathComponent(imageName)
        do {
            try data.write(to: filePath)
            return filePath.path
        } catch {
            print("Error saving image to disk: \(error)")
            return nil
        }
    }
}
