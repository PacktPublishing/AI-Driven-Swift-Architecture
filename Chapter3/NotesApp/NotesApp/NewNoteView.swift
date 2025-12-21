import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var content: AttributedString = ""
    @Binding var notes: [Note]
    @Binding var nextId: Int
    @State private var selection = AttributedTextSelection()
    @Environment(\.fontResolutionContext) private var fontResolutionContext

    var body: some View {
        NavigationStack {
            Form {
                Section("Note Details") {
                    TextField("Title", text: $title)
                        .accessibilityLabel("Note title")
                        .accessibilityHint("Enter a title for your note")
                        .accessibilityIdentifier("note-title-field")

                    TextEditor(text: $content, selection: $selection)
                        .frame(height: 150)
                        .scrollBounceBehavior(.basedOnSize)
                        .toolbarTitleDisplayMode(.inlineLarge)
                        .toolbar {
                            ToolbarItemGroup(placement: .bottomBar) {
                                Button {

                                    content.transformAttributes(in: &selection) { container in
                                        let currentFont = container.font ?? .default

                                        let resolved = currentFont.resolve(in: fontResolutionContext)

                                        container.font = currentFont.bold(!resolved.isBold)

                                    }

                                } label: {
                                    Image(systemName: "bold")
                                }

                                Button {

                                    content.transformAttributes(in: &selection) { container in
                                        let currentFont = container.font ?? .default

                                        let resolved = currentFont.resolve(in: fontResolutionContext)

                                        container.font = currentFont.italic(!resolved.isItalic)

                                    }

                                } label: {
                                    Image(systemName: "italic")
                                }

                                Button {

                                    content.transformAttributes(in: &selection) { container in
                                        if container.underlineStyle == .single {

                                            container.underlineStyle = .none
                                        } else {
                                            container.underlineStyle = .single
                                        }

                                    }

                                } label: {
                                    Image(systemName: "underline")
                                }

                                Button {

                                    content.transformAttributes(in: &selection) { container in
                                        if container.strikethroughStyle == .single {

                                            container.strikethroughStyle = .none
                                        } else {
                                            container.strikethroughStyle = .single
                                        }

                                    }

                                } label: {
                                    Image(systemName: "strikethrough")
                                }
                            }
                        }
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
