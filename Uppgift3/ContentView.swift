//
//  ContentView.swift
//  Uppgift3
//
//  Created by Martin Lundgren on 2024-10-30.
//

// Request:
// https://dog.ceo/api/breeds/image/random
//
// Example Response:
// {
// "message": "https://images.dog.ceo/breeds/schnauzer-miniature/n02097047_6567.jpg",
// "status": "success"
// }
//

import SwiftUI

struct DogImage: Codable {
    let message: String
    let status: String
}

struct ContentView: View {
    @State private var dogImageURL: URL?
    @State private var breedName: String = "Unknown Breed"
    
    var body: some View {
        VStack {
            // Display the breed name above the image
            Text(breedName.capitalized)
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 5)
            
            // Display the dog image if the URL is available, otherwise show a placeholder text
            if let url = dogImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Show a loading indicator while fetching the image
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    case .failure:
                        Text("Failed to load image")
                            .foregroundColor(.red)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Text("Press the button to load a dog image")
                    .padding()
            }
            
            // Button to fetch a new dog image
            Button("Load New Dog Image") {
                Task {
                    await fetchRandomDogImage()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    
    // Function to fetch a random dog image
    func fetchRandomDogImage() async {
        let urlString = "https://dog.ceo/api/breeds/image/random"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(DogImage.self, from: data)
            dogImageURL = URL(string: decodedData.message)
            
            // Extract and format the breed name from the URL
            if let breed = extractBreedName(from: decodedData.message) {
                breedName = formatBreedName(breed)
            }
        } catch {
            print("Error fetching dog image: \(error)")
            
            // Set default values if fetching fails
            dogImageURL = URL(string: "https://via.placeholder.com/300") // Placeholder image URL
            breedName = "Error loading breed"
        }
    }
    
    // Function to extract the breed name from the URL
    func extractBreedName(from url: String) -> String? {
        let components = url.components(separatedBy: "/")
        if let breedIndex = components.firstIndex(of: "breeds"), breedIndex + 1 < components.count {
            return components[breedIndex + 1]
        }
        return nil
    }
    
    // Function to format breed name by switching order if it contains two words
    func formatBreedName(_ breed: String) -> String {
        // Replace dashes with spaces to make it more readable
        let name = breed.replacingOccurrences(of: "-", with: " ")
        
        // Split the name into words
        let words = name.split(separator: " ")
        
        // If the breed has exactly two words, switch their order
        if words.count == 2 {
            return "\(words[1].capitalized) \(words[0].capitalized)"
        }
        
        // If it's not a two-word breed, just capitalize the name
        return name.capitalized
    }

}

#Preview {
    ContentView()
}
