import UIKit
import RxSwift
import RxCocoa
import RxOptional
import Swinject

class MovieCell: UITableViewCell {
    static let identifier = "MovieCell"
    
    private var disposeBag = DisposeBag()
    
    var viewModel = MovieCellViewModel()
    
    let poster: UIImageView = {
        let image = UIImageView()
        image.layer.borderWidth = 1.0
        image.layer.borderColor = UIColor.borderGrey.cgColor
        return image
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.applyStyle(.white, .standard, .bold)
        return label
    }()
    
    let releaseDate: UILabel = {
        let label = UILabel()
        label.applyStyle(.white, .small, .regular)
        return label
    }()
    
    let duration: UILabel = {
        let label = UILabel()
        label.applyStyle(.white, .small, .regular)
        return label
    }()
    
    let rating = RatingView()
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        buildUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildUI() {
        contentView.backgroundColor = .backgroundGrey
        
        let separator = UIView(forAutoLayout: ())
        separator.backgroundColor = .sectionGrey
        contentView.addSubview(separator)
        separator.autoPinEdge(toSuperviewEdge: .left)
        separator.autoPinEdge(toSuperviewEdge: .bottom)
        separator.autoPinEdge(toSuperviewEdge: .right)
        separator.autoSetDimension(.height, toSize: 5)
        
        contentView.addSubview(poster)
        poster.autoPinEdge(toSuperviewEdge: .left, withInset: 25)
        poster.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        poster.autoPinEdge(.bottom, to: .top, of: separator, withOffset: -7)
        poster.autoSetDimensions(to: CGSize(width: 49, height: 73))
        
        contentView.addSubview(rating)
        rating.autoAlignAxis(toSuperviewAxis: .horizontal)
        rating.autoPinEdge(toSuperviewEdge: .right, withInset: 25)
        rating.autoSetDimensions(to: CGSize(width: 40, height: 40))
        
        contentView.addSubview(title)
        title.autoPinEdge(.left, to: .right, of: poster, withOffset: 18)
        title.autoPinEdge(.right, to: .left, of: rating, withOffset: -18)
        title.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        
        contentView.addSubview(releaseDate)
        releaseDate.autoPinEdge(.left, to: .right, of: poster, withOffset: 18)
        releaseDate.autoPinEdge(.top, to: .bottom, of: title, withOffset: 7)
        
        contentView.addSubview(duration)
        duration.autoPinEdge(.left, to: .right, of: poster, withOffset: 18)
        duration.autoPinEdge(.top, to: .bottom, of: releaseDate, withOffset: 2)
    }
    
    private func bind() {
        viewModel.image
            .bind(to: poster.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.title
            .bind(to: title.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.releaseDate
            .bind(to: releaseDate.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.duration
            .bind(to: duration.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.rating
            .filterNil()
            .map { CGFloat($0/10) }
            .bind(to: rating.rx.rating)
            .disposed(by: disposeBag)
    }
    
    func configure(with movie: Movie) {
        viewModel.setup(movie: movie)
        bind()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        poster.image = nil
        title.text = nil
        disposeBag = DisposeBag()
    }
}

class MovieCellViewModel {
    let disposeBag = DisposeBag()
    let movieService = Container.sharedContainer.resolve(MovieService.self)!
    
    private let movie = BehaviorRelay<Movie?>(value: nil)
    
    lazy var image: Observable<UIImage> = {
        movie.asObservable()
            .filterNil()
            .flatMap { [weak self] movie -> Observable<UIImage> in
                guard let self = self, let path = movie.posterPath else { return .empty() }
                return self.movieService.getPoster(path: path)
            }
    }()
    lazy var duration: Observable<String?> = {
        movie.asObservable()
            .filterNil()
            .flatMap { [weak self] movie -> Observable<Movie> in
                guard let self = self, let id = movie.id else { return .empty() }
                return self.movieService.getMovieDetails(id: id)
            }
            .map { movie in
                guard let duration = movie.duration else { return "" }
                let hours = duration / 60
                let minutes = duration % 60
                return String(hours) + "h " + String(minutes) + "m"
            }
    }()
    let title: Observable<String?>
    let releaseDate: Observable<String?>
    let rating: Observable<Double?>
    
    init() {
        
        title = movie.asObservable().map { $0?.title }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        releaseDate = movie.asObservable().map { movie in
            guard let date = movie?.releaseDate else { return "" }
            return dateFormatter.string(from: date)
        }
        rating = movie.asObservable().map { $0?.rating }
    }
    
    func setup(movie: Movie) {
        self.movie.accept(movie)
    }
}
