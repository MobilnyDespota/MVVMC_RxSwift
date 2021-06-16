import Foundation
import RxSwift
import RxCocoa

class MovieDetailsViewModel {
    private let disposeBag = DisposeBag()
    private let movieService: MovieService
    
    private let movie: BehaviorRelay<Movie>
    private lazy var movieDetails: Observable<Movie> = {
        movie.asObservable()
            .flatMap { [weak self] movie -> Observable<Movie> in
                guard let self = self, let id = movie.id else { return .empty() }
                return self.movieService.getMovieDetails(id: id).share()
            }
    }()
    
    lazy var image: Observable<UIImage> = {
        movie.asObservable()
            .flatMap { [weak self] movie -> Observable<UIImage> in
                guard let self = self, let path = movie.posterPath else { return .empty() }
                return self.movieService.getPoster(path: path)
            }
    }()
    let title: Observable<String?>
    lazy var duration: Observable<String?> = {
        movieDetails
            .map { movie in
                guard let duration = movie.duration else { return "" }
                let hours = duration / 60
                let minutes = duration % 60
                return String(hours) + "h " + String(minutes) + "m"
            }
    }()
    let releaseDate: Observable<String?>
    let overview: Observable<String?>
    lazy var genres: Observable<[String]> = {
        movieDetails
            .map({ movie -> [String] in
                guard let genres = movie.genres else { return [] }
                return genres.map { $0.name ?? "" }
            })
    }()
    
    init(movieService: MovieService, movie: Movie) {
        self.movieService = movieService
        self.movie = BehaviorRelay(value: movie)
        
        title = self.movie.asObservable().map { $0.title }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        releaseDate = self.movie.asObservable().map { movie in
            guard let date = movie.releaseDate else { return "" }
            return dateFormatter.string(from: date)
        }
        
        overview = self.movie.asObservable().map { $0.overview }
    }
}
