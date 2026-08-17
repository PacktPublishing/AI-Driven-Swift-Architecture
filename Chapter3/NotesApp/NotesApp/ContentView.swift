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
                        .accessibilityAddTraits(.isHeader)

                    Spacer()

                    // Status indicator with proper accessibility
                    Circle()
                        .fill(notes.isEmpty ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                        .accessibilityLabel("Notes status")
                        .accessibilityValue(notes.isEmpty ? "No active notes" : "\(notes.count) active notes")
                        .accessibilityHint("Indicates whether there are active notes in the list")
                }
                .padding()
                .background(Color(.systemGray6))

                // Notes list
                List {
                    ForEach(notes, id: \.id) { note in
                        NoteRowView(
                            note: note,
                            onDelete: {
                                notes.removeAll { $0.id == note.id }
                            }
                        )
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Add button with minimum 44x44 touch target and clean accessibility hint
                    Button(action: { showingNewNote = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Add note")
                    .accessibilityHint("Creates a new note")
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
