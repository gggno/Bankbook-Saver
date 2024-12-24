//
//  HomeViewController.swift
//  Bankbook Saver
//
//  Created by 정근호 on 12/24/24.
//

import UIKit
import ReactorKit

class HomeViewController: UIViewController, View {

    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemYellow
        self.reactor = HomeReactor()
    }
    
    func bind(reactor: HomeReactor) {
        
    }
    
}
