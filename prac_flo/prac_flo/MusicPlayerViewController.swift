//
//  ViewController.swift
//  prac_flo
//
//  Created by 남수김 on 2021/05/31.
//

import UIKit

class MusicPlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestTest()
    }
    
    func requestTest() {
        APIRequest.shared.requestSongInfo { result in
            print(result)
        }
    }
}

