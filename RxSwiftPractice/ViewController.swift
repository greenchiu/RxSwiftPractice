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
    let viewModel = HomeViewModel()
    let authorizedButton = UIButton(type: .custom)
    
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
        
//        authorizedButton.rx
//            .controlEvent(.touchUpInside)
//            .asDriver()
//            .drive(viewModel.startTrigger)
//            .disposed(by: bag)
    
        let authrorizedRequest = authorizedButton.rx
            .controlEvent(.touchUpInside)
            .asObservable()
            .flatMap { _ in
                APIEngine.shared.authorizeKKBOX()
            }
            .share(replay: 1, scope: .whileConnected)

//        let loggedIn = authrorizedRequest.map { _ in
//                !APIEngine.shared.loggedin
//            }
//            .asDriver(onErrorJustReturn: false)
//
//
//        loggedIn.map {
//                $0 ? "loggedin" : "authorized"
//            }
//            .drive(authorizedButton.rx.title())
//            .disposed(by: bag)
//
//        loggedIn
//            .drive(authorizedButton.rx.isEnabled)
//            .disposed(by: bag)
        
        
        authrorizedRequest
            .asObservable()
            .do(onNext: { _ in
                self.authorizedButton.setTitle(APIEngine.shared.loggedin ? "loggedin" : "Authorized" , for: .normal)
            })
            .flatMap { _ in
                APIEngine.shared.fetchFeaturedPlaylist()
            }
            .map { (arg0) -> [Playlist] in
                let (playlists, _) = arg0
                return playlists
            }
            .bind(to: viewModel.result)
            .disposed(by: bag)
        
        
        
        let fetchPlaylistRequest = authrorizedRequest.asObservable().flatMap { _ in
            APIEngine.shared.fetchFeaturedPlaylist()
        }

        fetchPlaylistRequest.map { (arg0) -> [Playlist] in
            let (playlists, _) = arg0
            return playlists
        }
        .bind(to: viewModel.result)
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

