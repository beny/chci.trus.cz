import Foundation
import Ignite

/// Všechny seznamy najednou, přepínané segment controlem (Bootstrap pills).
/// `role` a `aria-selected` doplní Bootstrap JS při načtení.
struct Home: StaticPage {
    var title = "chci"

    func body(context: PublishingContext) async -> [BlockElement] {
        let allCards = await fetchCards(context: context)

        Group {
            for person in Person.allCases {
                Link(person.name, target: "#\(person.rawValue)")
                    .class("nav-link", person == .default ? "active" : nil)
                    .data("bs-toggle", "pill")
                    .aria("controls", person.rawValue)
            }
        }
        .class("nav", "segmented")

        Group {
            for (person, cards) in zip(Person.allCases, allCards) {
                let isActive = person == .default

                Group { cards }
                    .class("tab-pane", "fade", isActive ? "show" : nil, isActive ? "active" : nil)
                    .id(person.rawValue)
            }
        }
        .class("tab-content")
    }

    /// Mimo builder - vnořené `Group { }` buildery jsou synchronní.
    private func fetchCards(context: PublishingContext) async -> [any BlockElement] {
        var allCards: [any BlockElement] = []
        for person in Person.allCases {
            allCards.append(await Wishlist(person: person).cards(context: context))
        }
        return allCards
    }
}
