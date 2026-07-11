import SwiftUI
import MusicKit

struct CatalogSearchView: View {
    @EnvironmentObject var controller: MusicController
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        NavigationStack {
            Group {
                if controller.isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = controller.catalogSearchError {
                    ContentUnavailableView(
                        "Cannot Access Apple Music",
                        systemImage: "exclamationmark.circle",
                        description: Text(error)
                    )
                } else if controller.catalogSearchResults.isEmpty && !query.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try a different search term.")
                    )
                } else if query.isEmpty {
                    ContentUnavailableView(
                        "Search Apple Music",
                        systemImage: "music.note",
                        description: Text("Search for songs in the Apple Music catalog.")
                    )
                } else {
                    List(controller.catalogSearchResults, id: \.id) { song in
                        Button {
                            Task {
                                await controller.playCatalogSong(song)
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if let artwork = song.artwork {
                                    ArtworkImage(artwork, width: 44)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.secondary.opacity(0.2))
                                        .frame(width: 44, height: 44)
                                        .overlay {
                                            Image(systemName: "music.note")
                                                .foregroundStyle(.secondary)
                                        }
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(song.title)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    Text(song.artistName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $query, prompt: "Artists, Songs, Lyrics")
            .onChange(of: query) { newValue in
                Task { await controller.searchCatalog(query: newValue) }
            }
            .navigationTitle("Apple Music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
