import SwiftUI
import UniformTypeIdentifiers

struct ModFile: Identifiable, Codable {
    var id = UUID()
    let name: String
    let storedName: String
    let dateAdded: Date
}

@MainActor
final class ModLibrary: ObservableObject {
    @Published private(set) var files: [ModFile] = []
    private var folder: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImportedMods", isDirectory: true)
    }
    private var index: URL { folder.appendingPathComponent("index.json") }
    init() { load() }
    func importFile(_ source: URL) throws {
        let access = source.startAccessingSecurityScopedResource()
        defer { if access { source.stopAccessingSecurityScopedResource() } }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let stored = UUID().uuidString + "_" + source.lastPathComponent
        try FileManager.default.copyItem(at: source, to: folder.appendingPathComponent(stored))
        files.insert(ModFile(name: source.lastPathComponent, storedName: stored, dateAdded: .now), at: 0)
        save()
    }
    func delete(_ item: ModFile) {
        try? FileManager.default.removeItem(at: folder.appendingPathComponent(item.storedName))
        files.removeAll { $0.id == item.id }; save()
    }
    private func load() {
        guard let data = try? Data(contentsOf: index),
              let value = try? JSONDecoder().decode([ModFile].self, from: data) else { return }
        files = value
    }
    private func save() {
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try JSONEncoder().encode(files).write(to: index, options: .atomic)
        } catch { print("Save failed: \\(error)") }
    }
}

struct ContentView: View {
    @StateObject private var library = ModLibrary()
    @State private var importing = false
    @State private var errorText: String?
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.04, green: 0.06, blue: 0.12), Color(red: 0.10, green: 0.13, blue: 0.23)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("ROV").font(.caption.bold()).tracking(4).foregroundStyle(.cyan)
                            Text("MOD MENU").font(.system(size: 34, weight: .heavy, design: .rounded)).foregroundStyle(.white)
                            Text("จัดการไฟล์ส่วนตัวบน iPhone").foregroundStyle(.white.opacity(0.7))
                        }
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("HERO PRESET").font(.caption.bold()).tracking(2).foregroundStyle(.cyan)
                                    Text("NAKROTH").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
                                    Text("Racing concept").foregroundStyle(.white.opacity(0.7))
                                }
                                Spacer()
                                Image(systemName: "bolt.fill").font(.system(size: 42)).foregroundStyle(.cyan)
                            }
                            Text("ภาพคอนเซปต์เท่านั้น ไม่ใช่สกินทางการ").font(.footnote).foregroundStyle(.white.opacity(0.65))
                            Button { importing = true } label: {
                                Label("นำเข้าไฟล์มอด", systemImage: "square.and.arrow.down").font(.headline)
                                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                                    .background(.cyan, in: RoundedRectangle(cornerRadius: 14)).foregroundStyle(.black)
                            }
                        }.padding(20).background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 22))
                        HStack {
                            Text("คลังไฟล์").font(.title2.bold()).foregroundStyle(.white)
                            Spacer()
                            Text("\\(library.files.count) ไฟล์").foregroundStyle(.cyan)
                        }
                        if library.files.isEmpty {
                            Text("ยังไม่มีไฟล์ — นำเข้าไฟล์จากแอป Files เพื่อเก็บไว้ในแอปนี้").foregroundStyle(.white.opacity(0.65)).padding(.vertical, 16)
                        } else {
                            ForEach(library.files) { item in
                                HStack {
                                    Image(systemName: "doc.zipper").foregroundStyle(.cyan)
                                    VStack(alignment: .leading) {
                                        Text(item.name).foregroundStyle(.white).lineLimit(1)
                                        Text(item.dateAdded.formatted()).font(.caption).foregroundStyle(.white.opacity(0.55))
                                    }
                                    Spacer()
                                    Button(role: .destructive) { library.delete(item) } label: { Image(systemName: "trash") }
                                }.padding(12).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        Text("แอปนี้เก็บและจัดการไฟล์เท่านั้น ไม่แก้ไขหรือติดตั้งไฟล์เข้าเกม ROV").font(.footnote).foregroundStyle(.white.opacity(0.55))
                    }.padding(20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fileImporter(isPresented: $importing, allowedContentTypes: [.zip, .data, .item]) { result in
                do { if let url = try result.get().first { try library.importFile(url) } }
                catch { errorText = error.localizedDescription }
            }
            .alert("นำเข้าไฟล์ไม่สำเร็จ", isPresented: Binding(get: { errorText != nil }, set: { if !$0 { errorText = nil } })) {
                Button("ตกลง", role: .cancel) { errorText = nil }
            } message: { Text(errorText ?? "") }
        }.preferredColorScheme(.dark)
    }
}
