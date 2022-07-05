//
//  ViewController.swift
//  RatingSystem
//
//  Created by Mayank Tewatia on 6/29/22.
//

import UIKit
import Cosmos
import TinyConstraints

class RatingController: UIViewController {
    
    lazy var ratingView: CosmosView = {
        var view = CosmosView()
        
        // Below line will only let the user view the rating and not update it(For un-registered users). 
        //view.settings.updateOnTouch = false
        
        view.settings.fillMode = .half
        view.text = "Rating System"
        view.settings.textColor = .blue
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        view.addSubview(ratingView)
        ratingView.centerInSuperview()
        
        // prints what the user rated on console
        ratingView.didTouchCosmos = {
            rating in print ("Rated: \(rating)")
        }
    }


}

