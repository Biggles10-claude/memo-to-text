import SwiftUI
import Core

/// Job home. Proof: MemoLibrary, LibraryScreen.
struct LibraryScreen: View {
    @EnvironmentObject private var library: MemoLibrary
    @State private var showRecorder = false
    @State private var showImport = false
    @State private var showNewFolder = false
    @State private var newFolder = ""
    @State private var renameTarget: Memo?
    @State private var renameText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DT.spaceL) {
                header
                actions
                folderRow
                if let loadError = library.loadError {
                    ErrorStateView(message: LocalizedStringKey(loadError), retry: library.reload)
                } else if library.visibleMemos.isEmpty {
                    EmptyStateView(
                        title: "No memos yet",
                        message: "Record a note or import a lecture to get a private transcript. Nothing leaves this phone.",
                        systemImage: "waveform",
                        actionTitle: "Record",
                        action: { showRecorder = true },
                        secondaryTitle: "Import audio",
                        secondaryAction: { showImport = true }
                    )
                } else {
                    LazyVStack(spacing: DT.spaceS) {
                        ForEach(library.visibleMemos) { memo in
                            NavigationLink {
                                TranscriptScreen(memoID: memo.id)
                            } label: {
                                MemoRow(memo: memo)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Rename") {
                                    renameTarget = memo
                                    renameText = memo.title
                                }
                                Menu("Move to") {
                                    ForEach(library.folders, id: \.self) { folder in
                                        Button(folder) { library.move(ids: [memo.id], to: folder) }
                                    }
                                }
                                Button("Delete", role: .destructive) { library.delete(id: memo.id) }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DT.spaceM)
            .padding(.bottom, DT.spaceXL)
        }
        .background(DT.screenBackground.ignoresSafeArea())
        .navigationTitle("Private transcripts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink { SearchScreen() } label: {
                    Image(systemName: "magnifyingglass")
                        .frame(width: DT.tap, height: DT.tap)
                }
                .accessibilityLabel("Search")
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 0) {
                    Button {
                        showNewFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .frame(width: DT.tap, height: DT.tap)
                    }
                    .accessibilityLabel("New folder")
                    NavigationLink { SettingsScreen() } label: {
                        Image(systemName: "gearshape")
                            .frame(width: DT.tap, height: DT.tap)
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
        .alert("New folder", isPresented: $showNewFolder) {
            TextField("Folder name", text: $newFolder)
            Button("Add") {
                library.addFolder(newFolder)
                newFolder = ""
            }
            Button("Cancel", role: .cancel) { newFolder = "" }
        }
        .navigationDestination(isPresented: $showRecorder) {
            RecorderScreen()
        }
        .navigationDestination(isPresented: $showImport) {
            ImportScreen()
        }
        .alert("Rename memo", isPresented: Binding(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } }
        )) {
            TextField("Title", text: $renameText)
            Button("Save") {
                if let id = renameTarget?.id {
                    library.renameMemo(id: id, to: renameText)
                }
                renameTarget = nil
            }
            Button("Cancel", role: .cancel) { renameTarget = nil }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DT.spaceS) {
            Text("Private transcripts")
                .font(DT.captionFont())
                .foregroundStyle(DT.inkSecondary)
                .textCase(.uppercase)
                .tracking(1.1)
            Text("Record or import.")
                .font(DT.heroFont())
                .foregroundStyle(DT.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Search later.")
                .font(DT.titleFont())
                .foregroundStyle(DT.inkSecondary)
        }
        .padding(.top, DT.spaceS)
    }

    private var actions: some View {
        HStack(spacing: DT.spaceS) {
            PrimaryCTA(title: "Record", systemImage: "mic.fill") { showRecorder = true }
            GhostCTA(title: "Import", systemImage: "square.and.arrow.down") { showImport = true }
        }
    }

    private var folderRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DT.spaceS) {
                folderChip(nil, label: "All")
                ForEach(library.folders, id: \.self) { folder in
                    folderChip(folder, label: folder)
                }
            }
        }
    }

    private func folderChip(_ folder: String?, label: String) -> some View {
        let on = library.selectedFolder == folder
        return Button {
            withAnimation(DT.chip) { library.selectedFolder = folder }
        } label: {
            Text(label)
                .font(DT.headlineFont())
                .padding(.horizontal, DT.spaceM)
                .frame(minHeight: DT.tap)
                .foregroundStyle(on ? DT.paperElevated : DT.ink)
                .background(on ? DT.accent : DT.cardBackground, in: Capsule())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

struct MemoRow: View {
    let memo: Memo

    var body: some View {
        HStack(alignment: .top, spacing: DT.spaceM) {
            VStack(alignment: .leading, spacing: DT.spaceXS) {
                HStack(alignment: .firstTextBaseline) {
                    Text(memo.title)
                        .font(DT.titleFont())
                        .foregroundStyle(DT.ink)
                        .lineLimit(2)
                    Spacer(minLength: DT.spaceS)
                    Text(DurationFormat.clock(memo.duration))
                        .font(DT.captionFont())
                        .foregroundStyle(DT.paperElevated)
                        .padding(.horizontal, 10)
                        .frame(minHeight: 28)
                        .background(DT.accent, in: Capsule())
                        .accessibilityLabel("Duration \(DurationFormat.clock(memo.duration))")
                }
                Text(memo.folder)
                    .font(DT.captionFont())
                    .foregroundStyle(DT.accent)
                Text(rowSubtitle)
                    .font(DT.bodyFont())
                    .foregroundStyle(DT.inkSecondary)
                    .lineLimit(2)
            }
        }
        .padding(DT.spaceM)
        .background(DT.cardBackground, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous)
                .stroke(DT.rule, lineWidth: 1)
        )
    }

    private var rowSubtitle: String {
        switch memo.status {
        case .transcribing: return "Transcribing on this device"
        case .failed: return memo.lastError ?? "Transcription failed"
        case .recorded: return "Audio saved. Run transcription."
        case .ready:
            return memo.preview.isEmpty ? "Transcript is empty" : memo.preview
        }
    }
}
