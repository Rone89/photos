import Foundation
import Photos

#if DEBUG
extension PhotoManagerViewModel {
    static let mock: PhotoManagerViewModel = {
        let viewModel = PhotoManagerViewModel()
        
        // 创建模拟月份数据
        let calendar = Calendar.current
        let now = Date()
        
        var mockMonths: [Month] = []
        
        for monthOffset in 0..<3 {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月"
            let monthTitle = dateFormatter.string(from: monthDate)
            
            // 创建模拟照片
            var photos: [Photo] = []
            let photoCount = Int.random(in: 5...15)
            
            for i in 0..<photoCount {
                // 这里只是模拟数据，实际应用中会使用真实的 PHAsset
                // 在预览中，我们使用占位符
                let photo = Photo(
                    id: "mock-\(monthOffset)-\(i)",
                    asset: PHAsset(), // 注意：这是空的 PHAsset，仅用于预览
                    status: [.unmarked, .saved, .deleted].randomElement()!
                )
                photos.append(photo)
            }
            
            let month = Month(
                id: monthTitle,
                title: monthTitle,
                photos: photos,
                currentIndex: 0
            )
            mockMonths.append(month)
        }
        
        viewModel.months = mockMonths
        viewModel.isLoading = false
        
        return viewModel
    }()
}

extension PhotoManagerViewModel.Month {
    static let mock = PhotoManagerViewModel.Month(
        id: "2024年01月",
        title: "2024年01月",
        photos: [
            PhotoManagerViewModel.Photo(id: "1", asset: PHAsset(), status: .unmarked),
            PhotoManagerViewModel.Photo(id: "2", asset: PHAsset(), status: .saved),
            PhotoManagerViewModel.Photo(id: "3", asset: PHAsset(), status: .deleted),
        ],
        currentIndex: 0
    )
}
#endif