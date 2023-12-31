//
//  IBanResponseModel.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 01/08/23.
//

import Foundation

struct IBanResponseModel: Codable {
    let bankData: BankData
    let countryIbanExample, iban: String
    let ibanData: IbanData
    let message: String
    let valid: Bool
}

struct BankData: Codable {
    let bankCode, bic, city, name: String
    let zip: String
}

