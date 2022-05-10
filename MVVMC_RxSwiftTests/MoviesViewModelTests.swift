import XCTest
@testable import MVVMC_RxSwift
import RxSwift
import RxBlocking
import Swinject
import Mocker

class MoviesViewModelTests: XCTestCase {
    var sut: MoviesViewModel!
    var disposeBag: DisposeBag!
    static let pageSize = 20

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        loadJSON(from: "nowplaying", for: "https://api.themoviedb.org/3/movie/now_playing?api_key=***REMOVED***")
        loadJSON(from: "popular1", for: "https://api.themoviedb.org/3/movie/popular?api_key=***REMOVED***&page=1")
        loadJSON(from: "popular2", for: "https://api.themoviedb.org/3/movie/popular?api_key=***REMOVED***&page=2")
        sut = MoviesViewModel(movieService: Container.sharedContainer.resolve(MovieService.self, name: "mock")!)
        disposeBag = DisposeBag()
    }
    
    private func loadJSON(from file: String, for url: String) {
        if let path = Bundle.main.path(forResource: file, ofType: "json") {
            do {
                let jsonData = try String(contentsOfFile: path).data(using: .utf8)!
                let url = URL(string: url)!
                let mock = Mock(url: url, dataType: .json, statusCode: 200, data: [.get: jsonData])
                mock.register()
            } catch {
                debugPrint("catch")
            }
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        disposeBag = nil
    }

    func testLoadingNowPlayingOnCreate() {
        do {
            let result = try sut.dataSource.toBlocking().first()
            XCTAssertEqual(result?[0].header, "Playing now")
            XCTAssertNotEqual(result?[0].items.count, 0)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLoadingPopularOnCreate() {
        do {
            let result = try sut.dataSource.toBlocking().first()
            XCTAssertEqual(result?[1].header, "Most popular")
            XCTAssertEqual(result?[1].items.count, MoviesViewModelTests.pageSize)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLoadMore() {
        let waitForIt = expectation(description: "load more popular")
        
        sut.dataSource
            .subscribe(onNext: { dataSource in
                guard dataSource.isNotEmpty else { return }
                if dataSource[1].items.count == MoviesViewModelTests.pageSize * 2 {
                    waitForIt.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.sut.loadMoreItems()
        }
        
        wait(for: [waitForIt], timeout: 2)
    }
    
    func testPreventLoadingMorePagesAtOnce() {
        let waitForIt = expectation(description: "prevent load more popular pages at once")
        
        sut.dataSource
            .subscribe(onNext: { dataSource in
                guard dataSource.isNotEmpty else { return }
                if dataSource[1].items.count == MoviesViewModelTests.pageSize {
                    waitForIt.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        sut.loadMoreItems()
        
        wait(for: [waitForIt], timeout: 0.2)
    }
    
    func testLastPage() {
        let waitForIt = expectation(description: "prevent load more popular pages than exist")
        
        sut.dataSource
            .skip(2)
            .subscribe(onNext: { _ in
                XCTAssert(false)
            })
            .disposed(by: disposeBag)
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
            self.sut.loadMoreItems()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
            self.sut.loadMoreItems()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1500)) {
            waitForIt.fulfill()
        }
    
        wait(for: [waitForIt], timeout: 2)
    }
    
    func testRefresh() {
        let waitForIt = expectation(description: "refresh")
        
        sut.dataSource
            .skip(2)
            .subscribe(onNext: { dataSource in
                guard dataSource.isNotEmpty else { return }
                if dataSource[1].items.count == MoviesViewModelTests.pageSize {
                    waitForIt.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
            self.sut.loadMoreItems()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.sut.reloadItems()
        }
        
        wait(for: [waitForIt], timeout: 2)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
