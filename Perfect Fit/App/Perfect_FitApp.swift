import SwiftUI
import SwiftData

@main
struct Perfect_FitApp: App {
    // Create a ModelContainer that includes the ClothingItem model
    @State private var container = try! ModelContainer(for: ClothingItem.self)
    
    var body: some Scene {
        WindowGroup {
            // Pass the ModelContainer's context to the ViewModel
            ClothingListView(viewModel: ClothingListViewModel(context: container.mainContext))
                .modelContainer(container)
        }
    }
}
