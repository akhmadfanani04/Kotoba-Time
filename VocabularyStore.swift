import Foundation
import SwiftUI
import WidgetKit

@MainActor
final class VocabularyStore: ObservableObject {
    // Replace this with the App Group identifier configured in both targets.
    static let appGroupID = "group.com.yourname.KotobaTime"
    private let sharedDefaults = UserDefaults(suiteName: appGroupID)

    @Published private(set) var words: [Vocabulary] = []
    @Published var selectedJLPT = "Semua"
    @Published var searchText = ""
    @Published var interval: WidgetInterval = .thirtyMinutes {
        didSet {
            sharedDefaults?.set(interval.rawValue, forKey: "widgetInterval")
            refreshWidgetWord()
        }
    }

    private let jlptLevels = ["N5", "N4", "N3", "N2", "N1"]

    init() {
        loadSeed()
        if let saved = sharedDefaults?.string(forKey: "widgetInterval"),
           let interval = WidgetInterval(rawValue: saved) {
            self.interval = interval
        }
        refreshWidgetWord()
    }

    var filteredWords: [Vocabulary] {
        words.filter { word in
            let levelMatches = selectedJLPT == "Semua" || word.jlpt == selectedJLPT
            let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let searchMatches = q.isEmpty ||
                word.kanji.localizedCaseInsensitiveContains(q) ||
                word.kana.localizedCaseInsensitiveContains(q) ||
                word.romaji.localizedCaseInsensitiveContains(q) ||
                word.meaningID.localizedCaseInsensitiveContains(q)
            return levelMatches && searchMatches
        }
    }

    var learnedCount: Int { words.filter(\.isLearned).count }
    var favoriteCount: Int { words.filter(\.isFavorite).count }

    func toggleFavorite(_ word: Vocabulary) {
        guard let index = words.firstIndex(where: { $0.id == word.id }) else { return }
        words[index].isFavorite.toggle()
        saveWords()
    }

    func toggleLearned(_ word: Vocabulary) {
        guard let index = words.firstIndex(where: { $0.id == word.id }) else { return }
        words[index].isLearned.toggle()
        saveWords()
    }

    func refreshWidgetWord() {
        guard !words.isEmpty else { return }
        let eligible = selectedJLPT == "Semua" ? words : words.filter { $0.jlpt == selectedJLPT }
        let list = eligible.isEmpty ? words : eligible
        let intervalSeconds = TimeInterval(interval.minutes * 60)
        let slot = Int(Date().timeIntervalSince1970 / intervalSeconds)
        let word = list[abs(slot) % list.count]
        guard let data = try? JSONEncoder().encode(word) else { return }
        sharedDefaults?.set(data, forKey: "currentWidgetVocabulary")
        sharedDefaults?.set(interval.rawValue, forKey: "widgetInterval")
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func loadSeed() {
        if let saved = sharedDefaults?.data(forKey: "vocabularyProgress"),
           let decoded = try? JSONDecoder().decode([Vocabulary].self, from: saved) {
            words = decoded
            return
        }
        guard let url = Bundle.main.url(forResource: "kotoba_seed", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Vocabulary].self, from: data) else {
            words = []
            return
        }
        words = decoded
    }

    private func saveWords() {
        if let data = try? JSONEncoder().encode(words) {
            sharedDefaults?.set(data, forKey: "vocabularyProgress")
        }
        refreshWidgetWord()
    }
}
