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
    
    let loadingIndicator = UIActivityIndicatorView(style: .gray)
    let tableview = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configurationUIs()
        setupBuildings()
    }

    func configurationUIs() {
        
        authorizedButton.setTitle("Authorize", for: .normal)
        authorizedButton.setTitleColor(.black, for: .normal)
        view.addSubview(authorizedButton)
        authorizedButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 20))
            make.top.equalTo(60)
            make.leading.equalTo(10)
        }
        
        authorizedButton.rx.controlEvent(.touchUpInside)
            .bind(onNext: viewModel.startAuthorizing)
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
        
        fetchPlaylistButton.rx.controlEvent(.touchUpInside)
            .bind(onNext: viewModel.fetchMore)
            .disposed(by: bag)
        
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableview)
        tableview.snp.makeConstraints { make in
            make.top.equalTo(fetchPlaylistButton.snp.bottom)
            make.leading.trailing.bottom.equalTo(view)
        }
        
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(view.center)
        }
    }
    
    func setupBuildings() {
        viewModel.loggedIn
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { loggedIn in
                self.authorizedButton.isHidden = loggedIn
                self.fetchPlaylistButton.isHidden = !loggedIn
            })
            .disposed(by: bag)
        
        viewModel.playlists
            .asDriver(onErrorJustReturn: [])
            .drive(tableview.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, model, cell in
                cell.textLabel?.text = model.title
            }
            .disposed(by: bag)
        
        Observable.zip(tableview.rx.itemSelected, tableview.rx.modelSelected(Playlist.self))
            .bind { [weak self] indexPath, item in
                print("\(indexPath.row)")
                print("\(item)")
            }
            .disposed(by: bag)
        
        viewModel.loading
            .asDriver()
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: bag)
    }
    
}

