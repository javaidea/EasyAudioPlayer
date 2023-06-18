//
//  AudioPlayerView.swift
//  EasyAudioPlayer
//
//  Created by Zhou Yang on 6/17/23.
//

import SwiftUI

struct AudioPlayerView: View {
    
    enum constants {
        static let titleFontWidth: CGFloat = 20
        static let buttonWidth: CGFloat = 30
    }
    
    @StateObject var vm = AudioPlayerViewModel()
    
    @State var isDraggingProgress = false
    @State var isShowingList = false
    
    var body: some View {
        VStack(spacing: 40) {
            
            Image("demo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.44)
            
            Text(vm.currentFilename)
                .font(Font.custom("Helvetica Neue", size: 30))
                .fontWeight(.semibold)
            
            VStack {
                Slider(value: $vm.progress, onEditingChanged: { editing in
                    if !editing {
                        vm.seekByProgress()
                    }
                    vm.isSeeking = editing
                })
                .tint(Color.yellow.gradient)
                
                HStack {
                    Text(vm.playedTimeLabel)
                        .font(Font.custom("Helvetica Neue", size: 18))
                    
                    Spacer()
                    
                    Text(vm.durationTimeLabel)
                        .font(Font.custom("Helvetica Neue", size: 18))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if vm.timeDisplayMode == 0 {
                                vm.timeDisplayMode = 1
                            } else {
                                vm.timeDisplayMode = 0
                            }
                        }
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.6)
            
            actions
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(Color.white)
        .overlay(alignment: .top) {
            HStack {
                Spacer()
                Button {
                    isShowingList.toggle()
                } label:  {
                    Image(systemName: "circle.hexagongrid.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 64)
            .padding(.trailing, 24)
        }
        .sheet(isPresented: $isShowingList) {
            PlayListView(vm: vm) { index in
                isShowingList.toggle()
                vm.play(index)
            }
        }
    }
    
    var actions: some View {
        HStack {
            Button {
                vm.playPrev()
            } label:  {
                Image(systemName: "backward.end.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: constants.buttonWidth)
            
            Spacer()
            
            Button {
                vm.togglePlay()
            } label:  {
                vm.isPlaying ? Image(systemName: "pause.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit) :
                Image(systemName: "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: constants.buttonWidth)
            
            Spacer()
            
            Button {
                vm.playNext()
            } label:  {
                Image(systemName: "forward.end.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: constants.buttonWidth)
        }
        .frame(height: 40)
        .frame(width: UIScreen.main.bounds.width * 0.6)
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
