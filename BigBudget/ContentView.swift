//
//  ContentView.swift
//  BigBudget
//
//  Created by Reese Norton on 2/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var budgetManager = BudgetManager()
    
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            PaycheckView()
                .tabItem {
                    Label("Paycheck", systemImage: "dollarsign.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
