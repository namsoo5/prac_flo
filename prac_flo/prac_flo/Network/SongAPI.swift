//
//  SongAPI.swift
//  prac_flo
//
//  Created by 남수김 on 2021/06/01.
//

import Foundation
import Alamofire

struct SongAPI: API {
    var url: URL {
        baseURL.appendingPathComponent(path)
    }
    let path: String = "/2020-flo/song.json"
    let method: HTTPMethod = .get
    let header: HTTPHeaders?
    var body: Parameters?
}
