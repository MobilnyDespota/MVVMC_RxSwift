import Foundation
import RxSwift
import RxAlamofire
import Alamofire
import ObjectMapper

extension Reactive where Base: DataRequest {
    func mappedJSON<T: BaseMappable>(context: MapContext? = nil, shouldIncludeNilValues: Bool = false) -> Observable<T> {
        json()
        .flatMap { json -> Observable<T> in
            if let object = Mapper<T>(context: context, shouldIncludeNilValues: shouldIncludeNilValues).map(JSONObject: json) {
                return .just(object)
            }
            throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "ObjectMapper can't mapping"])
        }
    }

    func mappedJSON<T: BaseMappable>(context: MapContext? = nil, shouldIncludeNilValues: Bool = false) -> Observable<[T]> {
        json()
        .flatMap { json -> Observable<[T]> in
            if let object = Mapper<T>(context: context, shouldIncludeNilValues: shouldIncludeNilValues).mapArray(JSONObject: json) {
                return .just(object)
            }
            throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "ObjectMapper can't mapping"])
        }
    }
    
    func image() -> Observable<UIImage> {
        data()
        .flatMap { data -> Observable<UIImage> in
            guard let image = UIImage(data: data) else { return .empty() }
            return .just(image)
        }
    }
}

extension Observable where Element == DataRequest {
    func mappedJSON<T: BaseMappable>(context: MapContext? = nil, shouldIncludeNilValues: Bool = false) -> Observable<T> {
        self.flatMap { $0.rx.mappedJSON(context: context, shouldIncludeNilValues: shouldIncludeNilValues) }
    }

    func mappedJSON<T: BaseMappable>(context: MapContext? = nil, shouldIncludeNilValues: Bool = false) -> Observable<[T]> {
        self.flatMap { $0.rx.mappedJSON(context: context, shouldIncludeNilValues: shouldIncludeNilValues) }
    }
    
    func image() -> Observable<UIImage> {
        self.flatMap { $0.rx.image() }
    }
}
