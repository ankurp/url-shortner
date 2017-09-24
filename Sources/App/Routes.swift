import Vapor

extension Droplet {
    func setupRoutes() throws {
        get { _ in
            return try self.view.make("new")
        }

        resource("", UrlController(view))
    }
}
