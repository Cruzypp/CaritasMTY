import SwiftUI

struct GallerySection: View {
    let photoUrls: [String]?
    @State private var showAllPhotos = false
    
    var body: some View {
        VStack(spacing: 10) {
            if let urls = photoUrls, !urls.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(180)), count: 2), spacing: 10) {
                    
                    ForEach(Array(urls.prefix(3).enumerated()), id: \.offset) { _, urlString in
                        if let url = URL(string: urlString) {
                            Button { showAllPhotos = true } label: {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 180, height: 150)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    default:
                                        ZStack {
                                            Color(.systemGray6)
                                            ProgressView()
                                        }
                                        .frame(width: 180, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                    }
                    
                    if urls.count > 3 {
                        Button { showAllPhotos = true } label: {
                            ZStack {
                                Color(.gray.opacity(0.85))
                                Text("+\(urls.count - 3)")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                            }
                            .frame(width: 180, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .frame(maxWidth: 320, alignment: .center)
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showAllPhotos) {
            AllPhotosSheetView(photoUrls: photoUrls ?? [])
        }
    }
}

#Preview {
    GallerySection(photoUrls: [
        "https://picsum.photos/400/300",
        "https://picsum.photos/400/300",
        "https://picsum.photos/400/300",
        "https://picsum.photos/400/300"
    ])
}
