//
//  ContentView.swift
//  NotesApp
//
//  Created by Walid SASSI on 01/11/2025.
//

import SwiftUI

struct ContentView: View {

    @State private var notes: [Note] = [
        Note(
            id: 1,
            title: "Meeting",
            content: "Discuss Q4 goals",
            priority: .high
        ),
        Note(
            id: 2,
            title: "Shopping",
            content: "Milk, eggs, bread",
            priority: .low
        ),
        Note(
            id: 3,
            title: "Ideas",
            content: "New app features",
            priority: .medium
        )
    ]

    @State private var showingNewNote = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with status indicator
                HStack {
                    Text("My Notes")
                        .font(.title)
                        .fontWeight(.bold)

                    Spacer()

                    // Status indicator with proper accessibility
                    Circle()
                        .fill(notes.isEmpty ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                        .accessibilityLabel(notes.isEmpty ? "No notes" : "Active notes")
                        .accessibilityHint("Status indicator")
                }
                .padding()
                .background(Color(.systemGray6))

                // Notes list
                List {
                    ForEach(notes, id: \.id) { note in
                        NoteRowView(note: note)
                            // ACCESSIBILITY ISSUE #2: No accessibility container
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Add button with proper accessibility
                    Button(action: { showingNewNote = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .frame(width: 44, height: 44)  // Minimum 44x44 touch target
                    .accessibilityLabel("Add new note")
                    .accessibilityHint("Double tap to create a new note")
                    .accessibilityIdentifier("add-note-button")
                }
            }
        }
        .sheet(isPresented: $showingNewNote) {
            NewNoteView()
        }
    }
}

struct NoteRowView: View {
    let note: Note

    var body: some View {
        HStack(spacing: 8) {
            // Priority indicator with accessibility
            Rectangle()
                .fill(priorityColor(note.priority))
                .frame(width: 4)
                .accessibilityHidden(true) // Hidden because priority is communicated via label

            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.headline)

                Text(note.content)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            // Delete button with proper accessibility
            Button(action: {}) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            .frame(width: 44, height: 44)  // Minimum 44x44 touch target
            .accessibilityLabel("Delete \(note.title) note")
            .accessibilityHint("Double tap to delete this note")
            .accessibilityIdentifier("delete-note-\(note.id)")
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(note.title), \(priorityLabel(note.priority)) priority, \(note.content)")
        .accessibilityHint("Double tap to view or edit note")
    }

    private func priorityColor(_ priority: NotePriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }

    private func priorityLabel(_ priority: NotePriority) -> String {
        switch priority {
        case .high: return "high"
        case .medium: return "medium"
        case .low: return "low"
        }
    }
}

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Note Details") {
                    TextField("Title", text: $title)
                        .accessibilityLabel("Note title")
                        .accessibilityHint("Enter a title for your note")
                        .accessibilityIdentifier("note-title-field")

                    TextEditor(text: $content)
                        .frame(height: 150)
                        .accessibilityLabel("Note content")
                        .accessibilityHint("Enter the content of your note")
                        .accessibilityIdentifier("note-content-field")
                }
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityHint("Discard changes and close")
                    .accessibilityIdentifier("cancel-button")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .accessibilityHint(title.isEmpty ? "Enter a title to enable saving" : "Save the note and close")
                    .accessibilityIdentifier("save-button")
                }
            }
        }
    }
}

struct Note {
    let id: Int
    let title: String
    let content: String
    let priority: NotePriority
}

enum NotePriority {
    case high, medium, low
}

#Preview {
    ContentView()
}
