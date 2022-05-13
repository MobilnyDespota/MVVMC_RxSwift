import XCTest
@testable import MVVMC_RxSwift
import RxSwift
import RxBlocking
import Swinject
import Mocker
import TMDB

class MovieDetailsViewModelTests: XCTestCase {
    var sut: MovieDetailsViewModel!
    var mockMovie: Movie!
    var disposeBag: DisposeBag!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let path = Bundle.main.path(forResource: "details", ofType: "json") {
            do {
                let jsonString = try String(contentsOfFile: path)
                let jsonData = jsonString.data(using: .utf8)!
                let url = URL(string: "https://api.themoviedb.org/3/movie/632357?api_key=" + Api.Key)!
                let mock = Mock(url: url, dataType: .json, statusCode: 200, data: [.get: jsonData])
                mock.register()
                mockMovie = Movie(JSONString: jsonString)
            } catch {
                debugPrint("catch")
            }
        }
        sut = MovieDetailsViewModel(movieService: Container.sharedContainer.resolve(MovieService.self, name: "mock")!, movie: mockMovie)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        disposeBag = nil
    }

    func testDuration() {
        let waitForIt = expectation(description: "duration")
        
        sut.duration
            .subscribe(onNext: { duration in
                if duration == "1h 39m" {
                    waitForIt.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        wait(for: [waitForIt], timeout: 0.2)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
