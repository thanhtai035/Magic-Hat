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

struct LeaderBoard: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var leaderboard : [Player] = []

    init() {
        if let currentPlayer = UserDefaults.standard.object(forKey: "leaderboard") as? Data {
            let decoder = JSONDecoder()

            if var players = try? decoder.decode([Player].self, from: currentPlayer) {
                _leaderboard = State.init(initialValue: players)
            }
        }
    }
    
    var body: some View {
        ZStack{
            Color.yellow.ignoresSafeArea()
            VStack {
                Text("Leaderboard")
                    .foregroundColor(.black)
                    .font(.system(size: 40))
                    .fontWeight(.heavy)

                HStack{
                    Text("Name")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .fontWeight(.heavy)
                        .padding()
                    Spacer()
                    Text("Score")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .fontWeight(.heavy)
                    Spacer()
                    Text("Milestone")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .fontWeight(.heavy)
                        .padding(10)
                }
                Divider()
                ForEach (leaderboard, id: \.name) {
                    player in
                    HStack (spacing:10){
                        Text(player.name)
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .frame(width:50)
                        Text(String(player.Score))
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .frame(width:150)
                        HStack(){
                            if (player.Milestone[0]) {
                                Image("trophy1")
                                    .resizable()
                                    .frame(width:20, height: 30)
                            }
                            if (player.Milestone[1]) {
                                Image("trophy2")                                               .resizable()
                                    .frame(width:20, height: 30)
                            }
                            if (player.Milestone[2]) {
                                Image("trophy3")                                                .resizable()
                                    .frame(width:20, height: 30)
                            }
                            if (player.Milestone[3]) {
                                Image("trophy4")                                                     .resizable()
                                    .frame(width:20, height: 30)
                            }
                        }.frame(width:100)
                    }
                }
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
            }
        }
    }
}

struct LeaderBoard_Previews: PreviewProvider {
    static var previews: some View {
        LeaderBoard()
    }
}
