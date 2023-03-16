/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author:Le Thanh Tai
  ID: Your student id s3760615
  Created  date: 24/8/2022
  Last modified: 28/8/2002
  Acknowledgement:
 github.com/TomHuynhSG/RMIT_Casino/
*/

import SwiftUI

struct HowToPlay: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.yellow.ignoresSafeArea()
            VStack(spacing:30) {
                Text("How To Play")
                    .foregroundColor(.black)
                    .font(.system(size: 40))
                    .fontWeight(.heavy)
                Text("In this game, you will have to choose the correct hat with the rabbit in it out of three hats displayed. When you pressed button to start the game, the game will shuffle randomly the hats and when the shuffling stops, you will have to choose one hat.\nBased on the difficulty, the speeds and the rate of hard shuffle increases but the score you get after each round also higher\nYou can click the setting button on the top right to change the difficulty").foregroundColor(.black)
                    .font(.system(size: 20))
                Spacer()
                HStack {
                   Spacer()
                   Button {
                       presentationMode.wrappedValue.dismiss()
                    } label: {
                       Image(systemName: "x.circle.fill")
                           .foregroundColor(.black)
                           .font(.system(size: 30))
                           .padding()
                    }
                }
               
            }.frame(width: 250)
        }
    }
}

struct HowToPlay_Previews: PreviewProvider {
    static var previews: some View {
        HowToPlay()
    }
}
