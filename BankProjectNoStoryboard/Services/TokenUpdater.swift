import Foundation

extension Date {
    var millisecondsSince1970: Int {
        Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension Int {
    var timeInterval: Double {
        Double(self) / 1000.0
    }
}

class TokenUpdater {
    
    static let shared: TokenUpdater = .init()
    private init() {}
    
    var timer = Timer()
    lazy var request: ServiceWrapper = .login(phoneNumber: "", password: "", receiver: self)

    private(set) var token: String = ""
    private var validUntil: Int = 0 {
        didSet {
            let now = Date.now.millisecondsSince1970
            let interval = validUntil - now - 10_000 // make time for network call
            print("Setting timer to launch after \(interval) ms")
            timer = Timer(timeInterval: interval.timeInterval,
                          repeats: false) { [weak self] _ in
                self?.request.makeRequest()
            }
        }
    }
    
    func set(request: Service) {
        if case .login(let phoneNumber, let password) = request {
            self.request = .login(phoneNumber: phoneNumber, password: password, receiver: self)
        }
    }
    func set(validUntil: Int) {
        self.validUntil = validUntil
    }
    
    func dismiss() {
        token = ""
        validUntil = 0
        timer.invalidate()
    }
}

extension TokenUpdater: UserAuthenticationResponseReceiver {
    func receive(userAuthenticationResponse response: Service.UserAuthenticationResponse) {
        self.validUntil = response.validUntil
        self.token = response.accessToken
    }
    
    func receive(error: Service.Err) {
        timer.fire()
    }
}
