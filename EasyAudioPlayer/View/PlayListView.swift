//
//  PlayListView.swift
//  EasyAudioPlayer
//
//  Created by Zhou Yang on 6/17/23.
//

import SwiftUI

struct PlayListView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: AudioPlayerViewModel
    
    var selectItem: (Int) -> Void
    let columns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
            }
            .padding(.bottom, 16)
            ScrollView(showsIndicators: false) {
                ScrollViewReader { scrollViewProxy in
                    LazyVGrid(columns: columns, alignment: .center, spacing: 24) {
                        ForEach(vm.items) { item in
                            Button {
                                selectItem(item.id)
                            } label: {
                                Text(item.filename)
                                    .font(Font.custom("Helvetica Neue", size: 16))
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(vm.currentIndex == item.id ?
                                                (vm.isPlaying ? Color.pink : Color.purple) :
                                                    Color.indigo)
                                    .cornerRadius(6)
                                    .shadow(radius: 3)
                            }
                            .id(item.id)
                        }
                    }
                    .onAppear {
                        scrollViewProxy.scrollTo(vm.currentIndex)
                    }

                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding([.top, .horizontal], 24)
        .foregroundColor(.white)
        .background(Color.mint.gradient)
    }
}

struct PlayListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayListView(vm: AudioPlayerViewModel()) { _ in
            
        }
    }
}
