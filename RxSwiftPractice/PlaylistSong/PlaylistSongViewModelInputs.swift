//
//  PlaylistSongViewModelInputs.swift
//  RxSwiftPractice
//
//  Created by Green on 2019/4/22.
//  Copyright © 2019 Green. All rights reserved.
//


import RxSwift
import RxCocoa

typealias PlaylistSongViewModelProtocols = PlaylistSongViewModelInputs & PlaylistSongViewModelOutputs

protocol PlaylistSongViewModelInputs {
    var trigger: PublishSubject<Void> { get }
}

protocol PlaylistSongViewModelOutputs {
    var songs: BehaviorRelay<[Song]> { get }
    var loading: BehaviorRelay<Bool> { get }
}
