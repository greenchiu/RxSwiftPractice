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
import SnapKit

class ViewController: UIViewController {

    let bag = DisposeBag()
    let viewModel = SimpleRxViewModel()
    var authrorizedRequest: Observable<Never>!
    let authorizedButton = UIButton(type: .custom)
    let fetchPlaylistButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        authorizedButton.setTitle("Authorize", for: .normal)
        authorizedButton.setTitleColor(.black, for: .normal)
        view.addSubview(authorizedButton)
        authorizedButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 20))
            make.top.equalTo(60)
            make.leading.equalTo(10)
        }
        
        authorizedButton.rx.controlEvent(.touchUpInside)
            .bind(onNext: self.viewModel.startAuthorizing)
            .disposed(by: bag)

        fetchPlaylistButton.setTitle("Playlists", for: .normal)
        fetchPlaylistButton.setTitleColor(.black, for: .normal)
        view.addSubview(fetchPlaylistButton)
        fetchPlaylistButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 20))
            make.top.equalTo(60)
            make.leading.equalTo(10)
        }
        fetchPlaylistButton.isHidden = true
        
        
        viewModel.loggedIn
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                guard let loggedIn = event.element else {
                    return
                }
                self.authorizedButton.isHidden = loggedIn
                self.fetchPlaylistButton.isHidden = !loggedIn
            }
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

