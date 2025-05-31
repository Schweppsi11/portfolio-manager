//
//  YWProgressAnimatable.swift
//  portfolio-manager-app
//
//  Created by Georgi Kamenov on 31.05.25.
//
#if !SKIP
import SwiftUI

protocol YWProgressAnimatable: Animatable {
    var progress: CGFloat { get set }
}

extension YWProgressAnimatable {
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
}
#endif
