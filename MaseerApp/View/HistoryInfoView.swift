//
//  HistoryInfoView.swift
//  MaseerApp
//
//  Created by Ghadeer Fallatah on 09/06/1447 AH.
//

import SwiftUI

struct HistoryInfoView: View {
    var body: some View {
        
        ZStack{
            Color.black.ignoresSafeArea()
            
            VStack{
                Spacer().frame(height: 170)
                GlassEffectContainer(content: {
                    VStack{
                        Text("Dummy text").font(Font.largeTitle.bold()).foregroundColor(Color.white )
                    }
                }).frame(width: 396 , height: 792)
                    .glassEffect(.clear.tint(Color.black.opacity(0.1)), in: .rect(cornerRadius: 34))
                    
                
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .foregroundColor(.white)

    }
    
}


#Preview {
    HistoryInfoView()
}
