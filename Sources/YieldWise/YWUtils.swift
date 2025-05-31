//
//  YWUtils.swift
//  portfolio-manager-app
//
//  Created by Georgi Kamenov on 31.05.25.
//
import UIKit

extension UIApplication {
    nonisolated static let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
}
