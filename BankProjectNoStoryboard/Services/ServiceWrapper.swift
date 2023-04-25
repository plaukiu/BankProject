import Foundation
import Moya

protocol ServiceErrorReceiver: AnyObject {
    func receive(error: Service.Err)
}
protocol AccountInfoReceiver: AnyObject, ServiceErrorReceiver {
    func receive(accountInfo: Service.AccountInfo)
}
protocol TransactionInfoReceiver: AnyObject, ServiceErrorReceiver {
    func receive(transactionInfo: [Service.TransactionInfo])
}
protocol TransactionSuccessReceiver: AnyObject, ServiceErrorReceiver {
    func receiveTransactionSuccess()
}
protocol UserAuthenticationResponseReceiver: AnyObject, ServiceErrorReceiver {
    func receive(userAuthenticationResponse: Service.UserAuthenticationResponse)
}
protocol UserInfoReceiver: AnyObject, ServiceErrorReceiver {
    func receive(userInfo: [Service.UserInfo])
}
protocol UserRegisterResponseReceiver: AnyObject, ServiceErrorReceiver {
    func receive(userRegisterResponse: Service.UserRegisterResponse)
}
protocol DeleteUserSuccessReceiver: AnyObject, ServiceErrorReceiver {
    func receiveDeleteUserSuccess()
}

enum ServiceWrapper: RawRepresentable {
    init?(rawValue: Service) {
        return nil
    }
    
    typealias RawValue = Service
    
    typealias Id = Service.Id
    case updateBalance(accountId: Id,
                       amountToAdd: Int,
                       receiver: AccountInfoReceiver)
    
    case getTransactions(accountId: Id,
                         receiver: TransactionInfoReceiver)
    
    case makeTransaction(transactionRequest: Service.TransactionRequest,
                         receiver: TransactionSuccessReceiver)
    
    case getAllUsers(receiver: UserInfoReceiver)
    
    case updateUser(currentPhoneNumber: String,
                    newPhoneNumber: String,
                    newPassword: String,
                    token: String,
                    receiver: UserAuthenticationResponseReceiver)
    
    case deleteUser(userPhoneNumber: String,
                    token: String,
                    receiver: DeleteUserSuccessReceiver)
    
    case register(phoneNumber: String,
                  password: String,
                  currency: String,
                  receiver: UserRegisterResponseReceiver)
    
    case login(phoneNumber: String,
               password: String,
               receiver: UserAuthenticationResponseReceiver)
    
    var rawValue: Service {
        switch self {
        case .updateBalance(accountId: let accountId, amountToAdd: let amountToAdd, receiver: _):
            return .updateBalance(accountId: accountId, amountToAdd: amountToAdd)
        case .getTransactions(accountId: let accountId, receiver: _):
            return .getTransactions(accountId: accountId)
        case .makeTransaction(transactionRequest: let transactionRequest, receiver: _):
            return .makeTransaction(transactionRequest: transactionRequest)
        case .getAllUsers(receiver: _):
            return .getAllUsers
        case .updateUser(currentPhoneNumber: let currentPhoneNumber, newPhoneNumber: let newPhoneNumber, newPassword: let newPassword, token: let token, receiver: _):
            return .updateUser(currentPhoneNumber: currentPhoneNumber, newPhoneNumber: newPhoneNumber, newPassword: newPassword, token: token)
        case .deleteUser(userPhoneNumber: let userPhoneNumber, token: let token, receiver: _):
            return .deleteUser(userPhoneNumber: userPhoneNumber, token: token)
        case .register(phoneNumber: let phoneNumber, password: let password, currency: let currency, receiver: _):
            return .register(phoneNumber: phoneNumber, password: password, currency: currency)
        case .login(phoneNumber: let phoneNumber, password: let password, receiver: _):
            return .login(phoneNumber: phoneNumber, password: password)
        }
    }
}

extension ServiceWrapper {
    func makeRequest() {
        func handleSysFailure(_ error: MoyaError) {
            fatalError(error.errorDescription!)
        }

        switch self {
        case .updateBalance(accountId: let accountId, amountToAdd: let amountToAdd, receiver: let receiver):

            Service.provider.request(.updateBalance(
                accountId: accountId,
                amountToAdd: amountToAdd)) { result in
                    
                    switch result {
                    case .success(let moyaResponse):
                        
                        if moyaResponse.statusCode == 200 {
                            do {
                                let decoded = try JSONDecoder().decode(
                                    Service.AccountInfo.self,
                                    from: moyaResponse.data)
                                receiver.receive(accountInfo: decoded)
                            } catch {
                                fatalError("blabla")
                            }
                        }
                        else {
                            let error: Service.Err
                            switch moyaResponse.statusCode {
                            case 400: error = .incorrectRequest
                            default: fatalError("Received unmanaged response")
                            }
                            receiver.receive(error: error)
                        }
                        
                    case .failure(let failure):
                        handleSysFailure(failure)
                    }
                }
            
        case .getTransactions(accountId: let accountId, receiver: let receiver):
            
            Service.provider.request(.getTransactions(accountId: accountId)) { result in
                switch result {
                case .success(let moyaResponse):
                    
                    if moyaResponse.statusCode == 200 {
                        do {
                            let decoded = try JSONDecoder().decode([Service.TransactionInfo].self,
                                                                   from: moyaResponse.data)
                            receiver.receive(transactionInfo: decoded)
                        } catch {
                            fatalError("Transactions did not decode successfully.")
                        }
                    }
                    else {
                        let error: Service.Err
                        switch moyaResponse.statusCode {
                        case 400: error = .incorrectRequest
                        default: fatalError("Unhandled response")
                        }
                        receiver.receive(error: error)
                    }
                    
                case .failure(let failure):
                    handleSysFailure(failure)
                }
            }
            
        case .makeTransaction(transactionRequest: let transactionRequest, receiver: let receiver):
            
            Service.provider.request(.makeTransaction(transactionRequest: transactionRequest)) { result in
                switch result {
                case .success(let moyaResponse):
                    
                    if moyaResponse.statusCode == 200 {
                        receiver.receiveTransactionSuccess()
                    }
                    else {
                        let error: Service.Err
                        switch moyaResponse.statusCode {
                        case 400: error = .incorrectRequest
                        case 409: error = .receiverHasNoSuchCurrencyOrSenderLacksFunds
                        default: fatalError("Received unmanaged response: \(moyaResponse.statusCode)")
                        }
                        receiver.receive(error: error)
                    }
                    
                case .failure(let failure):
                    handleSysFailure(failure)
                }
            }

        case .getAllUsers(receiver: let receiver):

            Service.provider.request(.getAllUsers) { result in
                switch result {
                case .success(let moyaResponse):
                    if moyaResponse.statusCode == 200 {
                        do {
                            let decoded = try JSONDecoder().decode([Service.UserInfo].self, from: moyaResponse.data)
                            receiver.receive(userInfo: decoded)
                        } catch {
                            fatalError("blabla")
                        }
                    }
                case .failure(let failure):
                    handleSysFailure(failure)
                    
                }
            }
            
        case .updateUser(currentPhoneNumber: let currentPhoneNumber, newPhoneNumber: let newPhoneNumber, newPassword: let newPassword, token: let token, receiver: let receiver):
            
            Service.provider.request(.updateUser(
                currentPhoneNumber: currentPhoneNumber,
                newPhoneNumber: newPhoneNumber,
                newPassword: newPassword,
                token: token)) { result in
                    switch result {
                    case .success(let moyaResponse):
                        
                        if moyaResponse.statusCode == 200 {
                            do {
                                let decoded = try JSONDecoder().decode(Service.UserAuthenticationResponse.self, from: moyaResponse.data)
                                receiver.receive(userAuthenticationResponse: decoded)
                            } catch {
                                fatalError("blabla")
                            }
                        }
                        else {
                            let error: Service.Err
                            switch moyaResponse.statusCode {
                            case 400: error = .incorrectRequest
                            default: fatalError("Received Unhandled response")
                            }
                            receiver.receive(error: error)
                        }
                    case .failure(let failure):
                        handleSysFailure(failure)
                    }
                }
            
        case .deleteUser(userPhoneNumber: let userPhoneNumber, token: let token, receiver: let receiver):
            
            Service.provider.request(.deleteUser(userPhoneNumber: userPhoneNumber, token: token)) { result in
                switch result {
                case .success(let moyaResponse):
                    if moyaResponse.statusCode == 200 {
                        receiver.receiveDeleteUserSuccess()
                    }
                    else {
                        let error: Service.Err
                        switch moyaResponse.statusCode {
                        case 400: error = .incorrectRequest
                        case 401: error = .invalidToken
                        default: fatalError("Received Unhandled response")
                        }
                        receiver.receive(error: error)
                    }
                    
                case .failure(let failure):
                    handleSysFailure(failure)
                }
            }
            
        case .register(phoneNumber: let phoneNumber, password: let password, currency: let currency, receiver: let receiver):
            
            Service.provider.request(.register(phoneNumber: phoneNumber,
                                               password: password,
                                               currency: currency)) { result in
                switch result {
                case .success(let moyaResponse):
                    
                    if moyaResponse.statusCode == 200 {
                        do {
                            let decoded = try JSONDecoder().decode(
                                Service.UserRegisterResponse.self,
                                from: moyaResponse.data)
                            
                            receiver.receive(userRegisterResponse: decoded)
                        } catch {
                            fatalError("Blablabla")
                        }
                    }
                    else {
                        let error: Service.Err
                        switch moyaResponse.statusCode {
                        case 400: error = .incorrectRequest
                        case 409: error = .phoneNumberAlreadyTaken
                        default: fatalError("Received unmanaged response")
                        }
                        receiver.receive(error: error)
                    }
                    
                case .failure(let failure):
                    handleSysFailure(failure)
                }
            }
            
        case .login(phoneNumber: let phoneNumber, password: let password, receiver: let receiver):
            
            Service.provider.request(.login(phoneNumber: phoneNumber,
                                            password: password)) { result in
                switch result {
                case .success(let moyaResponse):
                    
                    if moyaResponse.statusCode == 200 {
                        do {
                            let decoded = try JSONDecoder().decode(
                                Service.UserAuthenticationResponse.self,
                                from: moyaResponse.data)
                            
                            receiver.receive(userAuthenticationResponse: decoded)
                        } catch {
                            fatalError("blabla")
                        }
                    }
                    else {
                        let error: Service.Err
                        switch moyaResponse.statusCode {
                        case 400: error = .incorrectRequest
                        case 401: error = .loginDetailsAreWrong
                        default: fatalError("Received unmanaged response")
                        }
                        receiver.receive(error: error)
                    }
                    
                case .failure(let failure):
                    handleSysFailure(failure)
                }
            }
        }
        
    }
}
