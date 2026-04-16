import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var viewModel = PhotoManagerViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("加载照片中...")
                } else if viewModel.months.isEmpty {
                    Text("未找到照片")
                        .foregroundColor(.secondary)
                } else {
                    MonthListView(viewModel: viewModel)
                }
            }
            .navigationTitle("照片管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("重新加载") {
                        viewModel.loadPhotos()
                    }
                }
            }
            .alert("需要相册权限", isPresented: $viewModel.showPermissionAlert) {
                Button("去设置") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("取消", role: .cancel) { }
            } message: {
                Text("请在设置中允许访问相册以使用此应用")
            }
        }
        .onAppear {
            viewModel.requestPhotoAccess()
        }
    }
}

struct MonthListView: View {
    @ObservedObject var viewModel: PhotoManagerViewModel
    
    var body: some View {
        List(viewModel.months) { month in
            NavigationLink {
                PhotoSwipeView(viewModel: viewModel, month: month)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(month.title)
                            .font(.headline)
                        Text("\(month.photos.count) 张照片")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if viewModel.isMonthCompleted(month) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .environmentObject(PhotoManagerViewModel.mock)
}
#endif