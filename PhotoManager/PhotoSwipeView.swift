import SwiftUI
import Photos

struct PhotoSwipeView: View {
    @ObservedObject var viewModel: PhotoManagerViewModel
    let month: PhotoManagerViewModel.Month
    
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showOverview = false
    
    private var currentPhoto: PhotoManagerViewModel.Photo? {
        guard currentIndex >= 0 && currentIndex < month.photos.count else { return nil }
        return month.photos[currentIndex]
    }
    
    var body: some View {
        VStack {
            if month.photos.isEmpty {
                Text("本月没有照片")
                    .foregroundColor(.secondary)
            } else if currentIndex >= month.photos.count {
                MonthOverviewView(viewModel: viewModel, month: month, showOverview: $showOverview)
            } else {
                photoView
                    .gesture(dragGesture)
            }
        }
        .navigationTitle(month.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("总览") {
                    showOverview = true
                }
            }
        }
        .sheet(isPresented: $showOverview) {
            MonthOverviewView(viewModel: viewModel, month: month, showOverview: $showOverview)
        }
    }
    
    private var photoView: some View {
        VStack {
            if let photo = currentPhoto {
                PhotoThumbnailView(asset: photo.asset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .offset(dragOffset)
                    .animation(.interactiveSpring(), value: dragOffset)
                
                HStack {
                    Text("左滑保存")
                        .foregroundColor(.green)
                    Spacer()
                    Text("\(currentIndex + 1)/\(month.photos.count)")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("上滑删除")
                        .foregroundColor(.red)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let horizontalThreshold: CGFloat = 100
                let verticalThreshold: CGFloat = 100
                
                if value.translation.width > horizontalThreshold {
                    // 右滑：返回上一张
                    if currentIndex > 0 {
                        currentIndex -= 1
                    }
                } else if value.translation.width < -horizontalThreshold {
                    // 左滑：标记为保存并切换到下一张
                    markCurrentPhoto(as: .saved)
                    moveToNextPhoto()
                } else if value.translation.height < -verticalThreshold {
                    // 上滑：标记为删除并切换到下一张
                    markCurrentPhoto(as: .deleted)
                    moveToNextPhoto()
                }
                
                dragOffset = .zero
            }
    }
    
    private func markCurrentPhoto(as status: PhotoManagerViewModel.Photo.Status) {
        guard let photo = currentPhoto else { return }
        viewModel.markPhoto(in: month.id, photoId: photo.id, as: status)
    }
    
    private func moveToNextPhoto() {
        if currentIndex < month.photos.count - 1 {
            currentIndex += 1
        } else {
            // 已经浏览完所有照片
            currentIndex = month.photos.count
        }
    }
}

struct PhotoThumbnailView: View {
    let asset: PHAsset
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 800, height: 800),
            contentMode: .aspectFit,
            options: options
        ) { result, _ in
            DispatchQueue.main.async {
                self.image = result
            }
        }
    }
}