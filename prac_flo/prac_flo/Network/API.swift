//
//  API.swift
//  prac_flo
//
//  Created by 남수김 on 2021/06/01.
//

import Foundation
import Alamofire

protocol API {
    var url: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var header: HTTPHeaders? { get }
    var body: Parameters? { get }
}

extension API {
    var baseURL: URL {
        guard let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com") else {
            fatalError("baseURL Error")
        }
        return url
    }
}
