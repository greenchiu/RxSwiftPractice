//
//  UIScrollView+Rx.swift
//  RxSwiftPractice
//
//  Created by GreenChiu on 2019/4/22.
//  Copyright © 2019 Green. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView  {
    
    //视图滚到底部检测序列
    var reachedBottom: Signal<()> {
        return contentOffset.asDriver()
            .flatMap { [weak base] contentOffset -> Signal<()> in
                guard let scrollView = base else {
                    return Signal.empty()
                }
                
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top
                    - scrollView.contentInset.bottom
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                //如果当前位置超出最大位置则发出一个事件
                let y = contentOffset.y + scrollView.contentInset.top
                return y > threshold ? Signal.just(()) : Signal.empty()
        }
    }
}
