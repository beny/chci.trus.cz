import Foundation
import Ignite

/// Samostatná stránka s jediným seznamem, např. `/vita`.
struct WishlistPage: StaticPage {
    let person: Person

    var title: String { "chci - \(person.name)" }
    var path: String { "/\(person.rawValue)" }

    func body(context: PublishingContext) async -> [BlockElement] {
        await Wishlist(person: person).cards(context: context)
    }
}
