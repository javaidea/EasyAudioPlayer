//
//  AVPlayer+Extensions.swift
//  EasyAudioPlayer
//
//  Created by Zhou Yang on 6/22/23.
//

import AVFoundation
import SwiftUI

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
