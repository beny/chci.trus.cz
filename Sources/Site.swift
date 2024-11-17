import Foundation
import Ignite

@main
struct IgniteWebsite {
    static func main() async {
        let site = ExampleSite()

        do {
            try await site.publish()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ExampleSite: Site {
    var name = "chci"
    var url = URL(string: "https://chci.trus.cz")!
    var builtInIconsEnabled = true

    var author = "Ondra Beneš"

    var favicon = URL(string: "/images/favicon.ico")

    var homePage = Home()
    var theme = MyTheme()
}


