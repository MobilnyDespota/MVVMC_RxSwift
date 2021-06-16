import Foundation
import ObjectMapper

struct PageResponse<T: Mappable>: Mappable {
    private(set) var page: Int?
    private(set) var results: [T]?
    private(set) var totalResults: Int?
    private(set) var totalPages: Int?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        page <- map["page"]
        results <- map["results"]
        totalResults <- map["total_results"]
        totalPages <- map["total_pages"]
    }
}
