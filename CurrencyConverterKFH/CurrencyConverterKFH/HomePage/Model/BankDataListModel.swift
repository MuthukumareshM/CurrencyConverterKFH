//
//  BankDataListModel.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 01/08/23.
//

import Foundation

struct BankDataListModel: Codable {
    let data: [DataDetails]
}

struct DataDetails: Codable {
    let ibanData: IbanData
    let swiftData: SwiftData
}

struct IbanData: Codable {
    let isoCountryCode: String?
    let accountNumber: String
    let bankCode, branch, bban: String?
    let checksum, country, countryCode: String?
    let iban: String?
}

struct SwiftData: Codable {
    let address, branch: String
    let city: String
    let country: String
    let countryCode: String
    let name, swift, zip: String
}
