//
//  String+Extensions.swift
//  EasyAudioPlayer
//
//  Created by Zhou Yang on 6/17/23.
//

import Foundation

extension String {
    var filenameWithoutSuffix: String {
        return (self as NSString).deletingPathExtension
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
}
