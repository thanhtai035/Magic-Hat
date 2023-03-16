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
import AVFoundation

var audioPlayer: AVAudioPlayer?

func playSound(sound: String, type: String, loop: Bool) {
  if let path = Bundle.main.path(forResource: sound, ofType: type) {
    do {
        audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        audioPlayer?.play()
        
    } catch {
      print("ERROR: Could not find and play the sound file!")
    }
  }
}

func playBackground(sound: String, type: String) {
  
}
