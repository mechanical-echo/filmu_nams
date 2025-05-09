import WidgetKit
import SwiftUI
import AppIntents

class ImageCache {
    static let shared = ImageCache()
    private var cache: [String: UIImage] = [:]
    
    func getImage(for url: String) -> UIImage? {
        return cache[url]
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache[url] = image
    }
}

struct NetworkImage: View {
    let urlString: String
    @State private var uiImage: UIImage?
    @State private var loadStatus: String = "Init"
    
    var body: some View {
        ZStack {
            Color(white: 0.1, opacity: 1.0)
            
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                VStack(spacing: 2) {
                    Image(systemName: "film")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(loadStatus)
                        .font(.system(size: 6))
                        .foregroundColor(.orange)
                        .lineLimit(1)
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        if let cachedImage = ImageCache.shared.getImage(for: urlString) {
            self.uiImage = cachedImage
            self.loadStatus = "Cached"
            return
        }
        
        guard !urlString.isEmpty else {
            loadStatus = "NoURL"
            return
        }
        
        guard let url = URL(string: urlString) else {
            loadStatus = "BadURL"
            return
        }
        
        loadStatus = "Loading"
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    loadStatus = "Err:\(error.localizedDescription.prefix(5))"
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    loadStatus = "NoResp"
                }
                return
            }
            
            if httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    loadStatus = "HTTP\(httpResponse.statusCode)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    loadStatus = "NoData"
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    loadStatus = "BadImg"
                }
                return
            }
            
            ImageCache.shared.setImage(image, for: urlString)
            
            DispatchQueue.main.async {
                self.uiImage = image
                self.loadStatus = "✓"
            }
        }.resume()
    }
}

struct TicketInfo: Codable {
    let id: String
    let movieTitle: String
    let posterUrl: String
    let date: Int
    let hall: Int
    let seat: String
    let formattedTime: String
    let formattedDate: String
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            tickets: [],
            debugInfo: ""
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let sampleTickets = [
            TicketInfo(
                id: "sample1",
                movieTitle: "Avengers: Endgame",
                posterUrl: "https://image.tmdb.org/t/p/w500/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg",
                date: Int(Date().timeIntervalSince1970 * 1000),
                hall: 1,
                seat: "5-8",
                formattedTime: "19:30",
                formattedDate: "15.05.2025"
            ),
            TicketInfo(
                id: "sample2",
                movieTitle: "The Batman",
                posterUrl: "https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg",
                date: Int(Date().timeIntervalSince1970 * 1000) + 86400000,
                hall: 2,
                seat: "3-4",
                formattedTime: "20:15",
                formattedDate: "16.05.2025"
            )
        ]
        
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            tickets: sampleTickets,
            debugInfo: ""
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var tickets: [TicketInfo] = []
        var debugInfo = "Timeline refresh: \(Date().formatted(date: .abbreviated, time: .standard))"
        
        if let userDefaults = UserDefaults(suiteName: "group.filmuNams") {
            debugInfo += "\nUserDefaults accessed: ✓"
            
            if let ticketsData = userDefaults.string(forKey: "tickets_data") {
                debugInfo += "\nTickets data found: \(ticketsData.prefix(30))..."
                
                let decoder = JSONDecoder()
                if let data = ticketsData.data(using: .utf8) {
                    do {
                        tickets = try decoder.decode([TicketInfo].self, from: data)
                        debugInfo += "\nDecoded \(tickets.count) tickets"
                        
                        // Debug poster URLs
                        for (i, ticket) in tickets.prefix(3).enumerated() {
                            debugInfo += "\nTicket \(i+1) URL: \(ticket.posterUrl.prefix(40))..."
                        }
                    } catch {
                        debugInfo += "\nError decoding tickets: \(error)"
                    }
                } else {
                    debugInfo += "\nCould not convert string to data"
                }
            } else {
                debugInfo += "\nNo tickets_data found"
            }
        } else {
            debugInfo += "\nCould not access UserDefaults"
        }
        
        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            tickets: tickets,
            debugInfo: debugInfo
        )
        
        let nextUpdate = Calendar.current.date(
            byAdding: tickets.isEmpty ? .minute : .hour,
            value: tickets.isEmpty ? 5 : 1,
            to: Date()
        )!
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let tickets: [TicketInfo]
    let debugInfo: String
}

struct AppColors {
    static let background = Color.black
    static let cardBackground = Color(white: 0.05, opacity: 1.0)
    static let cardBorder = Color.white.opacity(0.1)
    static let primaryText = Color.white.opacity(0.9)
    static let secondaryText = Color.white.opacity(0.7)
    static let subtleText = Color.white.opacity(0.5)
    static let accent = Color.red
    static let cardInnerShadow = Color.black.opacity(0.2)
    static let cardOuterGlow = Color.white.opacity(0.05)
}

struct FilmuNamsWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    @State private var showDebug = false
    
    var body: some View {
        ZStack {
            AppColors.background
            
            VStack(alignment: .leading, spacing: 8) {
                if entry.tickets.isEmpty {
                    Spacer()

                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "ticket")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.subtleText)
                            Text("Nav biļešu")
                                .font(.caption)
                                .foregroundColor(AppColors.subtleText)
                        }
                        Spacer()
                    }
                    Spacer()
                } else {
                    HStack(spacing: 8) {
                        ForEach(entry.tickets.prefix(3), id: \.id) { ticket in
                            TicketCard(ticket: ticket)
                        }
                        
                        if entry.tickets.count < 3 {
                            ForEach(0..<(3 - entry.tickets.count), id: \.self) { _ in
                                EmptyTicketCard()
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

struct TicketCard: View {
    var ticket: TicketInfo
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 5)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )
                .shadow(color: AppColors.cardInnerShadow, radius: 2, x: 0, y: 1)
            
            NetworkImage(urlString: ticket.posterUrl)
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: 140)
                .clipped()
                .cornerRadius(5)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(5)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(ticket.movieTitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .shadow(color: Color.black.opacity(0.7), radius: 1, x: 0, y: 1)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "calendar")
                        .font(.system(size: 8))
                        .foregroundColor(Color.white.opacity(0.9))
                    Text(ticket.formattedDate)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.9))
                }
                .shadow(color: Color.black.opacity(0.7), radius: 1, x: 0, y: 1)
                
                HStack(spacing: 2) {
                    Image(systemName: "clock")
                        .font(.system(size: 8))
                        .foregroundColor(Color.white.opacity(0.9))
                    Text(ticket.formattedTime)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.9))
                }
                .shadow(color: Color.black.opacity(0.7), radius: 1, x: 0, y: 1)
                
                HStack(spacing: 2) {
                    Image(systemName: "chair")
                        .font(.system(size: 8))
                        .foregroundColor(Color.white.opacity(0.9))
                    Text("Vieta \(ticket.seat), \(ticket.hall). zāle")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.9))
                        .lineLimit(1)
                }
                .shadow(color: Color.black.opacity(0.7), radius: 1, x: 0, y: 1)
            }
            .padding(8)
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .bottomLeading)
        }
    }
}

struct EmptyTicketCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(AppColors.cardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(AppColors.cardBorder.opacity(0.5), lineWidth: 1)
                )
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(5)
            
            VStack {
                Spacer()
                Image(systemName: "ticket")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.subtleText.opacity(0.3))
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 80)
        }
    }
}

struct FilmuNamsWidget: Widget {
    let kind: String = "FilmuNamsWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            FilmuNamsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Filmu Nams Biļetes")
        .description("Rāda jūsu jaunākās filmu biļetes")
        .contentMarginsDisabled()
    }
}

extension ConfigurationAppIntent {
    fileprivate static var preview: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🎬"
        return intent
    }
}

#Preview("With 3 Tickets", as: .systemMedium) {
    FilmuNamsWidget()
} timeline: {
    let tickets = [
        TicketInfo(
            id: "sample1",
            movieTitle: "Avengers: Endgame",
            posterUrl: "https://image.tmdb.org/t/p/w500/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg",
            date: Int(Date().timeIntervalSince1970 * 1000),
            hall: 1,
            seat: "5-8",
            formattedTime: "19:30",
            formattedDate: "15.05.2025"
        ),
        TicketInfo(
            id: "sample2",
            movieTitle: "The Batman",
            posterUrl: "https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg",
            date: Int(Date().timeIntervalSince1970 * 1000) + 86400000,
            hall: 2,
            seat: "3-4",
            formattedTime: "20:15",
            formattedDate: "16.05.2025"
        ),
        TicketInfo(
            id: "sample3",
            movieTitle: "Dune: Part Two",
            posterUrl: "https://image.tmdb.org/t/p/w500/8b8R8l88Qje9dn9OE8PY05Nxl1X.jpg",
            date: Int(Date().timeIntervalSince1970 * 1000) + 172800000,
            hall: 3,
            seat: "7-12",
            formattedTime: "18:45",
            formattedDate: "17.05.2025"
        )
    ]
    SimpleEntry(
        date: .now,
        configuration: .preview,
        tickets: tickets,
        debugInfo: ""
    )
}

#Preview("With 2 Tickets", as: .systemMedium) {
    FilmuNamsWidget()
} timeline: {
    let tickets = [
        TicketInfo(
            id: "sample1",
            movieTitle: "Avengers: Endgame",
            posterUrl: "https://image.tmdb.org/t/p/w500/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg",
            date: Int(Date().timeIntervalSince1970 * 1000),
            hall: 1,
            seat: "5-8",
            formattedTime: "19:30",
            formattedDate: "15.05.2025"
        ),
        TicketInfo(
            id: "sample2",
            movieTitle: "The Batman",
            posterUrl: "https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg",
            date: Int(Date().timeIntervalSince1970 * 1000) + 86400000,
            hall: 2,
            seat: "3-4",
            formattedTime: "20:15",
            formattedDate: "16.05.2025"
        )
    ]
    SimpleEntry(
        date: .now,
        configuration: .preview,
        tickets: tickets,
        debugInfo: ""
    )
}

#Preview("With 1 Ticket", as: .systemMedium) {
    FilmuNamsWidget()
} timeline: {
    let tickets = [
        TicketInfo(
            id: "sample1",
            movieTitle: "Avengers: Endgame",
            posterUrl: "https://image.tmdb.org/t/p/w500/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg",
            date: Int(Date().timeIntervalSince1970 * 1000),
            hall: 1,
            seat: "5-8",
            formattedTime: "19:30",
            formattedDate: "15.05.2025"
        )
    ]
    SimpleEntry(
        date: .now,
        configuration: .preview,
        tickets: tickets,
        debugInfo: ""
    )
}


#Preview("No tickets", as: .systemMedium) {
    FilmuNamsWidget()
} timeline : {
    SimpleEntry(
        date: .now,
        configuration: .preview,
        tickets: [],
        debugInfo: ""
    )
}
