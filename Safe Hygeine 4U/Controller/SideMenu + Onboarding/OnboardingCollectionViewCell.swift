//
//  OnboardingCollectionViewCell.swift
//  Yummie
//
//  Created by Emmanuel Okwara on 30/01/2021.
//

import UIKit
import Lottie
class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: OnboardingCollectionViewCell.self)
    
    @IBOutlet weak var slideTitleLbl: UILabel!
    @IBOutlet weak var slideAnimation: LottieAnimationView!
    @IBOutlet weak var slideDescriptionLbl: UILabel!
    
    func setup(_ slide: OnboardingSlide) {
        slideAnimation.animation = slide.animation
        slideTitleLbl.text = slide.title
        slideDescriptionLbl.text = slide.description
    }
}
