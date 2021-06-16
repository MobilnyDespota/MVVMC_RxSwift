import Foundation
import RxSwift
import RxFlow
import Swinject

enum AppStep: Step {
    case movies
    case details(movie: Movie)
}

class AppFlow: Flow {
    var root: Presentable {
        rootViewController
    }

    private lazy var rootViewController: UINavigationController = {
        let navigation = UINavigationController()
        navigation.navigationBar.barTintColor = .black
        navigation.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.kindOfOrange]
        return navigation
    }()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .movies:
            return goToMoviesList()
        case .details(let movie):
            return goToMovieDetails(movie: movie)
        }
    }
    
    func goToMoviesList() -> FlowContributors {
        let vm = MoviesViewModel(movieService: Container.sharedContainer.resolve(MovieService.self)!)
        let vc = MoviesViewController(viewModel: vm)
        self.rootViewController.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vm))
    }
    
    func goToMovieDetails(movie: Movie) -> FlowContributors {
        let vm = MovieDetailsViewModel(movieService: Container.sharedContainer.resolve(MovieService.self)!, movie: movie)
        let vc = MovieDetailsViewController(viewModel: vm)
        self.rootViewController.present(vc, animated: true)
        return .none
    }
}
