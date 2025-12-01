//
//  HomepageView.swift
//  MaseerApp
//
//  Created by Bushra Hatim Alhejaili on 01/12/2025.
//

import SwiftUI

struct HomepageView: View {
    
    var buttonWidth: CGFloat = 358
    var buttonHeight: CGFloat = 48
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack {
                
                // Top spacer pushes content toward center
                Spacer()
                    
                
                // Centered texts
                VStack(spacing: 7) {
                    Text("مَسير")
                        .font(.custom("Geeza Pro", size: 36))
                        .fontWeight(.regular)
                        .foregroundColor(Color.white)
                        .padding(7)
                    
                    Text("انت تعرف وِجهتك..ومَسير يعرف ملامحها")
                        .font(.custom("Geeza Pro", size: 17))
                        .fontWeight(.bold)
                        .foregroundColor(Color.gray)
                }
                .multilineTextAlignment(.center)

               
                // Spacer between texts and buttons
                Spacer()
                    
                
                // Bottom buttons grouped together
                VStack(spacing: 19) {
                    Button(action: {
                        
                    }) {
                        Text("ابدا")
                            .font(.custom("Geeza Pro", size: 21))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: buttonWidth, height: buttonHeight)
                    .glassEffect(.clear.tint(.black.opacity(0.65)))
                    .background(
                        RoundedRectangle(cornerRadius: 1000, style: .continuous)
                            .fill(.button)
                    )
                    
                    Button(action: {
                        
                    }) {
                        Text("السّجلات السابقة")
                            .font(.custom("Geeza Pro", size: 21))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: buttonWidth, height: buttonHeight)
                    .glassEffect(.clear.tint(.black.opacity(0.65)))
                    .background(
                        RoundedRectangle(cornerRadius: 1000, style: .continuous)
                            .fill(.darkishGrey)
                    )
                }
                // Control how far from the very bottom edge the buttons sit
                .padding(.bottom, 50) // adjust 24–40 to taste
                
            }
            
        }
    }
}

#Preview {
    HomepageView()
}
