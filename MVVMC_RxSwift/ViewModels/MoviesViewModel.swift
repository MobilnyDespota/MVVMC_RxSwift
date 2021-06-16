import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import RxFlow

enum SectionItem {
    case carouselItem(movies: [Movie])
    case listItem(movie: Movie)
}

enum TableSection {
    case carousel(items: [SectionItem])
    case list(items: [SectionItem])
}

extension TableSection: SectionModelType {
    typealias Item = SectionItem
    
    var items: [SectionItem] {
        switch self {
        case .carousel(let items):
            return items
        case .list(let items):
            return items
        }
    }
    
    var header: String {
        switch self {
        case .carousel:
            return "Playing now"
        case .list:
            return "Most popular"
        }
    }
    
    init(original: TableSection, items: [SectionItem]) {
        self = original
    }
}

class MoviesViewModel: Stepper {
    var steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()
    private let movieService: MovieService
    
    private let nowPlaying = BehaviorRelay<[Movie]>(value: [])
    private let popular = BehaviorRelay<[Movie]>(value: [])
    
    typealias DataSource = TableSection
    let dataSource: Observable<[DataSource]>
    private let popularNextPage = BehaviorRelay<Int>(value: 1)
    private var isLoading: Bool = false
    private var lastPageLoaded: Bool = false
    
    init(movieService: MovieService) {
        self.movieService = movieService
        let nowPlayingSection = nowPlaying.asObservable()
            .filter({ movies -> Bool in
                movies.count > 0
            })
            .map { movies -> DataSource in
                .carousel(items: [.carouselItem(movies: movies)])
            }
        
        let popularSection = popular.asObservable()
            .filter({ movies -> Bool in
                movies.count > 0
            })
            .map { movies -> DataSource in
                .list(items: movies.map { .listItem(movie: $0) })
            }
        
        dataSource = Observable.combineLatest(nowPlayingSection, popularSection)
            .map { sections -> [DataSource] in
                [sections.0, sections.1]
            }
        
        loadNowPlaying()
        popularNextPage
            .subscribe(onNext: { [weak self] page in
                self?.loadPopular(page: page)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func loadNowPlaying() {
        movieService.getNowPlaying()
            .map { response -> [Movie] in
                response.results ?? []
            }
            .bind(to: nowPlaying)
            .disposed(by: disposeBag)
    }
    
    private func loadPopular(page: Int) {
        isLoading = true
        movieService.getPopular(page: page)
            .do(onNext: { [weak self] response in
                guard let self = self, let total = response.totalPages else { return }
                self.lastPageLoaded = (page == total)
            })
            .map { response -> [Movie] in
                response.results ?? []
            }
            .subscribe(onNext: { [weak self] movies in
                guard let self = self else { return }
                var currentItems = self.popular.value
                currentItems.append(contentsOf: movies)
                self.popular.accept(currentItems)
                self.isLoading = false
            })
            .disposed(by: disposeBag)
    }
    
    func selected(item: Movie) {
        steps.accept(AppStep.details(movie: item))
    }
    
    func loadMoreItems() {
        guard !(isLoading || lastPageLoaded) else { return }
        popularNextPage.accept(popularNextPage.value + 1)
    }
    
    func reloadItems() {
        self.lastPageLoaded = false
        nowPlaying.accept([])
        popular.accept([])
        popularNextPage.accept(1)
        loadNowPlaying()
    }
}
