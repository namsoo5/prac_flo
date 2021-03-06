//
//  Log.swift
//  prac_flo
//
//  Created by λ¨μκΉ on 2021/06/02.
//

import Foundation

func Log<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
    let value = object()
    let fileURL = file.components(separatedBy: "/").last ?? "Unknown file"
    let queue = Thread.isMainThread ? "MAIN" : "BG"

    print("β <\(queue)> \(fileURL) \(function)[\(line)]:\n" + String(describing: value))
    #endif
}
