//
//  BankInfoViewModel.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 01/08/23.
//

import Foundation

protocol BankInfoDelegate: AnyObject {
    func sendBankDetails(details: [DataDetails])
    func sendIBanResponseStatus(status: Bool, message: String)
}

class BankInfoViewModel {
    weak var bankDetailsDelegate: BankInfoDelegate?
    private var apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    convenience init() {
        self.init(apiClient: NetworkService())
    }
    
    let asyncQueue = DispatchQueue.global(qos: .utility)
    
    func fetchBankDetails() {
        let url = "\(APIEndpoints.baseUrl)bank_data/all?per_page=10&page=1&country=KW"
        guard let request = apiClient.createRequest(for: url) else {
            return
        }
        asyncQueue.async {
            self.apiClient.executeRequest(request: request) { (result: Result<BankDataListModel, Error>) in
                switch(result) {
                case .success(let bankData):
                    self.bankDetailsDelegate?.sendBankDetails(details: bankData.data)
                case .failure(let error):
                    debugPrint("We got a failure trying to get the users. The error we got was: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func verifyIBanNumber(iban: String) {
        let url = "\(APIEndpoints.baseUrl)bank_data/iban_validate?iban_number=\(iban)"
        guard let request = apiClient.createRequest(for: url) else {
            return
        }
        asyncQueue.async {
            self.apiClient.executeRequest(request: request) { (result: Result<IBanResponseModel, Error>) in
                switch(result) {
                case .success(let ibanData):
                    self.bankDetailsDelegate?.sendIBanResponseStatus(status: ibanData.valid, message: ibanData.message)
                case .failure(let error):
                    self.bankDetailsDelegate?.sendIBanResponseStatus(status: false, message: error.localizedDescription)
                }
            }
        }
    }
    
}
