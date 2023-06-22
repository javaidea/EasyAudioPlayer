//
//  EasySlider.swift
//  EasyAudioPlayer
//
//  Created by Zhou Yang on 6/22/23.
//

import SwiftUI

struct EasySlider: View {
    
    @GestureState var dragOffset: CGSize = .zero
    
    @State var isEditing: Bool = false
    @State var isInitializing: Bool = false
    @State var maxX: CGFloat = 0
    @State var minX: CGFloat = 0
    @State var width: CGFloat = 0

    @Binding var value: CGFloat
    
    private let backgroundColor: Color
    private let foregroundColors: [Color]
    private let thickness: CGFloat
    private let thumbSize: CGSize
    
    private var onEditingChanged: (Bool) -> Void
    
    init(value: Binding<CGFloat>,
         thickness: CGFloat,
         thumbSize: CGSize? = nil,
         foregroundColors: [Color] = [Color.yellow, Color.orange],
         backgroundColor: Color = .black.opacity(0.25),
         onEditingChanged: @escaping (Bool) -> Void) {
        self._value = value
        self.thickness = thickness
        if let thumbSize {
            self.thumbSize = thumbSize
        } else {
            self.thumbSize = CGSize(width: 10, height: thickness * 3)
        }
        self.foregroundColors = foregroundColors
        self.backgroundColor = backgroundColor
        self.onEditingChanged = onEditingChanged
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(backgroundColor)
                .frame(width: width, height: thickness)
            
                .background(
                    GeometryReader {geo -> Color in
                        DispatchQueue.main.async {
                            let frame = geo.frame(in: .local)
                            minX = frame.minX
                            maxX = frame.maxX
                            width = frame.width
                        }
                        return .clear
                    }
                )
            
            Capsule()
                .fill(
                    LinearGradient(colors: foregroundColors, startPoint: .leading, endPoint: .trailing)
                )
                .frame(height: thickness)
                .background(
                    GeometryReader {geo -> Color in
                        DispatchQueue.main.async {
                            let frame = geo.frame(in: .local)
                            minX = frame.minX
                            maxX = frame.maxX
                        }
                        return .clear
                    }
                )
                .allowsTightening(false)
            
            Capsule()
                .fill(.purple.gradient)
                .frame(width: thumbSize.width, height: thumbSize.height)
                .shadow(radius: 1)
                .offset(x: (width - thumbSize.width) * value)
                .allowsTightening(false)
                .onChange(of: dragOffset, perform: { newValue in
                    if newValue == .zero {
                        isEditing = false
                    } else {
                        isEditing = true
                    }
                })
                .onChange(of: isEditing, perform: { newValue in
                    onEditingChanged(newValue)
                })
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($dragOffset, body: { value, gestureState, _ in
                    DispatchQueue.main.async {
                        var offsetX: CGFloat = 0
                        if value.location.x >= minX + thumbSize.width / 2 && value.location.x <= maxX - thumbSize.width {
                            offsetX = value.location.x - thumbSize.width / 2
                        } else if value.location.x < minX {
                            offsetX = minX
                        } else if value.location.x > maxX - thumbSize.width {
                            offsetX = maxX - thumbSize.width
                        }
                        if width > thumbSize.width {
                            self.value = (offsetX - minX) / (width - thumbSize.width)
                        }
                    }
                    gestureState = CGSize(width: value.location.x - value.startLocation.x, height: value.location.y - value.startLocation.y)
                })
        )
    }
}

struct EasySliderExampleContainer: View {
    @State var value: CGFloat = 0
    
    var body: some View {
        EasySlider(
            value: $value,
            thickness: 10,
            onEditingChanged: { _ in
            }
        )
    }
}

struct EasySlider_Previews: PreviewProvider {
    static var previews: some View {
        EasySliderExampleContainer()
    }
}
