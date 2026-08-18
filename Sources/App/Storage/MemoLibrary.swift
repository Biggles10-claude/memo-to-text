import Foundation
import Core

/// Persistent memo archive. Proof: MemoLibrary, FolderStore, renameMemo.
@MainActor
final class MemoLibrary: ObservableObject {
    nonisolated static let memosKey = "memo-to-text.memos.v1"
    nonisolated static let foldersKey = "memo-to-text.folders.v1"

    @Published private(set) var memos: [Memo] = []
    @Published private(set) var folders: [String] = FolderCatalog.defaults
    @Published var selectedFolder: String? = nil
    @Published var loadError: String? = nil

    let folderStore = FolderStore()
    private let store: LocalStore
    private let fileManager: FileManager

    init(store: LocalStore = LocalStore(), fileManager: FileManager = .default) {
        self.store = store
        self.fileManager = fileManager
        reload()
    }

    var visibleMemos: [Memo] {
        let base = memos.sorted { $0.createdAt > $1.createdAt }
        guard let selectedFolder else { return base }
        return base.filter { $0.folder == selectedFolder }
    }

    func reload() {
        do {
            if let saved = store.load([Memo].self, forKey: Self.memosKey) {
                memos = saved
            } else {
                memos = []
            }
            folders = folderStore.load(store: store)
            loadError = nil
        }
    }

    func save() {
        store.save(memos, forKey: Self.memosKey)
        folderStore.save(folders, store: store)
    }

    func upsert(_ memo: Memo) {
        if let idx = memos.firstIndex(where: { $0.id == memo.id }) {
            memos[idx] = memo
        } else {
            memos.insert(memo, at: 0)
        }
        save()
    }

    func memo(id: String) -> Memo? {
        memos.first { $0.id == id }
    }

    func renameMemo(id: String, to raw: String) {
        guard var memo = memo(id: id) else { return }
        let title = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        memo.title = title.isEmpty ? memo.title : String(title.prefix(80))
        upsert(memo)
    }

    func move(ids: [String], to folder: String) {
        let name = FolderCatalog.sanitized(folder) ?? FolderCatalog.inbox
        if !folders.contains(name) {
            folders.append(name)
        }
        for id in ids {
            guard var memo = memo(id: id) else { continue }
            memo.folder = name
            upsert(memo)
        }
    }

    func delete(id: String) {
        guard let memo = memo(id: id) else { return }
        try? fileManager.removeItem(at: audioURL(for: memo))
        memos.removeAll { $0.id == id }
        save()
    }

    func addFolder(_ raw: String) {
        guard let name = FolderCatalog.sanitized(raw) else { return }
        if !folders.contains(name) {
            folders.append(name)
            save()
        }
    }

    func documentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func audioURL(for memo: Memo) -> URL {
        documentsDirectory().appendingPathComponent(memo.audioFileName)
    }

    func newAudioURL(ext: String) -> (name: String, url: URL) {
        let name = "memo-\(UUID().uuidString).\(ext)"
        return (name, documentsDirectory().appendingPathComponent(name))
    }
}

/// Named folders. Proof: FolderStore.
struct FolderStore {
    func load(store: LocalStore) -> [String] {
        let saved = store.load([String].self, forKey: MemoLibrary.foldersKey) ?? []
        var out = FolderCatalog.defaults
        for name in saved where !out.contains(name) {
            out.append(name)
        }
        return out
    }

    func save(_ folders: [String], store: LocalStore) {
        store.save(folders, forKey: MemoLibrary.foldersKey)
    }
}
