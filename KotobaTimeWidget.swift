import WidgetKit
import SwiftUI

// Add this file to the Widget Extension target.
// Keep Vocabulary.swift included in both app and widget targets.

struct KotobaWidgetEntry: TimelineEntry {
    let date: Date
    let vocabulary: Vocabulary
}

struct KotobaWidgetProvider: TimelineProvider {
    private let appGroupID = "group.com.yourname.KotobaTime"

    func placeholder(in context: Context) -> KotobaWidgetEntry {
        KotobaWidgetEntry(date: .now, vocabulary: sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (KotobaWidgetEntry) -> Void) {
        completion(KotobaWidgetEntry(date: .now, vocabulary: loadVocabulary() ?? sample))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KotobaWidgetEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: appGroupID)
        let intervalString = defaults?.string(forKey: "widgetInterval") ?? WidgetInterval.thirtyMinutes.rawValue
        let interval = WidgetInterval(rawValue: intervalString) ?? .thirtyMinutes
        let seconds = TimeInterval(interval.minutes * 60)
        let now = Date()
        let vocabulary = loadVocabulary() ?? sample

        // Request a refresh at the next interval boundary. iOS may defer this refresh.
        let nextBoundary = Date(timeIntervalSince1970:
            (floor(now.timeIntervalSince1970 / seconds) + 1) * seconds)
        let entry = KotobaWidgetEntry(date: now, vocabulary: vocabulary)
        completion(Timeline(entries: [entry], policy: .after(nextBoundary)))
    }

    private func loadVocabulary() -> Vocabulary? {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let data = defaults?.data(forKey: "currentWidgetVocabulary") else { return nil }
        return try? JSONDecoder().decode(Vocabulary.self, from: data)
    }

    private var sample: Vocabulary {
        Vocabulary(
            id: "sample-tab eru",
            kanji: "食べる",
            kana: "たべる",
            romaji: "taberu",
            meaningID: "makan",
            partOfSpeech: "Kata kerja",
            jlpt: "N5",
            exampleJP: "毎日、ご飯を食べます。",
            exampleKana: "まいにち、ごはんをたべます。",
            exampleID: "Saya makan nasi setiap hari."
        )
    }
}

struct KotobaTimeWidgetView: View {
    let entry: KotobaWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("KOTOBA TIME")
                    .font(.caption2.bold())
                    .tracking(1)
                Spacer(minLength: 2)
                Text(entry.vocabulary.jlpt)
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.red.opacity(0.15), in: Capsule())
            }
            Spacer(minLength: 2)
            Text(entry.vocabulary.displayWord)
                .font(.system(size: family == .systemSmall ? 30 : 38, weight: .bold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(entry.vocabulary.kana)
                .font(.subheadline)
                .lineLimit(1)
            Text(entry.vocabulary.meaningID.uppercased())
                .font(.caption.bold())
                .lineLimit(2)
            Spacer(minLength: 2)
            Text("Belajar sedikit setiap hari")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

@main
struct KotobaTimeWidget: Widget {
    let kind = "KotobaTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KotobaWidgetProvider()) { entry in
            KotobaTimeWidgetView(entry: entry)
        }
        .configurationDisplayName("Kotoba Time")
        .description("Kosakata bahasa Jepang di Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline])
    }
}
