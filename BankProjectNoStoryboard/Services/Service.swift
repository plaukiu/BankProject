import Foundation
import Moya

enum Service {
        
    typealias Id = Int32

    static let provider = MoyaProvider<Self>()
    
    case updateBalance(accountId: Id,
                       amountToAdd: Int)
    
    case getTransactions(accountId: Id)
    
    case makeTransaction(transactionRequest: TransactionRequest)
    
    case getAllUsers
    
    case updateUser(currentPhoneNumber: String,
                    newPhoneNumber: String,
                    newPassword: String,
                    token: String)
    
    case deleteUser(userPhoneNumber: String,
                    token: String)
    
    case register(phoneNumber: String,
                  password: String,
                  currency: String)
    
    case login(phoneNumber: String,
               password: String)
}

extension Service {
    
    // MARK: - Requests
    
    struct TransactionRequest: Codable {
        let senderPhoneNumber: String
        let token: String
        let receiverPhoneNumber: String
        let senderAccountId: Id
        let amount: Double
        let comment: String
    }
    
    // MARK: - Returns
    
    struct TransactionInfo: Codable {
        let senderPhoneNumber: String
        let receiverPhoneNumber: String
        let sendingAccountId: Id
        let receivingAccountId: Id
        let transactionTime: Int
        let amount: Double
        let comment: String
    } // returned by getTransactions
    
    struct UserAuthenticationResponse: Codable {
        let userId: Id
        let validUntil: Int
        let accessToken: String
        var accountInfo: AccountInfo
    } // returned by updateUser, login
    
    struct AccountInfo: Codable {
        let id: Id
        let currency: String
        let balance: Double
        let ownerPhoneNumber: String
    } // returned by updateBalance, mediately by updateUser, login
    
    struct UserInfo: Codable {
        let id: Id
        let phoneNumber: String
    } // returned by getAllUsers
    
    struct UserRegisterResponse: Codable {
        let userId: Id
    } // returned by register
    
    enum Err: Error, CustomStringConvertible {
        case incorrectRequest
        case invalidToken
        case receiverHasNoSuchCurrencyOrSenderLacksFunds
        case phoneNumberAlreadyTaken
        case loginDetailsAreWrong
        
        var description: String {
            switch self {
            case .incorrectRequest:
                return "Incorrect request!"
            case .invalidToken:
                return "Invalid token!"
            case .receiverHasNoSuchCurrencyOrSenderLacksFunds:
                return "Receiver has no such currency or you lack funds!"
            case .phoneNumberAlreadyTaken:
                return "Phone number already taken!"
            case .loginDetailsAreWrong:
                return "Login details are wrong!"
            }
        }
    }
}


extension Service: TargetType {
    var baseURL: URL { URL(string: "http://134.122.94.77:7000/api")! }
    
    var path: String {
        switch self {
        case .updateBalance:
            return "/Accounts"
        case .makeTransaction, .getTransactions:
            return "/Transactions"
        case .getAllUsers, .updateUser, .deleteUser:
            return "/User"
        case .register:
            return "/User/register"
        case .login:
            return "/User/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .updateBalance, .updateUser:
            return .put
        case .getTransactions, .getAllUsers:
            return .get
        case .makeTransaction, .register, .login:
            return .post
        case .deleteUser:
            return .delete
        }
    }
    
    var task: Moya.Task {
        let encoding = JSONEncoding.default
        switch self {
            // plain
        case .getAllUsers:
            return .requestPlain
            
            // url encoded
        case .getTransactions(accountId: let accountId):
            return .requestParameters(parameters: [
                "accountId": accountId
            ], encoding: URLEncoding.queryString)
        
            // body encoded
        case .updateBalance(accountId: let accountId, amountToAdd: let amountToAdd):
            return .requestParameters(parameters: [
                "accountId": accountId,
                "amountToAdd": amountToAdd
            ], encoding: encoding)
            
        case .makeTransaction(let request):
            return .requestParameters(parameters: [
                "senderPhoneNumber": request.senderPhoneNumber,
                "token": request.token,
                "receiverPhoneNumber": request.receiverPhoneNumber,
                "senderAccountId": request.senderAccountId,
                "amount": request.amount,
                "comment": request.comment
            ], encoding: encoding)
            
        case .updateUser(currentPhoneNumber: let currentPhoneNumber, newPhoneNumber: let newPhoneNumber, newPassword: let newPassword, token: let token):
            return .requestParameters(parameters: [
                "currentPhoneNumber": currentPhoneNumber,
                "newPhoneNumber": newPhoneNumber,
                "newPassword": newPassword,
                "token": token
            ], encoding: encoding)
            
        case .deleteUser(userPhoneNumber: let userPhoneNumber, token: let token):
            return .requestParameters(parameters: [
                "userPhoneNumber": userPhoneNumber,
                "token": token
            ], encoding: encoding)
            
        case .register(phoneNumber: let phoneNumber, password: let password, currency: let currency):
            return .requestParameters(parameters: [
                "phoneNumber": phoneNumber,
                "password": password,
                "currency": currency
            ], encoding: encoding)
            
        case .login(phoneNumber: let phoneNumber, password: let password):
            return .requestParameters(parameters: [
                "phoneNumber": phoneNumber,
                "password": password
            ], encoding: encoding)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}
