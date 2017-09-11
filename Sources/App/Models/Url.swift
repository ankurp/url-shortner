import Vapor
import FluentProvider
import HTTP

let HashId = Hashids(salt: "TpLQdIQYiYFiIflBsyTzrA==")

final class Url: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The long of the url
    var long: String
    
    /// The column names for `id` and `long` in the database
    static let idKey = "id"
    static let longKey = "long"
    
    var short: String {
        get {
            return HashId.encode(id!.int!)!
        }
    }

    /// Creates a new URL
    init(long: String) {
        self.long = long
    }

    // MARK: Fluent Serialization

    /// Initializes the URL from the
    /// database row
    init(row: Row) throws {
        long = try row.get(Url.longKey)
    }

    // Serializes the URL to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Url.longKey, long)
        return row
    }
}

extension Url {
    // returns the found model for the resolved url parameter
    public static func make(for parameter: String) throws -> Self {
        let id = Identifier(HashId.decode(parameter).first!)
        guard let found = try find(id) else {
            throw Abort(.notFound, reason: "No \(Url.self) with that identifier was found.")
        }
        return found
    }
}

// MARK: Fluent Preparation

extension Url: Preparation {
    /// Prepares a table/collection in the database
    /// for storing URLs
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Url.longKey)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new URL (POST /urls)
//     - Fetching a url (GET /urls, GET /urls/:id)
//
extension Url: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            long: json.get(Url.longKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("short", short)
        try json.set(Url.longKey, long)
        return json
    }
}

// MARK: HTTP

// This allows URL models to be returned
// directly in route closures
extension Url: ResponseRepresentable { }
