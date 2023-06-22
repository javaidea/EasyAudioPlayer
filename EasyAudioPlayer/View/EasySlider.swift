//
//  EasySlider.swift
//  EasyAudioPlayer
//
//  Created by Zhou Yang on 6/22/23.
//

import SwiftUI

struct EasySlider: View {
    
    @GestureState var dragOffset: CGSize = .zero
    
    @State var minX: CGFloat = 0
    @State var maxX: CGFloat = 0

    @Binding var value: CGFloat
    @State var isEditing: Bool = false
    
    let width: CGFloat
    let height: CGFloat
    let foregroundColors: [Color]
    let backgroundColor: Color
    let thumbSize: CGSize
    
    var onEditingChanged: (Bool) -> Void
    
    init(value: Binding<CGFloat>,
         size: CGSize,
         thumbSize: CGSize? = nil,
         foregroundColors: [Color] = [Color.yellow, Color.orange],
         backgroundColor: Color = .black.opacity(0.25),
         onEditingChanged: @escaping (Bool) -> Void) {
        self.init(value: value,
                  width: size.width,
                  height: size.height,
                  foregroundColors: foregroundColors,
                  backgroundColor: backgroundColor,
                  onEditingChanged: onEditingChanged)
    }
    
    init(value: Binding<CGFloat>,
         width: CGFloat,
         height: CGFloat,
         thumbSize: CGSize? = nil,
         foregroundColors: [Color] = [Color.yellow, Color.orange],
         backgroundColor: Color = .black.opacity(0.25),
         onEditingChanged: @escaping (Bool) -> Void) {
        self._value = value
        self.width = width
        self.height = height
        if let thumbSize {
            self.thumbSize = thumbSize
        } else {
            self.thumbSize = CGSize(width: 10, height: height * 3)
        }
        self.foregroundColors = foregroundColors
        self.backgroundColor = backgroundColor
        self.onEditingChanged = onEditingChanged
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(backgroundColor)
                .frame(width: width, height: height)
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
            
            Capsule()
                .fill(
                    LinearGradient(colors: foregroundColors, startPoint: .leading, endPoint: .trailing)
                )
                .frame(width: width * value, height: height)
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
    
//    func updateThumbPos() {
//        if value > 0 && width > thumbSize.width {
//            offsetX = (width - thumbSize.width) * value + minX
//        }
//    }
}

struct EasySliderExampleContainer: View {
    @State var value: CGFloat = 0
    
    var body: some View {
        EasySlider(
            value: $value,
            width: UIScreen.main.bounds.width * 0.5,
            height: 10,
//            thumbSize: .init(width:20, height: 50),
            onEditingChanged: { editing in
            }
        )
    }
}

struct EasySlider_Previews: PreviewProvider {
    static var previews: some View {
        EasySliderExampleContainer()
    }
}
