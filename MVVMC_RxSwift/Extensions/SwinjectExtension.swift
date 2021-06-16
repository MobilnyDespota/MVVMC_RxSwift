import Foundation
import Swinject
import Alamofire
import Mocker

extension Container {
    static let sharedContainer: Container = {
        let container = Container()

        container.register(MovieService.self) { resolver -> MovieServiceManager in
            MovieServiceManager(session: Alamofire.Session.default)
        }
        
        container.register(MovieService.self, name: "mock") { resolver -> MovieServiceManager in
            let configuration = URLSessionConfiguration.af.default
            configuration.protocolClasses = [MockingURLProtocol.self]
            let session = Alamofire.Session(configuration: configuration)
            return MovieServiceManager(session: session)
        }

        return container
    }()
}
