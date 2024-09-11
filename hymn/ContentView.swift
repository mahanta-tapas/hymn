//
//  ContentView.swift
//  hymn
//
//  Created by Tapas Mahanta on 6/18/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    @State var record = false
    @State var session: AVAudioSession!
    @State var recorder: AVAudioRecorder!
    @State var alert = false
    @State var audios: [URL] = []
    @State var microphonePermissionGranted = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(self.audios, id: \.self) { i in
                    Text(i.relativeString)
                }
                
                Button(action: {
                    if self.record {
                        self.recorder.stop()
                        self.record.toggle()
                        self.getAudios()
                        return
                    }
                    
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let filName = url.appendingPathComponent("myRcd\(self.audios.count + 1).m4a")
                    
                    let settings = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 12000,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]
                    
                    self.recorder = try? AVAudioRecorder(url: filName, settings: settings)
                    
                    if self.microphonePermissionGranted {
                        self.recorder.record()
                        self.record.toggle()
                    } else {
                        self.alert.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                        
                        if self.record {
                            Circle()
                                .stroke(Color.white, lineWidth: 6)
                                .frame(width: 85, height: 85)
                        }
                    }
                }
                .padding(.vertical, 25)
            }
            .navigationBarTitle("Record Audio")
        }
        .alert(isPresented: self.$alert) {
            Alert(title: Text("Error"), message: Text("Enable Access"))
        }
        .onAppear {
            self.session = AVAudioSession.sharedInstance()
            do {
                try self.session.setCategory(.playAndRecord)
                self.session.requestRecordPermission { status in
                    DispatchQueue.main.async {
                        self.microphonePermissionGranted = status
                        if !status {
                            self.alert.toggle()
                        } else {
                            self.getAudios()
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getAudios() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            self.audios.removeAll()
            
            for i in result {
                self.audios.append(i)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
