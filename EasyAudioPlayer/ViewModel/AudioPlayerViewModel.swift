//
//  AudioPlayerViewModel.swift
//  EasyAudioPlayer
//
//  Created by Zhou Yang on 6/17/23.
//

import AVFoundation
import MediaPlayer
import Combine
import SwiftUI

class AudioPlayerViewModel: ObservableObject {
    
    enum TimeDisplayMode: Int {
        case total = 0
        case remain = 1
    }
    
    @AppStorage("currentIndex") var currentIndex: Int = 0
    @AppStorage("currentPlayedSeconds") var currentPlayedSeconds: Double = 0
    @AppStorage("duration") var duration: Double = 0
    @AppStorage("timeDisplayMode") var timeDisplayMode: TimeDisplayMode = .total
    
    @Published var items: [AudioItem] = []
    @Published var progress: CGFloat = 0
    @Published var isSeeking: Bool = false
    @Published var isPlaying = false
    
    var player: AVPlayer?
    private var progressTimer: AnyCancellable?
    
    init() {
        for i in 0...1 {
            let filename = String(format: "%.3d", i + 1)
            items.append(AudioItem(id: i, filename: filename.filenameWithoutSuffix, type: "m4a"))
        }
        
        if currentIndex < 0 || currentIndex >= items.count {
            currentIndex = 0
            currentPlayedSeconds = 0
        }
        
        if duration > 0 {
            progress = currentPlayedSeconds / duration
        }
        setupRemoteTransportControls()
    }
    
    deinit {
        if let progressTimer {
            progressTimer.cancel()
        }
    }
    
    var currentFilename: String {
        guard currentIndex >= 0 && currentIndex < items.count else {
            return ""
        }
        return items[currentIndex].filename
    }
    
    var currentFileType: String {
        guard currentIndex >= 0 && currentIndex < items.count else {
            return ""
        }
        return items[currentIndex].type
    }
    
    func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            if player == nil {
                player = createPlayer(named: currentFilename, ofType: currentFileType)
            }
            if let player = player {
                player.seek(to: CMTime(seconds: currentPlayedSeconds, preferredTimescale: 1))
                setupNowPlayingInfo()
                player.play()
                startProgressTimer()
            }
        } else if let player = player {
            player.pause()
            if let timer = progressTimer {
                timer.cancel()
                self.progressTimer = nil
            }
        }
    }
    
    func playPrev() {
        if currentPlayedSeconds > 10 {
            progress = 0
            seekByProgress()
            return
        }
        play((currentIndex - 1 + items.count) % items.count)
    }
    
    func playNext() {
        play((currentIndex + 1) % items.count)
    }
    
    func play(_ index: Int) {
        guard currentIndex != index || !isPlaying else { return }
        if currentIndex != index {
            currentIndex = index
            currentPlayedSeconds = 0
            player = createPlayer(named: currentFilename, ofType: currentFileType)
        }
        if let player = player {
            setupNowPlayingInfo()
            player.play()
            startProgressTimer()
            isPlaying = true
        }
    }
    
    func seekByProgress() {
        currentPlayedSeconds = duration * progress
        if let player = player {
            player.pause()
            player.seek(to: CMTime(seconds: currentPlayedSeconds, preferredTimescale: 1))
            setupNowPlayingInfo()
            if isPlaying {
                player.play()
            }
        }
    }
    
    func startProgressTimer() {
        progressTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let player = self.player else { return }
                self.currentPlayedSeconds = player.currentTime().seconds
                if !isSeeking {
                    progress = duration > 0 ? self.currentPlayedSeconds / duration : 0
                    if self.currentPlayedSeconds == duration {
                        playNext()
                    }
                }
            }
    }
    
    func createPlayer(named filename: String, ofType ext: String, startFrom: Double = 0) -> AVPlayer? {
        guard let path = Bundle.main.path(forResource: filename, ofType: ext) else {
            print("Error: Audio file not found", filename.filenameWithoutSuffix, ext)
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        
        let asset = AVURLAsset(url: url, options: nil)

        Task {
            do {
                let cm = try await asset.load(.duration)
                let seconds = cm.seconds
                DispatchQueue.main.async {
                    self.duration = seconds.isFinite ? seconds : 0
                }
            } catch {
            }
        }
        
        let playerItem = AVPlayerItem(url: url)
        return AVPlayer(playerItem: playerItem)
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    var playedTimeLabel: String {
        let result = secondsToHoursMinutesSeconds(Int(currentPlayedSeconds))
        var label = result.0 > 0 ? String(format: "%d:", result.0) : ""
        label += String(format:"%d:", result.1)
        label += String(format:"%.2d", result.2)
        return label
    }
    
    var durationTimeLabel: String {
        let result = secondsToHoursMinutesSeconds(Int(timeDisplayMode == .total ? duration : duration - currentPlayedSeconds))
        var label = result.0 > 0 ? String(format: "%d:", result.0) : ""
        label += String(format:"%d:", result.1)
        label += String(format:"%.2d", result.2)
        return timeDisplayMode == .total ? label : "-" + label
    }
    
    func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = String(format: "A Favorite Book - %.3d", (currentIndex + 1))
        
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Stone Octopus"
        
        if let image = UIImage(named: "demo") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }
        }
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlayedSeconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.togglePlay()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.togglePlay()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNext()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self]_ in
            self?.playPrev()
            return .success
        }
        
        commandCenter.seekBackwardCommand.addTarget { [weak self] event in
            if let event = event as? MPSkipIntervalCommandEvent {
                self?.currentPlayedSeconds -= event.interval
            }
            return .success
        }
        
        commandCenter.seekForwardCommand.addTarget { [weak self]event in
            if let event = event as? MPSkipIntervalCommandEvent {
                self?.currentPlayedSeconds += event.interval
            }
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self]event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self?.currentPlayedSeconds = event.positionTime
                return .success
            }
            return .commandFailed
        }
    }
}


struct AudioItem: Identifiable {
    var id: Int
    var filename: String
    var type: String
}
