//
//  ContentView.swift
//  Account_bank_race_condition
//
//  Created by Walid SASSI on 27/10/2025.
//

import Synchronization

final class BankAccount: Sendable {
    private let balance = Mutex<Int>(100)

    func withdraw(amount: Int) -> Bool {

        var currentBalance = 0

        balance.withLock { currentBalance = $0 }

        if currentBalance >= amount {

            balance.withLock { $0 -= amount }

            return true
        }

        return false
    }

    func getBalance() -> Int {
        balance.withLock { $0 }
    }
}

import SwiftUI

struct ContentView: View {

    @State private var initialBalance = 100

    @State private var currentBalance = 100

    @State private var task1Amount = 60

    @State private var task1Result: String = ""

    @State private var task1Success: Bool? = nil

    @State private var task2Amount = 70

    @State private var task2Result: String = ""

    @State private var task2Success: Bool? = nil

    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 24) {
            // Title
            Text("Bank Account Race Condition Demo")
                .font(.title)
                .fontWeight(.bold)

            // Balance Display
            VStack(spacing: 8) {
                Text("Current Balance")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Initial")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("$\(initialBalance)")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }

                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Final")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("$\(currentBalance)")
                            .font(.headline)
                            .foregroundColor(.green)
                    }

                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            Divider()

            // Task 1
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Task 1")
                        .fontWeight(.semibold)
                    Spacer()
                    StatusBadge(success: task1Success)
                }

                Text("Attempting to withdraw $\(task1Amount)")
                    .font(.caption)
                    .foregroundColor(.gray)

                if !task1Result.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: task1Success ?? false ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(task1Success ?? false ? .green : .red)

                        Text(task1Result)
                            .font(.caption)
                            .foregroundColor(task1Success ?? false ? .green : .red)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // Task 2
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Task 2")
                        .fontWeight(.semibold)
                    Spacer()
                    StatusBadge(success: task2Success)
                }

                Text("Attempting to withdraw $\(task2Amount)")
                    .font(.caption)
                    .foregroundColor(.gray)

                if !task2Result.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: task2Success ?? false ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(task2Success ?? false ? .green : .red)

                        Text(task2Result)
                            .font(.caption)
                            .foregroundColor(task2Success ?? false ? .green : .red)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)

            if task1Success != nil && task2Success != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Result")
                        .fontWeight(.semibold)

                    if currentBalance >= 0 {
                        Text("✅ Both tasks executed safely. Final balance: $\(currentBalance)")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("⚠️ Race condition would cause negative balance!")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: runTest) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Run Test")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading)

                Button(action: reset) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray4))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }

    func runTest() {

        isLoading = true

        task1Success = nil

        task2Success = nil

        task1Result = ""

        task2Result = ""

        currentBalance = initialBalance

        let account = BankAccount()

        Task {
            let result1 = account.withdraw(amount: task1Amount)
            task1Success = result1
            task1Result = result1 ? "✅ Withdrew $\(task1Amount)" : "❌ Insufficient funds"
        }

        Task {
            let result2 = account.withdraw(amount: task2Amount)
            task2Success = result2
            task2Result = result2 ? "✅ Withdrew $\(task2Amount)" : "❌ Insufficient funds"
        }

        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            currentBalance = account.getBalance()

            isLoading = false
        }
    }

    func reset() {

        initialBalance = 100

        currentBalance = 100

        task1Result = ""

        task2Result = ""

        task1Success = nil

        task2Success = nil
    }
}

struct StatusBadge: View {
    let success: Bool?

    var body: some View {
        if success == nil {
            HStack(spacing: 4) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Processing")
                    .font(.caption2)
            }
            .foregroundColor(.orange)
        } else if success ?? false {
            Label("Success", systemImage: "checkmark.circle.fill")
                .font(.caption2)
                .foregroundColor(.green)
        } else {
            Label("Failed", systemImage: "xmark.circle.fill")
                .font(.caption2)
                .foregroundColor(.red)
        }
    }
}

#Preview {
    ContentView()
}

