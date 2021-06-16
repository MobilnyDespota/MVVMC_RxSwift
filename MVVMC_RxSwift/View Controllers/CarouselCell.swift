import Foundation
import UIKit
import RxSwift
import RxCocoa
import Swinject
import RxFlow

class CarouselCell: UITableViewCell {
    static let identifier = "CarouselCell"
    
    private var disposeBag = DisposeBag()
    
    private let viewModel = CarouselCellViewModel()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.backgroundColor = .backgroundGrey
        collectionView.register(PosterCollectionCell.self, forCellWithReuseIdentifier: PosterCollectionCell.identifier)
        return collectionView
    }()
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func bind() {
        viewModel.movies
            .bind(to: collectionView.rx.items(cellIdentifier: PosterCollectionCell.identifier, cellType: PosterCollectionCell.self)) { indexPath, movie, cell in
                cell.configure(with: movie.posterPath ?? "")
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Movie.self)
            .subscribe(onNext: { [unowned self] movie in
                self.viewModel.selected(item: movie)
            })
            .disposed(by: disposeBag)
    }
    
    func configure(with movies: [Movie], and steps: PublishRelay<Step>) {
        viewModel.setup(with: movies, and: steps)
        bind()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    let cellWidthConstant: CGFloat = 106
    let cellHeightConstant: CGFloat = 160

    
    private func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(
            width: cellWidthConstant,
            height: cellHeightConstant)
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return layout
    }
}

class CarouselCellViewModel: Stepper {
    var steps = PublishRelay<Step>()
    let disposeBag = DisposeBag()
    let moveService = Container.sharedContainer.resolve(MovieService.self)
    
    let movies = BehaviorRelay<[Movie]>(value: [])
    
    func setup(with movies: [Movie], and steps: PublishRelay<Step>) {
        self.movies.accept(movies)
        self.steps = steps
    }
    
    func selected(item: Movie) {
        steps.accept(AppStep.details(movie: item))
    }
}
