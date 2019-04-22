//
//  PlaylistSongsViewController.swift
//  RxSwiftPractice
//
//  Created by GreenChiu on 2019/4/22.
//  Copyright © 2019 Green. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class PlaylistSongsViewController: UIViewController {
    
    private let bag = DisposeBag()
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .gray)
    
    var viewModel: PlaylistSongViewModelProtocols! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUIs()
        buildBindings()
        
    }
    
    private func configureUIs() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints{ make in
            make.edges.equalTo(view)
        }
        
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(view.center)
        }
    }
    
    private func buildBindings() {
        viewModel.loading
            .asDriver()
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: bag)
        
        viewModel.songs
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { row, model, cell in
                cell.textLabel?.text = model.name
            }
            .disposed(by: bag)
        
        rx.sentMessage(#selector(viewDidAppear(_:)))
            .map { _ in () }
            .bind(to: viewModel.trigger)
            .disposed(by: bag)
        
    }

}
