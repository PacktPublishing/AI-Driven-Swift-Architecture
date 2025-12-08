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
    @State private var nextId = 4

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
                        .accessibilityLabel("Status indicator")
                        .accessibilityValue(notes.isEmpty ? "No notes" : "Active notes")
                        .accessibilityHint("Shows whether the note list contains active items")
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
            NewNoteView(
                notes: $notes,
                nextId: $nextId
            )
        }
    }
}







enum NotePriority {
    case high, medium, low
}

#Preview {
    ContentView()
}
