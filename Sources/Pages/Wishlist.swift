import Foundation
import OpenGraph
import Ignite
import Yams

/// Čí seznam - každý má vlastní `Resources/<rawValue>.yaml` a stránku `/<rawValue>`.
enum Person: String, CaseIterable {
    case ondra
    case vita

    static let `default` = Person.ondra

    var name: String {
        switch self {
        case .ondra: "Ondra"
        case .vita: "Víťa"
        }
    }

    var resource: String { "\(rawValue).yaml" }
}

struct Wishlist {
    /// Položka tak, jak ji zapisuješ v `<person>.yaml`.
    /// Povinné je jen `url`; ostatní pole jsou volitelný override.
    private struct LinkEntry: Decodable {
        let url: String
        let title: String?
        let description: String?
        let image: String?
    }

    /// Výsledná data pro vykreslení karty (po sloučení override + OpenGraph).
    private struct Item {
        let title: String?
        let description: String?
        let imageURL: String?
        let url: String
    }

    /// Seznam se vykresluje na `/` i na `/<person>` - OpenGraph stačí stáhnout jednou.
    /// Ignite vykresluje stránky postupně, takže stačí obyčejná statická cache.
    private static var cache: [Person: [Item]] = [:]

    let person: Person

    func cards(context: PublishingContext) async -> any BlockElement {
        let items = await fetchItems(context: context)

        if items.isEmpty {
            return Text("Zatím tu nic není.")
                .horizontalAlignment(.center)
                .foregroundStyle(.secondary)
                .margin(.vertical, 40)
        }

        return Section {
            for item in items {
                Card(imageName: item.imageURL) {
                    Text(item.title ?? "")
                        .font(.title3)
                    Text(item.description ?? "")

                    Link("Detail", target: item.url)
                        .linkStyle(.button)
                }
                .frame(minWidth: 300, maxWidth: 390)
            }
        }
        .padding()
    }

    private func fetchItems(context: PublishingContext) async -> [Item] {
        if let cached = Self.cache[person] {
            return cached
        }

        let entries = decodeEntries(context: context)
        var items: [Item] = []

        for entry in entries {
            items.append(await resolve(entry: entry))
        }

        Self.cache[person] = items
        return items
    }

    /// Načte a dekóduje `<person>.yaml` ze složky Resources.
    private func decodeEntries(context: PublishingContext) -> [LinkEntry] {
        guard let data = context.data(forResource: person.resource) else {
            print("Failed to locate \(person.resource) in Resources folder.")
            return []
        }
        do {
            // Soubor jen s komentáři je prázdný dokument -> nil.
            return try YAMLDecoder().decode([LinkEntry]?.self, from: data) ?? []
        } catch {
            print("Failed to decode \(person.resource): \(error)")
            return []
        }
    }

    /// Sloučí ruční override s OpenGraph daty stránky.
    /// Override má vždy přednost; OpenGraph se stahuje jen pro chybějící pole.
    private func resolve(entry: LinkEntry) async -> Item {
        // Když máme všechno ručně, OpenGraph vůbec netaháme.
        if let title = entry.title,
           let description = entry.description,
           let image = entry.image {
            return Item(title: title, description: description, imageURL: image, url: entry.url)
        }

        var openGraph: OpenGraph?
        if let url = URL(string: entry.url) {
            openGraph = try? await OpenGraph.fetch(url: url)
        }

        return Item(
            title: entry.title ?? openGraph?[.title],
            description: entry.description ?? openGraph?[.description],
            imageURL: entry.image ?? openGraph?[.image],
            url: entry.url
        )
    }
}
