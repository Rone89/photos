import SwiftUI
import Photos

struct MonthOverviewView: View {
    @ObservedObject var viewModel: PhotoManagerViewModel
    let month: PhotoManagerViewModel.Month
    @Binding var showOverview: Bool
    
    @State private var showDeleteConfirmation = false
    @State private var deletionResult: String?
    
    private var savedPhotos: [PhotoManagerViewModel.Photo] {
        month.photos.filter { $0.status == .saved }
    }
    
    private var deletedPhotos: [PhotoManagerViewModel.Photo] {
        month.photos.filter { $0.status == .deleted }
    }
    
    private var unmarkedPhotos: [PhotoManagerViewModel.Photo] {
        month.photos.filter { $0.status == .unmarked }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 统计信息
                    HStack(spacing: 20) {
                        StatView(title: "保存", count: savedPhotos.count, color: .green)
                        StatView(title: "删除", count: deletedPhotos.count, color: .red)
                        StatView(title: "未标记", count: unmarkedPhotos.count, color: .gray)
                    }
                    .padding(.horizontal)
                    
                    // 保存的照片
                    if !savedPhotos.isEmpty {
                        SectionView(title: "保存的照片", photos: savedPhotos, color: .green)
                    }
                    
                    // 删除的照片
                    if !deletedPhotos.isEmpty {
                        SectionView(title: "待删除的照片", photos: deletedPhotos, color: .red)
                    }
                    
                    // 未标记的照片
                    if !unmarkedPhotos.isEmpty {
                        SectionView(title: "未标记的照片", photos: unmarkedPhotos, color: .gray)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("\(month.title) 总览")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        showOverview = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !deletedPhotos.isEmpty {
                        Button("删除标记照片") {
                            showDeleteConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert("确认删除", isPresented: $showDeleteConfirmation) {
                Button("删除", role: .destructive) {
                    deleteMarkedPhotos()
                }
                Button("取消", role: .cancel) { }
            } message: {
                Text("确定要删除 \(deletedPhotos.count) 张标记为删除的照片吗？此操作不可撤销。")
            }
            .alert("删除结果", isPresented: .init(
                get: { deletionResult != nil },
                set: { if !$0 { deletionResult = nil } }
            )) {
                Button("确定") { deletionResult = nil }
            } message: {
                Text(deletionResult ?? "")
            }
        }
    }
    
    private func deleteMarkedPhotos() {
        viewModel.deleteMarkedPhotos(in: month.id) { deletedCount in
            if deletedCount > 0 {
                deletionResult = "成功删除 \(deletedCount) 张照片"
            } else {
                deletionResult = "删除失败，请重试"
            }
        }
    }
}

struct StatView: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct SectionView: View {
    let title: String
    let photos: [PhotoManagerViewModel.Photo]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(photos) { photo in
                        PhotoThumbnailView(asset: photo.asset)
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(color, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}