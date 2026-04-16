import SwiftUI
import Photos
import Combine

class PhotoManagerViewModel: ObservableObject {
    @Published var months: [Month] = []
    @Published var isLoading = false
    @Published var showPermissionAlert = false
    
    private var cancellables = Set<AnyCancellable>()
    
    struct Month: Identifiable {
        let id: String
        let title: String
        let photos: [Photo]
        var currentIndex: Int = 0
    }
    
    struct Photo: Identifiable {
        let id: String
        let asset: PHAsset
        var status: Status = .unmarked
        
        enum Status {
            case unmarked
            case saved
            case deleted
        }
    }
    
    func requestPhotoAccess() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            loadPhotos()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.loadPhotos()
                    } else {
                        self?.showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            break
        }
    }
    
    func loadPhotos() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            var monthDict: [String: [PHAsset]] = [:]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月"
            
            allPhotos.enumerateObjects { asset, _, _ in
                if let creationDate = asset.creationDate {
                    let monthKey = dateFormatter.string(from: creationDate)
                    monthDict[monthKey, default: []].append(asset)
                }
            }
            
            let months = monthDict.map { key, assets in
                let photos = assets.map { asset in
                    Photo(id: asset.localIdentifier, asset: asset)
                }
                return Month(id: key, title: key, photos: photos)
            }.sorted { $0.title > $1.title }
            
            DispatchQueue.main.async {
                self?.months = months
                self?.isLoading = false
            }
        }
    }
    
    func isMonthCompleted(_ month: Month) -> Bool {
        guard let monthIndex = months.firstIndex(where: { $0.id == month.id }) else { return false }
        return months[monthIndex].photos.allSatisfy { $0.status != .unmarked }
    }
    
    func markPhoto(in monthId: String, photoId: String, as status: Photo.Status) {
        guard let monthIndex = months.firstIndex(where: { $0.id == monthId }),
              let photoIndex = months[monthIndex].photos.firstIndex(where: { $0.id == photoId }) else { return }
        
        months[monthIndex].photos[photoIndex].status = status
    }
    
    func deleteMarkedPhotos(in monthId: String, completion: @escaping (Int) -> Void) {
        guard let monthIndex = months.firstIndex(where: { $0.id == monthId }) else { return }
        
        let assetsToDelete = months[monthIndex].photos
            .filter { $0.status == .deleted }
            .map { $0.asset }
        
        guard !assetsToDelete.isEmpty else {
            completion(0)
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.months[monthIndex].photos.removeAll { $0.status == .deleted }
                    completion(assetsToDelete.count)
                } else {
                    print("删除失败: \(error?.localizedDescription ?? "未知错误")")
                    completion(0)
                }
            }
        }
    }
}