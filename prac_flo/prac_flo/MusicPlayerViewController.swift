//
//  ViewController.swift
//  prac_flo
//
//  Created by 남수김 on 2021/05/31.
//

import UIKit
import AVFoundation

final class MusicPlayerViewController: UIViewController {

    @IBOutlet private weak var songTitleLabel: UILabel!
    @IBOutlet private weak var songSingerLabel: UILabel!
    @IBOutlet private weak var songImageView: UIImageView!
    @IBOutlet private weak var songProgressView: UIProgressView!
    @IBOutlet private weak var songPlayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestTest()
        
    }
    
    @IBAction private func playButtonTouchUpInside(_ sender: Any) {
        
    }
    
    private func requestTest() {
        APIRequest.shared.requestSongInfo { result in
            print(result)
            
            
        }
    }
}

