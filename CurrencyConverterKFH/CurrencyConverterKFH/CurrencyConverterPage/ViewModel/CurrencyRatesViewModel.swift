//
//  CurrencyRatesViewModel.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 01/08/23.
//

import Foundation

protocol currencyRateDetailsDelegate: AnyObject {
    func sendCurrencyListAndRateDetails(details: [String: Double])
}

class CurrencyRatesViewModel {
    weak var fetchCurrencyDelegate: currencyRateDetailsDelegate?
    private var apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    convenience init() {
        self.init(apiClient: NetworkService())
    }
    
    let asyncQueue = DispatchQueue.global(qos: .utility)
    
    func fetchCurrentCurrencyRates() {
        let url = "\(APIEndpoints.baseUrl)fixer/latest?symbols=&base=KWD"
        guard let request = apiClient.createRequest(for: url) else {
            return
        }
        asyncQueue.async {
            self.apiClient.executeRequest(request: request) { (result: Result<CurrencyRatesModel, Error>) in
                switch(result) {
                case .success(let currentRateData):
                    print(currentRateData.rates)
                    
                    self.fetchCurrencyDelegate?.sendCurrencyListAndRateDetails(details: currentRateData.rates)
                case .failure(let error):
                    debugPrint("We got a failure trying to get the users. The error we got was: \(error.localizedDescription)")
                }
            }
        }
    }
}
