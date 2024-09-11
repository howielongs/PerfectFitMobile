import SwiftData
import SwiftUI

class ClothingListViewModel: ObservableObject {
    @Published var clothingItems: [ClothingItem] = []
    private var context: ModelContext

    init(context: ModelContext) {
        self.context = context
        loadClothingItems()
    }

    func loadClothingItems() {
        let fetchRequest = FetchDescriptor<ClothingItem>()
        do {
            let results = try context.fetch(fetchRequest)
            clothingItems = results
        } catch {
            print("Failed to fetch clothing items: \(error)")
        }
    }

    func addItem(name: String, category: String, imagePath: String?) {
        let newItem = ClothingItem(name: name, descriptionText: "A new item.", category: category, imagePath: imagePath)
        context.insert(newItem)

        do {
            try context.save()
            // Directly append the new item to the @Published array to trigger a UI refresh
            clothingItems.append(newItem)
        } catch {
            print("Failed to save new clothing item: \(error)")
        }
    }

    func deleteItem(item: ClothingItem) {
        context.delete(item)
        do {
            try context.save()
            // Update the local array after deletion
            if let index = clothingItems.firstIndex(of: item) {
                clothingItems.remove(at: index)
            }
        } catch {
            print("Failed to delete clothing item: \(error)")
        }
    }

    func updateItem(item: ClothingItem) {
        if let index = clothingItems.firstIndex(where: { $0.id == item.id }) {
            clothingItems[index] = item
            do {
                try context.save()
                // No need to call loadClothingItems here since @Published will update the UI automatically
            } catch {
                print("Failed to update clothing item: \(error)")
            }
        }
    }
}
