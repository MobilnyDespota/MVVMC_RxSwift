import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import TMDB

protocol MovieService {
    func getNowPlaying() -> Observable<PageResponse<Movie>>
    func getPopular(page: Int) -> Observable<PageResponse<Movie>>
    func getMovieDetails(id: Int) -> Observable<Movie>
    func getPoster(path: String) -> Observable<UIImage>
}

class MovieServiceManager: MovieService {
    let apiKey = Api.Key
    let baseUrl = "https://api.themoviedb.org/3"
    let imageBaseUrl = "https://image.tmdb.org/t/p/w154"
    
    let session: Alamofire.Session
    
    init(session: Alamofire.Session) {
        self.session = session
    }
    
    func getNowPlaying() -> Observable<PageResponse<Movie>> {
        let params = [
            "api_key": apiKey
        ]
        return session.rx.request(.get, baseUrl + "/movie/now_playing", parameters: params).mappedJSON()
    }
    
    func getPopular(page: Int) -> Observable<PageResponse<Movie>> {
        let params = [
            "api_key": apiKey,
            "page": String(page)
        ]
        return session.rx.request(.get, baseUrl + "/movie/popular", parameters: params).mappedJSON()
    }
    
    func getMovieDetails(id: Int) -> Observable<Movie> {
        let params = [
            "api_key": apiKey
        ]
        return session.rx.request(.get, baseUrl + "/movie/" + String(id), parameters: params).mappedJSON()
    }
    
    func getPoster(path: String) -> Observable<UIImage> {
        session.request(imageBaseUrl + path, method: .get).cacheResponse(using: ResponseCacher(behavior: .cache)).rx.image()
    }
}
