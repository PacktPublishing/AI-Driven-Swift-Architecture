import SwiftUI

struct NoteRowView: View {
    let note: Note
    var onDelete: () -> Void = {}

    var body: some View {
        HStack(spacing: 8) {
            // Priority indicator
            Rectangle()
                .fill(priorityColor(note.priority))
                .frame(width: 4)
                .accessibilityHidden(true) // Communicated via parent accessibility label

            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(note.title), \(priorityLabel(note.priority)) priority, \(note.content)")
            .accessibilityIdentifier("note-info-\(note.id)")

            Spacer()

            // Delete button with compliant touch target and Dynamic Type scaling
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.body)
                    .foregroundColor(.red)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete \(note.title)")
            .accessibilityHint("Permanently deletes this note")
            .accessibilityIdentifier("delete-note-\(note.id)")
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
        .accessibilityAction(named: "Delete \(note.title)") {
            onDelete()
        }
    }

    private func priorityColor(_ priority: NotePriority) -> Color {
        switch priority {
        case .high: .red
        case .medium: .orange
        case .low: .green
        }
    }

    private func priorityLabel(_ priority: NotePriority) -> String {
        switch priority {
        case .high: "high"
        case .medium: "medium"
        case .low: "low"
        }
    }
}
