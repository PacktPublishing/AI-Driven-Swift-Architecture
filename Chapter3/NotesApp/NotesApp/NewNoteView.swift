import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var content = ""
    @Binding var notes: [Note]
    @Binding var nextId: Int

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
                        let newNote = Note(
                            id: nextId,
                            title: title,
                            content: content,
                            priority: .medium
                        )

                        notes.append(newNote)

                        nextId += 1

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
