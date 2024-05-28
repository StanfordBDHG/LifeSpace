//
//  RefreshIcon.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 5/27/24.
//

import SwiftUI


struct RefreshIcon: View {
    @State private var rotationAngle = 0.0
    
    var body: some View {
        VStack {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(50)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
                .onDisappear {
                    rotationAngle = 0
                }
        }
    }
}

#Preview {
    RefreshIcon()
}
