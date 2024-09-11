import Foundation
import SwiftUI
import SwiftData

struct OutfitGeneratorView: View {
    @ObservedObject var viewModel: ClothingListViewModel
    @State private var headwearIndex = 0
    @State private var topsIndex = 0
    @State private var bottomsIndex = 0
    @State private var shoesIndex = 0

    // Lock states
    @State private var headwearLocked = false
    @State private var topsLocked = false
    @State private var bottomsLocked = false
    @State private var shoesLocked = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)

            // Headwear
            HStack {
                Button(action: { cycleLeft(for: &headwearIndex, items: headwear) }) {
                    Image(systemName: "chevron.left")
                        .font(.largeTitle)
                        .padding()
                }
                Spacer()
                if let item = headwear[safe: headwearIndex], let imagePath = item.imagePath, let uiImage = UIImage(contentsOfFile: imagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                        .padding()
                    // Lock button for headwear
                    Button(action: { headwearLocked.toggle() }) {
                        Image(systemName: headwearLocked ? "lock.fill" : "lock.open.fill")
                            .foregroundColor(headwearLocked ? .red : .green)
                            .padding(.leading, 10)
                    }
                }
                Spacer()
                Button(action: { cycleRight(for: &headwearIndex, items: headwear) }) {
                    Image(systemName: "chevron.right")
                        .font(.largeTitle)
                        .padding()
                }
            }

            // Tops
            HStack {
                Button(action: { cycleLeft(for: &topsIndex, items: tops) }) {
                    Image(systemName: "chevron.left")
                        .font(.largeTitle)
                        .padding()
                }
                Spacer()
                if let item = tops[safe: topsIndex], let imagePath = item.imagePath, let uiImage = UIImage(contentsOfFile: imagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .padding()
                    // Lock button for tops
                    Button(action: { topsLocked.toggle() }) {
                        Image(systemName: topsLocked ? "lock.fill" : "lock.open.fill")
                            .foregroundColor(topsLocked ? .red : .green)
                            .padding(.leading, 10)
                    }
                }
                Spacer()
                Button(action: { cycleRight(for: &topsIndex, items: tops) }) {
                    Image(systemName: "chevron.right")
                        .font(.largeTitle)
                        .padding()
                }
            }

            // Bottoms
            HStack {
                Button(action: { cycleLeft(for: &bottomsIndex, items: bottoms) }) {
                    Image(systemName: "chevron.left")
                        .font(.largeTitle)
                        .padding()
                }
                Spacer()
                if let item = bottoms[safe: bottomsIndex], let imagePath = item.imagePath, let uiImage = UIImage(contentsOfFile: imagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .padding()
                    // Lock button for bottoms
                    Button(action: { bottomsLocked.toggle() }) {
                        Image(systemName: bottomsLocked ? "lock.fill" : "lock.open.fill")
                            .foregroundColor(bottomsLocked ? .red : .green)
                            .padding(.leading, 10)
                    }
                }
                Spacer()
                Button(action: { cycleRight(for: &bottomsIndex, items: bottoms) }) {
                    Image(systemName: "chevron.right")
                        .font(.largeTitle)
                        .padding()
                }
            }

            // Shoes
            HStack {
                Button(action: { cycleLeft(for: &shoesIndex, items: shoes) }) {
                    Image(systemName: "chevron.left")
                        .font(.largeTitle)
                        .padding()
                }
                Spacer()
                if let item = shoes[safe: shoesIndex], let imagePath = item.imagePath, let uiImage = UIImage(contentsOfFile: imagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                        .padding()
                    // Lock button for shoes
                    Button(action: { shoesLocked.toggle() }) {
                        Image(systemName: shoesLocked ? "lock.fill" : "lock.open.fill")
                            .foregroundColor(shoesLocked ? .red : .green)
                            .padding(.leading, 10)
                    }
                }
                Spacer()
                Button(action: { cycleRight(for: &shoesIndex, items: shoes) }) {
                    Image(systemName: "chevron.right")
                        .font(.largeTitle)
                        .padding()
                }
            }

            Spacer()

            // Shuffle Outfit Button with grey background and blue text
            Button(action: {
                withAnimation(.easeInOut) {
                    randomizeOutfit()
                }
            }) {
                Text("Shuffle Outfit")
                    .font(.headline)
                    .foregroundColor(.blue) // Blue text
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5)) // Grey background
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 60) // Padding to avoid the button being too close to the bottom
        }
        .padding()
        .navigationBarTitle("Perfect Fit", displayMode: .inline)
    }

    // Get filtered arrays
    var headwear: [ClothingItem] {
        return viewModel.clothingItems.filter { $0.category == "Headwear" }
    }
    
    var tops: [ClothingItem] {
        return viewModel.clothingItems.filter { $0.category == "Tops" }
    }
    
    var bottoms: [ClothingItem] {
        return viewModel.clothingItems.filter { $0.category == "Bottoms" }
    }
    
    var shoes: [ClothingItem] {
        return viewModel.clothingItems.filter { $0.category == "Shoes" }
    }

    // Function to cycle left through the items
    func cycleLeft(for index: inout Int, items: [ClothingItem]) {
        if index == 0 {
            index = items.count - 1
        } else {
            index -= 1
        }
    }
    
    // Function to cycle right through the items
    func cycleRight(for index: inout Int, items: [ClothingItem]) {
        if index == items.count - 1 {
            index = 0
        } else {
            index += 1
        }
    }

    // Randomize the outfit, skipping locked sections
    func randomizeOutfit() {
        if !headwearLocked {
            headwearIndex = Int.random(in: 0..<headwear.count)
        }
        if !topsLocked {
            topsIndex = Int.random(in: 0..<tops.count)
        }
        if !bottomsLocked {
            bottomsIndex = Int.random(in: 0..<bottoms.count)
        }
        if !shoesLocked {
            shoesIndex = Int.random(in: 0..<shoes.count)
        }
    }
}

// Safe array access extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
