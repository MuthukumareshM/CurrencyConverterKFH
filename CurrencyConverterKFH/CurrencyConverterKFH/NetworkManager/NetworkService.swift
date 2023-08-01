//
//  NetworkService.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 01/08/23.
//

import Foundation

enum NetworkError: Error {
    case invalidUrl
    case invalidData
    case noInternet
}

struct ApiKeys {
    static let apiKey = "UEdaNdpiNGTzxNFOrGKhrINnmFqYso6N"
}

protocol APIClient {
    func createRequest(for url: String) -> URLRequest?
    func executeRequest<T: Codable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
}


class NetworkService: NSObject, APIClient {
    
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    
    private let certificates: [Data] = {
            let url = Bundle.main.url(forResource: "sni.cloudflaressl.com", withExtension: "cer")!
            let data = try! Data(contentsOf: url)
            return [data]
    }()
    
    func createRequest(for url: String) -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(ApiKeys.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func executeRequest<T: Codable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        print(NetworkMonitor.shared.isConnected)
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(NetworkError.noInternet))
            return
        }
        let dataTask = self.session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print(error?.localizedDescription)
                completion(.failure(error ?? NetworkError.invalidData))
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let decodedResponse = try? decoder.decode(T.self, from: data) {
                DispatchQueue.main.async {
                    completion(.success(decodedResponse))
                }
            } else {
                completion(.failure(NetworkError.invalidData))
            }
        }
        dataTask.resume()
    }
}

extension NetworkService: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust,
           SecTrustGetCertificateCount(trust) > 0 {
            if let certificate = SecTrustGetCertificateAtIndex(trust, 0) {
                let data = SecCertificateCopyData(certificate) as Data
                
                if certificates.contains(data) {
                    completionHandler(.useCredential, URLCredential(trust: trust))
                    return
                } else {
                    print("Certificate Mismatch")
                    //TODO: Throw SSL Certificate Mismatch
                }
            }
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}


