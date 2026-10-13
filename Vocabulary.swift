import Foundation

struct Vocabulary: Identifiable, Codable, Hashable {
    let id: String
    let kanji: String
    let kana: String
    let romaji: String
    let meaningID: String
    let partOfSpeech: String
    let jlpt: String
    let exampleJP: String
    let exampleKana: String
    let exampleID: String
    var isFavorite: Bool = false
    var isLearned: Bool = false

    var displayWord: String { kanji.isEmpty ? kana : kanji }
}

enum WidgetInterval: String, CaseIterable, Identifiable {
    case thirtyMinutes = "30 menit"
    case oneHour = "1 jam"
    case daily = "Harian"

    var id: String { rawValue }

    var minutes: Int {
        switch self {
        case .thirtyMinutes: return 30
        case .oneHour: return 60
        case .daily: return 1440
        }
    }
}
