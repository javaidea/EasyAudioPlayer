//
//  ContentView.swift
//  EasyAudioPlayer
//
//  Created by Zhou Yang on 6/17/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            AudioPlayerView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.blue.gradient)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
