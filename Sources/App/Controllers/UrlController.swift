import Vapor
import HTTP

final class UrlController: ResourceRepresentable {
    let view: ViewRenderer
    let host: String
    init(_ view: ViewRenderer, hostname: String, port: Int) {
        self.view = view
        switch port {
        case 80:
            self.host = "http://\(hostname)/"
        case 443:
            self.host = "https://\(hostname)/"
        default:
            self.host = "http://\(hostname):\(port)/"
        }
    }

    /// When consumers call 'POST' on '/urls' with valid JSON
    /// create and save the Url
    func create(_ req: Request) throws -> ResponseRepresentable {
        var longUrl = req.data["long"]!.string!
        if !longUrl.starts(with: "http://") || !longUrl.starts(with: "https://") {
            longUrl = "http://\(longUrl)"
        }

        if let url = try Url.makeQuery().filter("long", longUrl).first() {
            return try view.make("show", [
                "shortUrl": "\(host)\(url.short)",
                "longUrl": url.long
            ], for: req)
        }
        
        let newUrl = Url(long: longUrl)
        try newUrl.save()

        return try view.make("show", [
            "shortUrl": "\(host)\(newUrl.short)",
            "longUrl": newUrl.long
        ], for: req)
    }

    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/urls/13rd88' we should show that specific url
    func show(_ req: Request, url: Url) throws -> ResponseRepresentable {
        return Response(redirect: url.long)
    }

    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this 
    /// implementation
    func makeResource() -> Resource<Url> {
        return Resource(
            store: create,
            show: show
        )
    }
}

extension Request {
    /// Create a url from the JSON body
    /// return BadRequest error if invalid 
    /// or no JSON
    func url() throws -> Url {
        guard let json = json else { throw Abort.badRequest }
        return try Url(json: json)
    }
}