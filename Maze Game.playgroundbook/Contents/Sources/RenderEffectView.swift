//
//  RenderEffectView.swift
//  CameraController
//
//  Created by scauos on 2018/3/28.
//  Copyright © 2018年 scauos. All rights reserved.
//

import UIKit

class RenderEffectView: UIVisualEffectView {
    var cornerRadius: CGFloat = 22 {
        didSet {
            self.vibrancyView.layer.cornerRadius = cornerRadius
            layer.cornerRadius = cornerRadius
        }
    }
    var vibrancyView: UIVisualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light)))

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        self.contentView.addSubview(vibrancyView)
        vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vibrancyView.clipsToBounds = true
    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}
