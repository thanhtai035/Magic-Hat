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
	
struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode

    private var answer_track = [2,3,1,1,3,2]
    //Matrix explain:
    //[[1,2,3],[1,3,2],[2,1,3],[2,3,1], [3,1,2], [3,2,1]]
    private var position_matrix =
    [
    [[-60,0],[0,0],[60,0]],
    [[-50,0],[135,0],[-80,0]],
    [[90,0],[-140,0],[60,0]],
    [[220,0],[-140,0],[-85,0]],
    [[90,0],[135,0],[-220,0]],
    [[215,0],[0,0],[-220,0]]
    ]
    var BackgroundPlayer: AVAudioPlayer?
    
    private var milestoneMessage =
    ["You just achieved your first win",
     "You just got the achievement reaching difficulty 5",
     "You just got the achievement having at least 1000 points",
     "You just got the achievement passing the highest difficulty"
    ]
    
    @AppStorage("currentName") var currentName = ""
    @State private var hat1 = false
    @State private var hat2 = true
    @State private var hat3 = false
                                    
    @State private var count = 10
    @State private var animation_delay = false
    @State private var currentPosition = 0
    @State private var difficulty = 1
    @State private var shuffle_speed = 3.0
    @State private var shuffle_delay = 3
    @State private var score = 0
    @State private var milestone = [false,false,false,false]
    @State private var message :String = ""
    
    @State private var swap2_rate = 100
    @State private var swap3_rate = 0
    
    @State private var finish = false
    @State private var chosen = 0
    
    @State private var gameOver = false
    @State private var mainMenu = false
    
    @State private var continueModal = false
    @State private var milestoneModal = false
    @State private var settingModal = false

    
    // MARK: Functions
        // MARK: Initialize
    init() {
        let path = Bundle.main.path(forResource: "background2.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            BackgroundPlayer = try AVAudioPlayer(contentsOf: url)
            BackgroundPlayer?.play()
            BackgroundPlayer?.numberOfLoops = -1
        } catch {
            print("Cannot print background mp3")
        }
        
        if let currentPlayer = UserDefaults.standard.object(forKey: "currentPlayer") as? Data {
            let decoder = JSONDecoder()
           
            if var player = try? decoder.decode(Player.self, from: currentPlayer) {
                _continueModal = State(initialValue: true)
                _difficulty = State(initialValue: player.difficulty)
                _score = State(initialValue: player.Score)
                _milestone = State(initialValue: player.Milestone) 
            }
        }
    }
    
        // MARK: Swap 2 objects
    func swap_2() {
        var buf : [Int] = []
        if (difficulty < 20) {
            switch currentPosition {
            case 0:
                buf = [1,5,2]
            case 1:
                buf = [4,3,0]
            case 2:
                buf = [0,4,3]
            case 3:
                buf = [5,1,2]
            case 4:
                buf = [1,2,5]
            case 5:
                buf = [0,4,3]
            default:
                buf = [1,5,2]
            }
        }
        currentPosition = buf[Int.random(in: 0...2)]
    }
    
    //MARK: Swap 3 objects
    func swap_3() {
        if (difficulty < 20) {
            var buf : [Int] = []
            if (difficulty < 20) {
                switch currentPosition {
                case 0:
                    buf = [3,4]
                case 1:
                    buf = [2,5]
                case 2:
                    buf = [1,5]
                case 3:
                    buf = [0,4]
                case 4:
                    buf = [0,3]
                case 5:
                    buf = [0,4]
                default:
                    buf = [1,2]
                }
            }
            currentPosition = buf[Int.random(in: 0...1)]
        } else {
        }
    }
    
        // MARK: Check selection of the user
    func check_answer () {
        finish = false
        
        if (answer_track[currentPosition] == chosen) {
            playSound(sound: "blink", type: "mp3", loop: false)

                score = score + (100*difficulty)
                
                //MARK: Milestone validate
                if (!milestone[0]) {
                    milestone[0] = true
                    milestoneModal = true
                    if (message == "") {
                        message = message + milestoneMessage[0]
                    } else {
                        message = message + "\n\n" + milestoneMessage[0]
                    }
                }
                if(!milestone[1] && difficulty > 5) {
                    milestone[1] = true
                    milestoneModal = true
                    if (message == "") {
                        message = message + milestoneMessage[1]
                    } else {
                        message = message + "\n\n" + milestoneMessage[1]
                    }
                }
                if(!milestone[2] && score >= 1000) {
                    milestone[2] = true
                    milestoneModal = true
                    if (message == "") {
                        message = message + milestoneMessage[2]
                    } else {
                        message = message + "\n\n" + milestoneMessage[2]
                    }
                }
                if (!milestone[3] && difficulty == 10) {
                    milestone[3] = true
                    milestoneModal = true
                    if (message == "") {
                        message = message + milestoneMessage[3]
                    } else {
                        message = message + "\n\n" + milestoneMessage[3]
                    }
                }
                if (difficulty < 10) {
                    difficulty = difficulty + 1
                }
                difficulty_configuration()
            
            //MARK: Handle UserDefaults data
            let currentPlayer = Player(name: currentName, Score: score, Milestone: milestone, difficulty: difficulty)
            if let currentData = UserDefaults.standard.object(forKey: "leaderboard") as? Data {
                let decoder = JSONDecoder()
                if var leaderboard = try? decoder.decode([Player].self, from: currentData) {
                        let pos = leaderboard.firstIndex(where: {$0.name == currentName})

                        if (pos == nil) {
                            leaderboard.append(currentPlayer)
                        } else {
                            if (leaderboard[pos!].Score < score) {
                                leaderboard[pos!] = currentPlayer
                            }
                        }
                    leaderboard.sort{ $0.Score >	 $1.Score }
                    if (leaderboard.count == 11) {
                        leaderboard.remove(at: 10)
                    }
                    print(leaderboard)

                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(leaderboard) {
                        UserDefaults.standard.set(encoded, forKey: "leaderboard")
                    }
                    if let encodedCurrent = try? encoder.encode(currentPlayer) {
                        UserDefaults.standard.set(encodedCurrent, forKey: "currentPlayer")
                    }
                    print(currentPlayer)
                } else {
                    let encoder = JSONEncoder()
                    let firstData : [Player] = [Player(name:currentName, Score: score)]
                    if let encoded = try? encoder.encode(firstData) {
                        UserDefaults.standard.set(encoded, forKey: "leaderboard")
                    }
                    if let encodedCurrent = try? encoder.encode(currentPlayer) {
                        UserDefaults.standard.set(encodedCurrent, forKey: "currentPlayer")
                    }
                }
            } else {
                let encoder = JSONEncoder()
                let firstData : [Player] = [Player(name:currentName, Score: score)]
                if let encoded = try? encoder.encode(firstData) {
                    UserDefaults.standard.set(encoded, forKey: "leaderboard")
                }
                if let encodedCurrent = try? encoder.encode(currentPlayer) {
                    UserDefaults.standard.set(encodedCurrent, forKey: "currentPlayer")
                }
            }
            animation_delay = false
            
            if (answer_track[currentPosition] == 1) {
                hat1 = true
            } else if (answer_track[currentPosition] == 2) {
                hat2 = true
            } else {
                hat3 = true
            }
            currentPosition = 0
        } else {
            playSound(sound: "gameover", type: "mp3",loop: false)

            UserDefaults.standard.removeObject(forKey: "currentPlayer")
            gameOver = true
        }
        hat1 = false
        hat3 = false
        hat2 = true
    }
    
    func difficulty_configuration() {
        switch difficulty {
        case 1:
            shuffle_delay = 3
            shuffle_speed = 3
            count =  10
            swap2_rate = 100
            swap3_rate = 0
        case 2:
            shuffle_delay = 3
            shuffle_speed = 2.5
            count =  10
            swap2_rate = 100
            swap3_rate = 0
        case 3:
            shuffle_delay = 2
            shuffle_speed = 2.5
            count =  12
            swap2_rate = 80
            swap3_rate = 20
        case 4:
            shuffle_delay = 2
            shuffle_speed = 2
            count =  15
            swap2_rate = 80
            swap3_rate = 20
        case 5:
            shuffle_delay = 2
            shuffle_speed = 2
            count =  20
            swap2_rate = 70
            swap3_rate = 30
        case 6:
            shuffle_delay = 2
            shuffle_speed = 1.5
            count =  20
            swap2_rate = 60
            swap3_rate = 40
        case 7:
            shuffle_delay = 2
            shuffle_speed = 1.5
            count =  20
            swap2_rate = 50
            swap3_rate = 50
        case 8:
            shuffle_delay = 1
            shuffle_speed = 1.5
            count =  20
            swap2_rate = 30
            swap3_rate = 70
        case 9:
            shuffle_delay = 1
            shuffle_speed = 1
            count =  20
            swap2_rate = 30
            swap3_rate = 70
        case 10:
            shuffle_delay = 1
            shuffle_speed = 1
            count =  20
            swap2_rate = 0
            swap3_rate = 100
        default:
            shuffle_delay = 3
            shuffle_speed = 3
            count =  10
        }
    }
    

    //MARK: VIEW
    var body: some View {
        ZStack {

            Color.yellow.ignoresSafeArea()

        
            // MARK: - GAME UI
           VStack(spacing: 20) {
               //MARK: Setting button
                HStack {
                   Spacer()
                   Button {
                       settingModal.toggle()
                    } label: {
                       Image(systemName: "gearshape.fill")
                           .foregroundColor(.black)
                           .font(.system(size: 30))
                           .padding()
                    }
                }
               
                Text("Difficulty: " + String(difficulty)).foregroundColor(.white)
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                    .background(
                        Capsule().fill(.black)
                            .frame(width: 200, height: 50, alignment: .center)
                    )

                Text("Score: " + String(score)).foregroundColor(.black)
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                    .offset(x:70, y: 50)
            	
                Spacer()
            
               //MARK: Hat images
                HStack{
                    Image(!self.hat1 ? "hat1" : "hat2")
                             .resizable()
                             .scaledToFit()
                             .frame(height:70)
                             .offset(x: CGFloat(position_matrix[currentPosition][0][0]), y: CGFloat(position_matrix[currentPosition][0][1]))
                             .animation(.default.delay(shuffle_speed))
                        
                    Image(!self.hat2 ? "hat1" : "hat2")
                             .resizable()
                             .scaledToFit()
                             .frame(height:70)
                             .offset(x: CGFloat(position_matrix[currentPosition][1][0]), y: CGFloat(position_matrix[currentPosition][1][1]))
                             .animation(.default.delay(shuffle_speed))
              
                    Image(!self.hat3 ? "hat1" : "hat2")
                             .resizable()
                             .scaledToFit()
                             .frame(height:70)
                             .offset(x: CGFloat(position_matrix[currentPosition][2][0]), y: CGFloat(position_matrix[currentPosition][2][1]))
                             .animation(.default.delay(shuffle_speed))
                }.padding()
                
                //MARK: Choose buttons
                if (finish) {
                    HStack(spacing:20){
                        Button {
                            chosen = 1
                            check_answer()
                        } label: {
                            Image("choose_button")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width:100)
                                  
                        }
                        
                        Button {
                            chosen = 2
                            check_answer()
                        } label: {
                            Image("choose_button")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width:100)
                        }
                        
                        Button {
                            chosen = 3
                            check_answer()
                        } label: {
                            Image("choose_button")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width:100)
                        }
                    }
                    }
                    Spacer()
                    
              
                   if (!animation_delay) {
                       Button {
                        animation_delay = true
                        hat1 = false
                        hat2 = false
                        hat3 = false
                        let queue = DispatchQueue(label: "queue_name")
                               queue.async {
                               var num = 0
                                sleep(2)
                               while(num < count) {
                                       let rate_generate = Int.random(in: 0...100)
                                       if (rate_generate < swap3_rate) {
                                           swap_3()
                                       } else {
                                           swap_2()
                                       }
                                        
                                   num = num + 1
                                   sleep(UInt32(shuffle_delay))
                                   print("Current Position: " + String(answer_track[currentPosition]))
                                   playSound(sound: "sound1", type: "mp3", loop: false)

                               }
                               sleep(2)
                               finish = true
                               }
                       } label: {
                       Text("START")
                                   .foregroundColor(.white)
                                   .font(.system(size: 25, weight: .heavy, design: .rounded))
                                   .background(
                                       Capsule().fill(.black)
                                           .frame(width: 250, height: 50, alignment: .center)
                                   )
                           }
                   }
                    
                    Spacer()
            }
           
                //MARK: Game Over Modal
            if(gameOver){

            ZStack{
               VStack{
                   Text("GAME OVER")
                       .font(.system(.title, design: .rounded))
                       .fontWeight(.heavy)
                       .foregroundColor(Color.white)
                       .padding()
                       .frame(minWidth: 280, idealWidth: 280, maxWidth: 320)
                       .background(.black)
                   
                   Spacer()
                   
                   
                   Button{
                       presentationMode.wrappedValue.dismiss()
                   }
                   label: {
                       Text("Back To Main Menu")
                           .foregroundColor(.black)
                           .font(.system(size: 25, design: .rounded))
                           .background(
                            Capsule().fill(.gray.opacity(0.3))
                                   .frame(width: 250, height: 50, alignment: .center)
                           )
                       }
                   
                   Spacer()
               }
               .frame(minWidth: 280, idealWidth: 280, maxWidth: 320, minHeight: 280, idealHeight: 300, maxHeight: 350, alignment: .center)
               .background(.white)
               .cornerRadius(20)
               }.onAppear(perform: {
                 })
               }
           
                //MARK: Continue Modal
              if(continueModal) {
                  ZStack{
                      VStack{
                          Text("Welcome Back, " + currentName)
                              .font(.system(size: 25, design: .rounded))
                              .fontWeight(.heavy)
                              .foregroundColor(Color.white)
                              .padding()
                              .frame(minWidth: 280, idealWidth: 280, maxWidth: 320)
                              .background(.black)
                  
                      Spacer()
                  
                      Text("Your current score: " + String(score))
                          .foregroundColor(.black)
                          .font(.system(size: 25, design: .rounded))
                          
                      Spacer()
                      
                      Button{
                          continueModal = false
                          difficulty_configuration()
                  }
                  label: {
                      Text("Continue")
                          .foregroundColor(.black)
                          .font(.system(size: 25, design: .rounded))
                          .background(
                           Capsule().fill(.gray.opacity(0.3))
                                  .frame(width: 250, height: 50, alignment: .center)

                          )
                      }
                  Spacer()
              }
              }
              .frame(minWidth: 280, idealWidth: 280, maxWidth: 320, minHeight: 280, idealHeight: 300, maxHeight: 350, alignment: .center)
              .background(.white)
              .cornerRadius(20)
          }
           
                //MARK: Milestone Modal
           if(milestoneModal) {
           ZStack{
               VStack{
                   Text("Congratulations")
                       .font(.system(.title, design: .rounded))
                       .fontWeight(.heavy)
                       .foregroundColor(Color.white)
                       .padding()
                       .frame(minWidth: 280, idealWidth: 280, maxWidth: 320)
                       .background(.black)
                   
                   Spacer()
               
                   ScrollView {
                       HStack(spacing: 5) {
                           if (milestone[0]) {
                               Image("trophy1")
                                   .resizable()
                                   .frame(width:30, height: 30)
                           }
                           if (milestone[1]) {
                               Image("trophy2")                                               .resizable()
                                   .frame(width:30, height: 30)
                           }
                           if (milestone[2]) {
                               Image("trophy3")                                                .resizable()
                                   .frame(width:30, height: 30)
                           }
                           if (milestone[3]) {
                               Image("trophy4")                                                     .resizable()
                                   .frame(width:30, height: 30)
                           }
                       }
                       VStack (spacing: 20) {
                          
                           Text(message)
                               .foregroundColor(.black)
                               .font(.system(size: 25, design: .rounded))
                               .frame(width: 250)
                           }
                   }.frame(width: 280, height: 150)
                       
                   Spacer()
                   
                   Button{
                       milestoneModal = false
                       message = ""
                   }
                   label: {
                       Text("Continue")
                           .foregroundColor(.black)
                           .font(.system(size: 25, design: .rounded))
                           .background(
                            Capsule().fill(.gray.opacity(0.3))
                                   .frame(width: 250, height: 50, alignment: .center)
                           )
                       }
                   
                   Spacer()
               }
               }
               .frame(minWidth: 280, idealWidth: 280, maxWidth: 320, minHeight: 280, idealHeight: 300, maxHeight: 350, alignment: .center)
               .background(.white)
               .cornerRadius(20)
           }
            
            //MARK: Setting Modal
            if (settingModal){
                ZStack{
                    VStack{
                        Text("Setting")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.heavy)
                            .foregroundColor(Color.white)
                            .padding()
                            .frame(minWidth: 280, idealWidth: 280, maxWidth: 320)
                            .background(.black)
                        
                        Spacer()
                    
                        Text("Difficulty:")
                            .font(.system(size: 35))
                            .fontWeight(.heavy)
                            .foregroundColor(.black)

                        if(!animation_delay) {
                            HStack (spacing: 20) {
                                Button {
                                    if (difficulty < 10) {
                                        difficulty = difficulty + 1
                                        difficulty_configuration()
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .foregroundColor(.black)
                                        .font(.system(size: 35))
                                        .padding()
                                }
                                
                                Text(String(difficulty))
                                    .font(.system(size: 35))
                                    .foregroundColor(.black)
                                
                                Button {
                                    if(difficulty > 0) {
                                        difficulty = difficulty - 1
                                        difficulty_configuration()
                                    }
                                } label: {
                                    Image(systemName: "minus")
                                        .foregroundColor(.black)
                                        .font(.system(size: 35))
                                        .padding()
                                }
                            }
                        } else {
                            Text("Please wait until the end of round to change the difficulty")
                                .foregroundColor(.black)
                                .font(.system(size: 25))
                                .multilineTextAlignment(.center)
                        }
                            
                        Spacer()
                        
                        Button{
                            presentationMode.wrappedValue.dismiss()
                        }
                        label: {
                            Text("Back to Main Menu")
                                .foregroundColor(.black)
                                .font(.system(size: 25, design: .rounded))
                                .background(
                                 Capsule().fill(.gray.opacity(0.3))
                                        .frame(width: 250, height: 50, alignment: .center)
                                )
                            }
                        
                        Spacer()
                    }
                    }
                    .frame(minWidth: 280, idealWidth: 280, maxWidth: 320, minHeight: 280, idealHeight: 300, maxHeight: 350, alignment: .center)
                    .background(.white)
                    .cornerRadius(20)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
