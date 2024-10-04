import Foundation
import OpenGraph
import Ignite

struct Home: StaticPage {
    var title = "chci"

    private struct Item {
        let title: String?
        let description: String?
        let imageURL: String?
        let url: String?
    }

    func body(context: PublishingContext) async -> [BlockElement] {
        let items = await fetchItems(context: context)
        Section {
            for item in items {
                Card(imageName: item.imageURL) {
                    Text(item.title ?? "")
                        .font(.title3)
                    Text(item.description ?? "")

                    Link("Detail", target: item.url ?? "")
                        .linkStyle(.button)
                }
                .frame(minWidth: 300, maxWidth: 390)
            }
        }
        .padding()
    }

    private func fetchItems(context: PublishingContext) async -> [Item] {
        let links = context.decode(resource: "links.json", as: [String].self) ?? []
        var items: [Item] = []
        do {
            for link in links {
                guard let url = URL(string: link) else { continue }
                let openGraph = try await OpenGraph.fetch(url: url)
                dump(openGraph)
                items.append(
                    Item(
                        title: openGraph[.title],
                        description: openGraph[.description],
                        imageURL: openGraph[.image],
                        url: openGraph[.url]
                    )
                )
            }
        } catch {
            print(error.localizedDescription)
        }

        return items
    }
}
