import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: VocabularyStore
    private let levels = ["Semua", "N5", "N4", "N3", "N2", "N1"]

    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("今日のことば")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Kotoba Time")
                                .font(.largeTitle.bold())
                            Text("Sedikit demi sedikit, setiap hari.")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))

                        HStack(spacing: 12) {
                            statCard(title: "Kosakata", value: "\(store.words.count)")
                            statCard(title: "Dipelajari", value: "\(store.learnedCount)")
                            statCard(title: "Favorit", value: "\(store.favoriteCount)")
                        }

                        Picker("Level JLPT", selection: $store.selectedJLPT) {
                            ForEach(levels, id: \.self) { level in
                                Text(level).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)

                        HStack {
                            Text("Kosakata")
                                .font(.title2.bold())
                            Spacer()
                            Text("\(store.filteredWords.count) kata")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        ForEach(store.filteredWords) { word in
                            NavigationLink {
                                VocabularyDetailView(word: word)
                            } label: {
                                VocabularyRow(word: word)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Beranda", systemImage: "house") }

            NavigationStack {
                List {
                    Section("Widget") {
                        Picker("Interval pergantian", selection: $store.interval) {
                            ForEach(WidgetInterval.allCases) { interval in
                                Text(interval.rawValue).tag(interval)
                            }
                        }
                    }
                    Section("Tentang") {
                        LabeledContent("Level tersedia", value: "N5–N1")
                        LabeledContent("Mode", value: "Offline")
                        Text("WidgetKit dijadwalkan oleh iOS. Pembaruan tidak dijamin tepat pada menit yang dipilih.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .navigationTitle("Pengaturan")
            }
            .tabItem { Label("Pengaturan", systemImage: "gearshape") }
        }
        .searchable(text: $store.searchText, prompt: "Cari kanji, kana, romaji, atau arti")
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

struct VocabularyRow: View {
    let word: Vocabulary

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.displayWord).font(.title2.bold())
                Text(word.kana).font(.subheadline).foregroundStyle(.secondary)
                Text(word.meaningID).font(.body)
            }
            Spacer()
            Text(word.jlpt)
                .font(.caption.bold())
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Color.red.opacity(0.12), in: Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
    }
}

struct VocabularyDetailView: View {
    @EnvironmentObject private var store: VocabularyStore
    let word: Vocabulary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(word.jlpt).font(.headline).foregroundStyle(.red)
                Text(word.displayWord).font(.system(size: 54, weight: .bold))
                Text(word.kana).font(.title2)
                Text(word.romaji).foregroundStyle(.secondary)
                Text(word.meaningID).font(.title3.bold())
                Divider()
                Text("Contoh kalimat").font(.headline)
                Text(word.exampleJP).font(.title3)
                Text(word.exampleKana).foregroundStyle(.secondary)
                Text(word.exampleID)
                HStack {
                    Button {
                        store.toggleFavorite(word)
                    } label: {
                        Label("Favorit", systemImage: "star")
                    }
                    .buttonStyle(.bordered)
                    Button {
                        store.toggleLearned(word)
                    } label: {
                        Label("Tandai dipelajari", systemImage: "checkmark.circle")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Detail Kotoba")
        .navigationBarTitleDisplayMode(.inline)
    }
}
