import SwiftUI
import Core

/// Full-text search. Proof: MemoSearchIndex, SearchScreen.
struct SearchScreen: View {
    @EnvironmentObject private var library: MemoLibrary
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var hits: [SearchHit] {
        let titles = Dictionary(uniqueKeysWithValues: library.memos.map { ($0.id, $0.title) })
        let segs = Dictionary(uniqueKeysWithValues: library.memos.map { ($0.id, $0.segments) })
        return MemoSearchIndex.hits(query: query, titles: titles, segments: segs)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(DT.inkSecondary)
                TextField("Search transcripts", text: $query)
                    .font(DT.bodyFont())
                    .textInputAutocapitalization(.never)
            }
            .padding(DT.spaceM)
            .background(DT.cardBackground)
            .padding(.horizontal, DT.spaceM)
            .padding(.top, DT.spaceS)

            if query.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
                EmptyStateView(
                    title: "Find a quote",
                    message: "Type two letters to search titles and every sentence in the library.",
                    systemImage: "magnifyingglass",
                    actionTitle: library.memos.isEmpty ? "Back to library" : nil,
                    action: library.memos.isEmpty ? { dismiss() } : nil
                )
                .padding(DT.spaceM)
                Spacer()
            } else if hits.isEmpty {
                EmptyStateView(
                    title: "No matches",
                    message: "Nothing in the local library contains that phrase.",
                    systemImage: "text.magnifyingglass",
                    actionTitle: "Clear search",
                    action: { query = "" }
                )
                .padding(DT.spaceM)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: DT.spaceS) {
                        ForEach(hits, id: \.segmentID) { hit in
                            NavigationLink {
                                TranscriptScreen(memoID: hit.memoID)
                            } label: {
                                VStack(alignment: .leading, spacing: DT.spaceXS) {
                                    Text(hit.title)
                                        .font(DT.titleFont())
                                        .foregroundStyle(DT.ink)
                                    Text(hit.sentence)
                                        .font(DT.bodyFont())
                                        .foregroundStyle(DT.inkSecondary)
                                        .lineLimit(3)
                                }
                                .padding(DT.spaceM)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(DT.cardBackground, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(DT.spaceM)
                }
            }
        }
        .background(DT.screenBackground.ignoresSafeArea())
        .navigationTitle("Search")
    }
}
