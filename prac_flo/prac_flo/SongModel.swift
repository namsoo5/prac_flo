//
//  SongModel.swift
//  prac_flo
//
//  Created by 남수김 on 2021/06/01.
//

import Foundation

struct Song: Decodable {
    let singer: String
    let album: String
    let title: String
    let duration: Int
    let image: String
    let file: String
    let lyrics: [String]
}
