import SwiftUI
import MediaPlayer

struct MediaPickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onPick: ([MPMediaItem]) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.allowsPickingMultipleItems = false
        picker.showsCloudItems = true
        picker.showsItemsWithProtectedAssets = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: Context) {}

    class Coordinator: NSObject, MPMediaPickerControllerDelegate {
        let parent: MediaPickerView
        init(_ parent: MediaPickerView) { self.parent = parent }

        func mediaPicker(_ mediaPicker: MPMediaPickerController,
                         didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            parent.isPresented = false
            parent.onPick(mediaItemCollection.items)
        }

        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            parent.isPresented = false
        }
    }
}
