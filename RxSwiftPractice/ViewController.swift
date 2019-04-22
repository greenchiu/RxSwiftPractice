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
        
        tableview.dataSource = self
        view.addSubview(tableview)
        tableview.snp.makeConstraints { make in
            make.top.equalTo(fetchPlaylistButton.snp.bottom)
            make.leading.trailing.bottom.equalTo(view)
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
            .drive(onNext: { _ in
                self.tableview.reloadData()
            })
            .disposed(by: bag)
        
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.playlists.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        guard let aCell = cell else { fatalError() }
        
        let playlist = viewModel.playlists.value[indexPath.row]
        aCell.textLabel?.text = playlist.title
        return aCell
        
    }
}

