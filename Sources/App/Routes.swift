import Vapor

extension Droplet {
    func setupRoutes() throws {
        get { _ in
            return try self.view.make("new")
        }

        let host = config["server", "host"]?.string ?? "localhost"
        let port = config["server", "port"]?.int ?? 8080

        resource("", UrlController(view, hostname: host, port: port))
    }
}
