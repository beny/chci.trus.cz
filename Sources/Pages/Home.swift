import Foundation
import OpenGraph
import Ignite
import Yams

struct Home: StaticPage {
    var title = "chci"

    /// Položka tak, jak ji zapisuješ v `links.yaml`.
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

    func body(context: PublishingContext) async -> [BlockElement] {
        let items = await fetchItems(context: context)
        Section {
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
        let entries = decodeEntries(context: context)
        var items: [Item] = []

        for entry in entries {
            items.append(await resolve(entry: entry))
        }

        return items
    }

    /// Načte a dekóduje `links.yaml` ze složky Resources.
    private func decodeEntries(context: PublishingContext) -> [LinkEntry] {
        guard let data = context.data(forResource: "links.yaml") else {
            print("Failed to locate links.yaml in Resources folder.")
            return []
        }
        do {
            return try YAMLDecoder().decode([LinkEntry].self, from: data)
        } catch {
            print("Failed to decode links.yaml: \(error)")
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
