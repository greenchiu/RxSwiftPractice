//
//  ViewController.swift
//  RxSwiftPractice
//
//  Created by GreenChiu on 2019/4/10.
//  Copyright © 2019 Green. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class ViewController: UIViewController {

    let bag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        APIEngine.shared.authorizeKKBOX()
            .debug("AuthorizedKKBOX", trimOutput: true)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: {
                print("authorized success")
                self.fetchPlaylists()
            })
            .disposed(by: bag)
        
        
        
    }


    func fetchPlaylists() {
        APIEngine.shared.fetchFeaturedPlaylist(page: 0)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { tuple in
                print(tuple.0)
            })
            .disposed(by: bag)
    }
}

