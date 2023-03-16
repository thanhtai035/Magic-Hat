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
import AVFoundation

struct MainMenu: View {
    @State private var newGame = false
    @State private var nameModal = false
    @State private var name = ""
    @State private var invalid_name = false
    @State private var leaderboard = false
    @State private var howToPlay = false
    @AppStorage("currentName") var currentName = ""
    @State private var isContinued = false
    var BackgroundPlayer: AVAudioPlayer?

    
    init () {
        let path = Bundle.main.path(forResource: "background1.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            BackgroundPlayer = try AVAudioPlayer(contentsOf: url)
            BackgroundPlayer?.numberOfLoops = -1
            BackgroundPlayer?.play()
        } catch {
            print("Cannot print background mp3")
        }
        
        _isContinued = State(initialValue: (UserDefaults.standard.object(forKey: "currentPlayer") != nil))
    }

    func check_name() {
        if (name.count < 2 || name.count > 7) {
            invalid_name = true
        } else {
            invalid_name = false
        }
    }
    
    var body: some View {
        ZStack() {
            Color.yellow.ignoresSafeArea()
            VStack(spacing: 30){
                if (isContinued) {
                    Button{
                        newGame = true
                        BackgroundPlayer?.stop()
                        playSound(sound: "sound1", type: "mp3", loop: false)
                    }
                    label: {
                        Text("Continue")
                            .foregroundColor(.white)
                            .font(.system(size: 25, weight: .heavy, design: .rounded))
                            .background(
                                Capsule().fill(.black)
                                    .frame(width: 250, height: 50, alignment: .center)
                            )
                    }
    
                }
                
                Button{
                    nameModal = true
                }
                label: {
                    Text("Start New Game")
                        .foregroundColor(.white)
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        .background(
                            Capsule().fill(.black)
                                .frame(width: 250, height: 50, alignment: .center)
                        )
                }
                
                Button{
                    leaderboard = true
                }
                label: {
                    Text("Leaderboard")
                        .foregroundColor(.white)
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        .background(
                            Capsule().fill(.black)
                                .frame(width: 250, height: 50, alignment: .center)
                        )
                }
                Button{
                    howToPlay = true
                }
                label: {
                    Text("How To Play")
                        .foregroundColor(.white)
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        .background(
                            Capsule().fill(.black)
                                .frame(width: 250, height: 50, alignment: .center)
                        )
                }
            }
            
            if(nameModal) {
                ZStack{
                    
                    VStack{
                        Text("Enter your name:")
                            .font(.system(.title, design: .rounded))
                            .foregroundColor(.black)
                            .padding()
                            .frame(minWidth: 280, idealWidth: 280, maxWidth: 320)
                            .background(.white.opacity(0.4))
                    
                        VStack {
                        
                        TextField("",text: $name)
                            .foregroundColor(.black)
                            .font(.system(size: 25,  design: .rounded))
                            .frame(width:120)
                            .background(
                                Capsule().fill(Color.gray.opacity(0.3))
                                    .frame(width: 200, height: 50, alignment: .center)
                            )
                            Spacer()
                            Button {
                                check_name()
                                if (!invalid_name) {
                                    nameModal = false
                                    invalid_name = false
                                    currentName = name
                                    name = ""
                                    playSound(sound: "sound1", type: "mp3", loop: false)
                                    BackgroundPlayer?.stop()
                                    UserDefaults.standard.removeObject(forKey: "currentPlayer")
                                    newGame = true
                                }
                            } label: {
                                Text("START")
                                    .foregroundColor(.white)
                                    .font(.system(size: 25, weight: .heavy,design: .rounded))
                                    .background(
                                        Capsule().fill(.red)
                                            .frame(width: 150, height: 50, alignment: .center)
                                        
                                    )
                            }
                            Spacer()
                        }
                        if (invalid_name) {
                            Text("Please enter your name from 2 to 7 characters")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        }
                        Spacer()

                    }
                    .frame(width: 280, height: 250,alignment: .center)
                    .background(.white)
                    .cornerRadius(20)
                }
            }
        }.fullScreenCover(isPresented: $newGame, onDismiss: {
            BackgroundPlayer?.play()
            isContinued = (UserDefaults.standard.object(forKey: "currentPlayer") != nil)
        }) {
            ContentView()
        }.fullScreenCover(isPresented: $leaderboard) {
            LeaderBoard()
        }.fullScreenCover(isPresented: $howToPlay) {
            HowToPlay()
        }
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
    }
}
