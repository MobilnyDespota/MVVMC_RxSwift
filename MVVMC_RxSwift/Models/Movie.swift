import Foundation
import ObjectMapper

struct Movie: Mappable {
    private(set) var id: Int?
    private(set) var posterPath: String?
    private(set) var title: String?
    private(set) var rating: Double?
    private(set) var duration: Int?
    private(set) var releaseDate: Date?
    private(set) var overview: String?
    private(set) var genres: [Genre]?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        posterPath <- map["poster_path"]
        title <- map["title"]
        rating <- map["vote_average"]
        duration <- map["runtime"]
        releaseDate <- (map["release_date"], DateTransform())
        overview <- map["overview"]
        genres <- map["genres"]
    }
}

struct DateTransform: TransformType {
    typealias Object = Date
    typealias JSON = String

    func transformFromJSON(_ value: Any?) -> Date? {
        if let value = value as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: value)
        }
        return nil
    }

    func transformToJSON(_ value: Date?) -> String? {
        if let value = value {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: value)
        }
        return nil
    }
}
