import Vapor
import HTTP

final class UrlController: ResourceRepresentable {
    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }

    func render(_ url: Url, forReq: Request) throws -> ResponseRepresentable {
        return try view.make("show", [
            "shortUrl": url.short,
            "longUrl": url.long
        ], for: forReq)
    }

    /// When consumers call 'POST' on '/urls' with valid JSON
    /// create and save the Url
    func create(_ req: Request) throws -> ResponseRepresentable {
        guard let reqLongData = req.data["long"] else { throw Abort.badRequest }
        guard var longUrl = reqLongData.string else { throw Abort.badRequest }

        if !longUrl.hasPrefix("http://") && !longUrl.hasPrefix("https://") {
            longUrl = "http://\(longUrl)"
        }

        if let url = try Url.makeQuery().filter("long", longUrl).first() {
            return try render(url, forReq: req)
        }
        
        let newUrl = Url(long: longUrl)
        try newUrl.save()

        return try render(newUrl, forReq: req)
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
