import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var isFindNavigatorPresented = false
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

                    // Enhanced TextEditor with modern iOS improvements
                    TextEditor(text: $content)
                        .frame(minHeight: 150, maxHeight: 300)
                        .font(.body)
                        .lineSpacing(4)
                        .textSelection(.enabled)
                        .scrollDismissesKeyboard(.interactively)
                        .autocorrectionDisabled(false)
                        .textInputAutocapitalization(.sentences)
                        .padding(8)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityLabel("Note content")
                        .accessibilityHint("Enter the content of your note")
                        .accessibilityIdentifier("note-content-field")
                        // iOS 17+ features with backward compatibility
                        .applyTextEditorEnhancements(isFindNavigatorPresented: $isFindNavigatorPresented)
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
                    Button {
                        isFindNavigatorPresented.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .disabled(content.isEmpty)
                    .accessibilityLabel("Find in note")
                    .accessibilityHint(content.isEmpty ? "Add content to enable search" : "Open find and replace")
                    .accessibilityIdentifier("find-button")
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

// MARK: - iOS 17+ TextEditor Features
@available(iOS 17.0, *)
struct iOS17TextEditorModifier: ViewModifier {
    @Binding var isFindNavigatorPresented: Bool

    func body(content: Content) -> some View {
        content
            .textEditorStyle(.plain)
            .findNavigator(isPresented: $isFindNavigatorPresented)
            .findDisabled(false)
            .replaceDisabled(false)
    }
}

// Fallback for iOS 16
struct iOS16TextEditorFallback: ViewModifier {
    @Binding var isFindNavigatorPresented: Bool

    func body(content: Content) -> some View {
        // iOS 16 doesn't support these modifiers
        content
    }
}

// Convenience extension to apply the correct modifier
extension View {
    @ViewBuilder
    func applyTextEditorEnhancements(isFindNavigatorPresented: Binding<Bool>) -> some View {
        if #available(iOS 17.0, *) {
            self.modifier(iOS17TextEditorModifier(isFindNavigatorPresented: isFindNavigatorPresented))
        } else {
            self.modifier(iOS16TextEditorFallback(isFindNavigatorPresented: isFindNavigatorPresented))
        }
    }
}
