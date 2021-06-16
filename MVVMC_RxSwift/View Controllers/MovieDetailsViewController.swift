import Foundation
import UIKit
import RxSwift
import RxCocoa

class MovieDetailsViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel: MovieDetailsViewModel
    
    let poster: UIImageView = {
        let image = UIImageView()
        image.layer.borderWidth = 2.0
        image.layer.borderColor = UIColor.borderGrey.cgColor
        return image
    }()
    
    let movieTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.applyStyle(.white, .big, .bold)
        return label
    }()
    
    let releaseAndDuration: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.applyStyle(.white, .small, .regular)
        return label
    }()
    
    let overview: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.applyStyle(.white, .small, .regular)
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        return button
    }()
    
    let genreContainer = UIView()
    
    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        buildUI()
        bind()
    }
    
    private func buildUI() {
        view.addSubview(closeButton)
        closeButton.autoPinEdge(toSuperviewEdge: .top, withInset: 31)
        closeButton.autoPinEdge(toSuperviewEdge: .right, withInset: 25)
        
        view.addSubview(poster)
        poster.autoPinEdge(toSuperviewEdge: .top, withInset: 75)
        poster.autoAlignAxis(toSuperviewAxis: .vertical)
        
        view.addSubview(movieTitle)
        movieTitle.autoPinEdge(.top, to: .bottom, of: poster, withOffset: 6)
        movieTitle.autoPinEdge(toSuperviewEdge: .left, withInset: 25)
        movieTitle.autoPinEdge(toSuperviewEdge: .right, withInset: 25)
        
        view.addSubview(releaseAndDuration)
        releaseAndDuration.autoPinEdge(.top, to: .bottom, of: movieTitle, withOffset: 2)
        releaseAndDuration.autoPinEdge(toSuperviewEdge: .left, withInset: 25)
        releaseAndDuration.autoPinEdge(toSuperviewEdge: .right, withInset: 25)
        
        let overviewLabel = UILabel(forAutoLayout: ())
        overviewLabel.applyStyle(.white, .big, .bold)
        overviewLabel.text = "Overview"
        view.addSubview(overviewLabel)
        overviewLabel.autoPinEdge(.top, to: .bottom, of: releaseAndDuration, withOffset: 20)
        overviewLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 42)
        overviewLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 42)
        
        view.addSubview(overview)
        overview.autoPinEdge(.top, to: .bottom, of: overviewLabel, withOffset: 20)
        overview.autoPinEdge(toSuperviewEdge: .left, withInset: 42)
        overview.autoPinEdge(toSuperviewEdge: .right, withInset: 42)
        
        genreContainer.backgroundColor = .clear
        view.addSubview(genreContainer)
        genreContainer.autoPinEdge(.top, to: .bottom, of: overview, withOffset: 18)
        genreContainer.autoPinEdge(toSuperviewEdge: .left, withInset: 41)
//        NSLayoutConstraint.autoSetPriority(UILayoutPriority.defaultLow, forConstraints: {
//            genreContainer.autoPinEdge(toSuperviewEdge: .right, withInset: 41)
//        })
        genreContainer.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    private func bind() {
        closeButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.image
            .bind(to: poster.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.title
            .bind(to: movieTitle.rx.text)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.releaseDate, viewModel.duration) { releaseDate, duration -> String in
                "\(releaseDate ?? "") - \(duration ?? "")"
            }
            .bind(to: releaseAndDuration.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.overview
            .bind(to: overview.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.genres
            .subscribe(onNext: { [unowned self] genres in
                let genreLabels = NSArray(array: genres.map { genre -> UIView in
                    self.setLabelFor(genre)
                })
                genreLabels.autoDistributeViews(along: .horizontal, alignedTo: .top, withFixedSpacing: 7, insetSpacing: false, matchedSizes: false)
            })
            .disposed(by: disposeBag)
    }

    private func setLabelFor(_ genre: String) -> UIView {
        let view = UIView(forAutoLayout: ())
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        genreContainer.addSubview(view)
        
        let label = UILabel(forAutoLayout: ())
        label.applyStyle(.black, .small)
        label.text = genre.uppercased()
        view.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .top, withInset: 2)
        label.autoPinEdge(toSuperviewEdge: .bottom, withInset: 2)
        label.autoPinEdge(toSuperviewEdge: .left, withInset: 4)
        label.autoPinEdge(toSuperviewEdge: .right, withInset: 4)
        
        return view
    }
}
