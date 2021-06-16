import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import PureLayout
import PullToRefreshKit

class MoviesViewController: UIViewController, UITableViewDelegate {
    let disposeBag = DisposeBag()
    let viewModel: MoviesViewModel
    
    init(viewModel: MoviesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "Moviebox"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(forAutoLayout: ())
        tableView.backgroundColor = .sectionGrey
        tableView.separatorStyle = .none
        tableView.register(CarouselCell.self, forCellReuseIdentifier: CarouselCell.identifier)
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
        
        let header = DefaultRefreshHeader.header()
        header.setText("Pull to refresh", mode: .pullToRefresh)
        header.setText("Release to refresh", mode: .releaseToRefresh)
        header.setText("Success", mode: .refreshSuccess)
        header.setText("Refreshing...", mode: .refreshing)
        header.setText("Failed", mode: .refreshFailure)
        header.tintColor = .kindOfOrange
        header.imageRenderingWithTintColor = true
        header.durationWhenHide = 0.4
        tableView.configRefreshHeader(with: header, container: self) { [weak self] in
            self?.viewModel.reloadItems()
            self?.tableView.switchRefreshHeader(to: .normal(.success, 0.3))
        };
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea()

        bind()
    }
    
    private func bind() {
        let dataSource = RxTableViewSectionedReloadDataSource<MoviesViewModel.DataSource>(configureCell: { [unowned self] dataSource, tableView, indexPath, model in
            switch dataSource[indexPath] {
            case .carouselItem(let movies):
                let cell = tableView.dequeueReusableCell(withIdentifier: CarouselCell.identifier, for: indexPath)
                if let cell = cell as? CarouselCell {
                    cell.configure(with: movies, and: self.viewModel.steps)
                }
                return cell
            case .listItem(let movie):
                let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath)
                if let cell = cell as? MovieCell {
                    cell.configure(with: movie)
                }
                return cell
            }
        })
        dataSource.titleForHeaderInSection = { (source: TableViewSectionedDataSource<MoviesViewModel.DataSource>, section: Int) -> String? in
            source[section].header
        }

        viewModel.dataSource
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
                if case let .listItem(movie) = dataSource[indexPath] {
                    self.viewModel.selected(item: movie)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection _: Int) {
        let v = view as? UITableViewHeaderFooterView
        v?.textLabel?.applyStyle(.orange, .small)
        v?.contentView.backgroundColor = .sectionGrey
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 160
        }
        return 93
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == (tableView.numberOfSections - 1) && indexPath.row == (tableView.numberOfRows(inSection: indexPath.section) - 1) {
            viewModel.loadMoreItems()
        }
    }
}
