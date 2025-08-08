import Foundation
import Ignite

struct MyTheme: Theme {
    func render(page: Page, context: PublishingContext) -> HTML {
        HTML {
            Head(for: page, in: context) {
                MetaLink(href: "/main.css", rel: "stylesheet")
            }

            Body {
                page.body

                IgniteFooter()
            }
        }
    }
}
