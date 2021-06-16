import Foundation
import UIKit
import RxSwift
import RxCocoa
import Swinject

class PosterCollectionCell: UICollectionViewCell {
    static let identifier = "PosterCell"
    
    private var disposeBag = DisposeBag()
    
    private let viewModel = PosterCollectionCellViewModel()
    
    let poster = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(poster)
        poster.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        viewModel.image
            .bind(to: poster.rx.image)
            .disposed(by: disposeBag)
    }
    
    func configure(with path: String) {
        viewModel.setup(path: path)
        bind()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        poster.image = nil
        disposeBag = DisposeBag()
    }
}

class PosterCollectionCellViewModel {
    let disposeBag = DisposeBag()
    let moveService = Container.sharedContainer.resolve(MovieService.self)!
    
    private let posterPath = BehaviorRelay<String>(value: "")
    
    lazy var image: Observable<UIImage> = {
        posterPath.asObservable()
            .flatMap { [weak self] path -> Observable<UIImage> in
                guard let self = self else { return .empty() }
                return self.moveService.getPoster(path: path)
            }
    }()
    
    func setup(path: String) {
        self.posterPath.accept(path)
    }
}
