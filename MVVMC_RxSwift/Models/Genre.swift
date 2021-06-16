import Foundation
import ObjectMapper

struct Genre: Mappable {
    private(set) var id: Int?
    private(set) var name: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
