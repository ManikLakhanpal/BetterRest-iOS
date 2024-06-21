//
//  ContentView.swift
//  BetterRest
//
//  Created by Manik Lakhanpal on 11/06/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWaketTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlet = false
    
    static var defaultWaketTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from:components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    HStack {
                        Text("Choose Time")
                        Spacer()
                        DatePicker("Please enter a time",
                                   selection: $wakeUp,
                                   displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                    }
                }
                
                Section("Desired amount of sleep") {
                    VStack(alignment: .leading, spacing: 10) {
                
                        Stepper("\(sleepAmount.formatted()) hours",
                                value: $sleepAmount,
                                in: 4...12,
                                step: 0.25
                        )
                    }
                }
                Section("Daily coffee intake"){
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Stepper("\(coffeeAmount) cup(s)",
                                value: $coffeeAmount,
                                in: 0...20
                        )
                    }
                }
            }
            .navigationTitle("Better Rest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlet) {
                Button("Ok") {}
            } message: {
                Text(alertMessage)
            }
        }
        
        
    }
    func calculateBedTime () {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                    wake: Double(hour + minute),
                    estimatedSleep: sleepAmount,
                    coffee: Double(coffeeAmount)
            )
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedTime."
        }
        
        showingAlet = true
    }
}

#Preview {
    ContentView()
}
