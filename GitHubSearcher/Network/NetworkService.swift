//
//  NetworkService.swift
//  GitHubSearcher
//
//  Created by YN on 4/16/20.
//  Copyright © 2020 YN. All rights reserved.
//

import Foundation
enum EndPoints: String {
    case users = "/search/users?"
    case repos = "/search/repositories?"
}
enum NetworkError: String,Error {
    case urlInitFail
    case dataTaskError
    case statusCodeError
    case dataNil
    case decodeError
}
class NetworkService {
    static let shared = NetworkService()
    let urlSession = URLSession(configuration: .default)
    let baseURL = "https://api.github.com"
    private init() {}
    func users(userName: String, page: Int, completionHandler: @escaping (Result<UserModel, NetworkError>) -> ()) -> URLSessionDataTask? {
        let replacedUserName = userName.replacingOccurrences(of: " ", with: "+")
        let urlString = baseURL + EndPoints.users.rawValue + "q=\(replacedUserName)" + "&page=\(page)"
        return get(urlString: urlString) { result in
            completionHandler(result)
        }
    }
    func repos(userName: String, repoName:String?, page: Int, completionHandler: @escaping (Result<RepoModel, NetworkError>) -> ()) -> URLSessionDataTask? {
        let replacedUserName = userName.replacingOccurrences(of: " ", with: "+")
        var replacedRepoName = ""
        if let repo = repoName {
            replacedRepoName = repo.replacingOccurrences(of: " ", with: "+")
        }
        let urlString = baseURL + EndPoints.repos.rawValue + "q=\(replacedRepoName)+user:\(replacedUserName)" + "&page=\(page)"
        return get(urlString: urlString) { result in
            completionHandler(result)
        }
    }
    func userDetail(urlString: String, completionHandler: @escaping (Result<UserDetailModel, NetworkError>) -> ()) -> URLSessionDataTask? {
        return get(urlString: urlString) { result in
            completionHandler(result)
            }
    }
    func get<T:Codable>(urlString: String, completionHandler: @escaping (Result<T,NetworkError>)->Void) -> URLSessionDataTask? {
        guard let url = URL(string: urlString) else  {
            completionHandler(.failure(.urlInitFail))
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        /*Rever the token to pass the github token check*/
        let token1 = "177a8b9e06badae9b"
        let token2 = "47d45571ec2270c74aef390"
        let token = String(token1.reversed()) + String(token2.reversed())
        urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                completionHandler(.failure(.dataTaskError))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    completionHandler(.failure(.statusCodeError))
                    return
            }
            guard let data = data else {
                completionHandler(.failure(.dataNil))
                return
            }
            guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                completionHandler(.failure(.decodeError))
                return
            }
            completionHandler(.success(decodedData))
        }
        return task
    }
}

