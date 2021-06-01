//
//  APIRequest.swift
//  prac_flo
//
//  Created by 남수김 on 2021/06/01.
//

import Foundation
import Alamofire

struct APIRequest {
    private func request<T: Decodable>(api: API, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        AF.request(api.url,
                   method: api.method,
                   parameters: api.body,
                   encoding: JSONEncoding.default,
                   headers: api.header)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: type) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

extension APIRequest {
    func requestSongInfo(completion: @escaping (Result<Song, Error>) -> Void) {
        let api = SongAPI(header: nil, body: nil)
        request(api: api, type: Song.self) { result in
            switch result {
            case .success(let song):
                completion(.success(song))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
