import Foundation
import FoundationModels

import EventKit

/// `CalendarTool` provides access to calendar events with EventKit integration.
///
/// This tool can create, read, query, update, and delete calendar events.
/// Important: Requires Calendar entitlement and user permission.
public struct CalendarTool: Tool {

    public let name = "manageCalendar"

    public let description = """
    Manage calendar events: create, read, query, update, and delete events.
    Requires calendar access permission.
    """

    /// Arguments for calendar operations
    @Generable
    public struct Arguments: Codable {

        /// Action to perform
        @Guide(description: "Action: 'create', 'query', 'read', 'update', 'delete', 'findAvailable'")
        public var action: String

        /// Event title
        @Guide(description: "Event title (required for create/update)")
        public var title: String?

        /// Start date (ISO8601 format: YYYY-MM-DD HH:mm:ss)
        @Guide(description: "Start date in ISO8601 format (YYYY-MM-DD HH:mm:ss)")
        public var startDate: String?

        /// End date (ISO8601 format: YYYY-MM-DD HH:mm:ss)
        @Guide(description: "End date in ISO8601 format (YYYY-MM-DD HH:mm:ss)")
        public var endDate: String?

        /// Event location
        @Guide(description: "Event location")
        public var location: String?

        /// Event notes/description
        @Guide(description: "Event notes or description")
        public var notes: String?

        /// Calendar name to use
        @Guide(description: "Calendar name to use (defaults to default calendar)")
        public var calendarName: String?

        /// Number of days to query (for query action)
        @Guide(description: "Number of days ahead to query (for 'query' action)")
        public var daysAhead: Int?

        /// Event identifier (for read/update/delete)
        @Guide(description: "Unique event identifier (for read/update/delete actions)")
        public var eventId: String?

        /// All-day event flag
        @Guide(description: "All-day event (true/false)")
        public var isAllDay: Bool?

        /// Event URL
        @Guide(description: "URL associated with the event")
        public var url: String?

        /// Alarms (in minutes before event)
        @Guide(description: "Alarms: array of minutes before event, e.g., [15, 60] for 15min and 1h before")
        public var alarms: [Int]?

        /// Recurrence rule
        @Guide(description: "Recurrence: 'daily', 'weekly', 'monthly', 'yearly'")
        public var recurrence: String?

        /// Recurrence end date
        @Guide(description: "Recurrence end date (ISO8601 format)")
        public var recurrenceEndDate: String?

        public init(
            action: String = "",
            title: String? = nil,
            startDate: String? = nil,
            endDate: String? = nil,
            location: String? = nil,
            notes: String? = nil,
            calendarName: String? = nil,
            daysAhead: Int? = nil,
            eventId: String? = nil,
            isAllDay: Bool? = nil,
            url: String? = nil,
            alarms: [Int]? = nil,
            recurrence: String? = nil,
            recurrenceEndDate: String? = nil
        ) {
            self.action = action
            self.title = title
            self.startDate = startDate
            self.endDate = endDate
            self.location = location
            self.notes = notes
            self.calendarName = calendarName
            self.daysAhead = daysAhead
            self.eventId = eventId
            self.isAllDay = isAllDay
            self.url = url
            self.alarms = alarms
            self.recurrence = recurrence
            self.recurrenceEndDate = recurrenceEndDate
        }
    }

    // MARK: - Private Properties

    nonisolated(unsafe) private let eventStore = EKEventStore()

    private static let dateFormat = "yyyy-MM-dd HH:mm:ss"

    private static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone.current
        return formatter
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - Tool Protocol

    public func call(arguments: Arguments) async throws -> some PromptRepresentable {
        // Request calendar access
        let authorized = await requestAccess()
        guard authorized else {
            return createErrorOutput(error: CalendarError.accessDenied)
        }

        // Route to appropriate action
        return switch arguments.action.lowercased() {
        case "create":
            try createEvent(arguments: arguments)
        case "query":
            try queryEvents(arguments: arguments)
        case "read":
            try readEvent(eventId: arguments.eventId)
        case "update":
            try updateEvent(arguments: arguments)
        case "delete":
            try deleteEvent(eventId: arguments.eventId)
        case "findavailable":
            try findAvailableSlots(arguments: arguments)
        default:
            createErrorOutput(error: CalendarError.invalidAction)
        }
    }

    // MARK: - Private Methods - Access

    private func requestAccess() async -> Bool {
        do {
            if #available(macOS 14.0, iOS 17.0, *) {
                return try await eventStore.requestFullAccessToEvents()
            } else {
                return try await eventStore.requestAccess(to: .event)
            }
        } catch {
            return false
        }
    }

    // MARK: - Private Methods - CRUD Operations

    private func createEvent(arguments: Arguments) throws -> GeneratedContent {
        guard let title = arguments.title, !title.isEmpty else {
            return createErrorOutput(error: CalendarError.missingTitle)
        }

        guard let startDateString = arguments.startDate,
              let startDate = parseDate(startDateString) else {
            return createErrorOutput(error: CalendarError.invalidStartDate)
        }

        let endDate: Date
        if let endDateString = arguments.endDate {
            guard let parsedEndDate = parseDate(endDateString) else {
                return createErrorOutput(error: CalendarError.invalidEndDate)
            }
            endDate = parsedEndDate
        } else {
            // Default to 1 hour duration
            endDate = startDate.addingTimeInterval(3600)
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = arguments.isAllDay ?? false

        if let location = arguments.location {
            event.location = location
        }

        if let notes = arguments.notes {
            event.notes = notes
        }

        if let urlString = arguments.url, let url = URL(string: urlString) {
            event.url = url
        }

        // Set calendar
        event.calendar = findOrCreateCalendar(name: arguments.calendarName)

        // Add alarms
        if let alarmMinutes = arguments.alarms {
            event.alarms = alarmMinutes.map { minutes in
                EKAlarm(relativeOffset: TimeInterval(-minutes * 60))
            }
        }

        // Add recurrence rule
        if let recurrence = arguments.recurrence {
            event.recurrenceRules = [createRecurrenceRule(
                type: recurrence,
                endDate: arguments.recurrenceEndDate
            )].compactMap { $0 }
        }

        do {
            try eventStore.save(event, span: .thisEvent)

            return GeneratedContent(properties: [
                "status": "success",
                "message": "Event created successfully",
                "eventId": event.eventIdentifier ?? "",
                "title": event.title ?? "",
                "startDate": formatDate(event.startDate),
                "endDate": formatDate(event.endDate),
                "location": event.location ?? "",
                "calendar": event.calendar?.title ?? "",
                "isAllDay": event.isAllDay,
                "hasAlarms": !(event.alarms?.isEmpty ?? true),
                "hasRecurrence": !(event.recurrenceRules?.isEmpty ?? true)
            ])
        } catch {
            return createErrorOutput(error: error)
        }
    }

    private func queryEvents(arguments: Arguments) throws -> GeneratedContent {
        let startDate = Date()
        let daysToQuery = arguments.daysAhead ?? 7
        guard let endDate = Calendar.current.date(byAdding: .day, value: daysToQuery, to: startDate) else {
            return createErrorOutput(error: CalendarError.invalidDateCalculation)
        }

        let calendars: [EKCalendar]?
        if let calendarName = arguments.calendarName {
            calendars = eventStore.calendars(for: .event).filter { $0.title == calendarName }
        } else {
            calendars = eventStore.calendars(for: .event)
        }

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )

        let events = eventStore.events(matching: predicate)

        var eventsDescription = ""
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short

        for (index, event) in events.enumerated() {
            let location = event.location != nil ? " at \(event.location!)" : ""
            let calendar = event.calendar?.title ?? "Unknown Calendar"

            eventsDescription += "\(index + 1). \(event.title ?? "Untitled")\n"
            eventsDescription += "   When: \(displayFormatter.string(from: event.startDate))"
            if !event.isAllDay {
                eventsDescription += " - \(displayFormatter.string(from: event.endDate))"
            }
            eventsDescription += "\n"
            eventsDescription += "   Calendar: \(calendar)\(location)\n"

            if let notes = event.notes, !notes.isEmpty {
                let preview = notes.count > 50 ? String(notes.prefix(50)) + "..." : notes
                eventsDescription += "   Notes: \(preview)\n"
            }

            if let alarms = event.alarms, !alarms.isEmpty {
                eventsDescription += "   Alarms: \(alarms.count) reminder(s)\n"
            }

            eventsDescription += "\n"
        }

        if eventsDescription.isEmpty {
            eventsDescription = "No events found in the next \(daysToQuery) days"
        }

        return GeneratedContent(properties: [
            "status": "success",
            "count": events.count,
            "daysQueried": daysToQuery,
            "events": eventsDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            "message": "Found \(events.count) event(s) in the next \(daysToQuery) days"
        ])
    }

    private func readEvent(eventId: String?) throws -> GeneratedContent {
        guard let id = eventId else {
            return createErrorOutput(error: CalendarError.missingEventId)
        }

        guard let event = eventStore.event(withIdentifier: id) else {
            return createErrorOutput(error: CalendarError.eventNotFound)
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .full
        displayFormatter.timeStyle = .short

        let alarmCount = event.alarms?.count ?? 0
        let recurrenceDescription: String
        if let recurrenceRules = event.recurrenceRules, let firstRule = recurrenceRules.first {
            recurrenceDescription = describeRecurrence(firstRule)
        } else {
            recurrenceDescription = ""
        }

        return GeneratedContent(properties: [
            "status": "success",
            "eventId": event.eventIdentifier ?? "",
            "title": event.title ?? "",
            "startDate": formatDate(event.startDate),
            "endDate": formatDate(event.endDate),
            "location": event.location ?? "",
            "notes": event.notes ?? "",
            "calendar": event.calendar?.title ?? "",
            "isAllDay": event.isAllDay,
            "url": event.url?.absoluteString ?? "",
            "hasAlarms": !(event.alarms?.isEmpty ?? true),
            "hasRecurrence": !(event.recurrenceRules?.isEmpty ?? true),
            "formattedDate": "\(displayFormatter.string(from: event.startDate)) - \(displayFormatter.string(from: event.endDate))",
            "alarmCount": alarmCount,
            "recurrenceDescription": recurrenceDescription
        ])
    }

    private func updateEvent(arguments: Arguments) throws -> GeneratedContent {
        guard let eventId = arguments.eventId else {
            return createErrorOutput(error: CalendarError.missingEventId)
        }

        guard let event = eventStore.event(withIdentifier: eventId) else {
            return createErrorOutput(error: CalendarError.eventNotFound)
        }

        // Update fields if provided
        if let title = arguments.title {
            event.title = title
        }

        if let startDateString = arguments.startDate,
           let startDate = parseDate(startDateString) {
            event.startDate = startDate
        }

        if let endDateString = arguments.endDate,
           let endDate = parseDate(endDateString) {
            event.endDate = endDate
        }

        if let location = arguments.location {
            event.location = location
        }

        if let notes = arguments.notes {
            event.notes = notes
        }

        if let isAllDay = arguments.isAllDay {
            event.isAllDay = isAllDay
        }

        if let urlString = arguments.url, let url = URL(string: urlString) {
            event.url = url
        }

        // Update alarms
        if let alarmMinutes = arguments.alarms {
            event.alarms = alarmMinutes.map { minutes in
                EKAlarm(relativeOffset: TimeInterval(-minutes * 60))
            }
        }

        do {
            try eventStore.save(event, span: .thisEvent)

            return GeneratedContent(properties: [
                "status": "success",
                "message": "Event updated successfully",
                "eventId": event.eventIdentifier ?? "",
                "title": event.title ?? "",
                "startDate": formatDate(event.startDate),
                "endDate": formatDate(event.endDate),
                "location": event.location ?? "",
                "calendar": event.calendar?.title ?? ""
            ])
        } catch {
            return createErrorOutput(error: error)
        }
    }

    private func deleteEvent(eventId: String?) throws -> GeneratedContent {
        guard let id = eventId else {
            return createErrorOutput(error: CalendarError.missingEventId)
        }

        guard let event = eventStore.event(withIdentifier: id) else {
            return createErrorOutput(error: CalendarError.eventNotFound)
        }

        let eventTitle = event.title ?? "Untitled"

        do {
            try eventStore.remove(event, span: .thisEvent)

            return GeneratedContent(properties: [
                "status": "success",
                "message": "Event '\(eventTitle)' deleted successfully",
                "deletedEventId": id
            ])
        } catch {
            return createErrorOutput(error: error)
        }
    }

    private func findAvailableSlots(arguments: Arguments) throws -> GeneratedContent {
        guard let startDateString = arguments.startDate,
              let startDate = parseDate(startDateString) else {
            return createErrorOutput(error: CalendarError.invalidStartDate)
        }

        let daysToSearch = arguments.daysAhead ?? 7
        guard let endDate = Calendar.current.date(byAdding: .day, value: daysToSearch, to: startDate) else {
            return createErrorOutput(error: CalendarError.invalidDateCalculation)
        }

        let calendars = eventStore.calendars(for: .event)
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )

        let events = eventStore.events(matching: predicate)

        // Find available slots (simplified: 1-hour slots during business hours)
        var availableSlots: [String] = []
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate < endDate {
            let hour = calendar.component(.hour, from: currentDate)

            // Only check business hours (9 AM - 6 PM)
            if hour >= 9 && hour < 18 {
                let slotEnd = calendar.date(byAdding: .hour, value: 1, to: currentDate)!

                // Check if this slot is free
                let isOccupied = events.contains { event in
                    event.startDate < slotEnd && event.endDate > currentDate
                }

                if !isOccupied {
                    let displayFormatter = DateFormatter()
                    displayFormatter.dateStyle = .short
                    displayFormatter.timeStyle = .short

                    availableSlots.append(
                        "\(displayFormatter.string(from: currentDate)) - \(displayFormatter.string(from: slotEnd))"
                    )
                }
            }

            currentDate = calendar.date(byAdding: .hour, value: 1, to: currentDate)!
        }

        let slotsDescription = availableSlots.isEmpty
            ? "No available slots found"
            : availableSlots.prefix(20).joined(separator: "\n")

        return GeneratedContent(properties: [
            "status": "success",
            "count": availableSlots.count,
            "message": "Found \(availableSlots.count) available slot(s)",
            "slots": slotsDescription
        ])
    }

    // MARK: - Helper Methods

    private func findOrCreateCalendar(name: String?) -> EKCalendar {
        if let calendarName = name {
            let calendars = eventStore.calendars(for: .event)
            if let calendar = calendars.first(where: { $0.title == calendarName }) {
                return calendar
            }
        }
        return eventStore.defaultCalendarForNewEvents ?? eventStore.calendars(for: .event).first!
    }

    private func createRecurrenceRule(type: String, endDate: String?) -> EKRecurrenceRule? {
        let frequency: EKRecurrenceFrequency

        switch type.lowercased() {
        case "daily":
            frequency = .daily
        case "weekly":
            frequency = .weekly
        case "monthly":
            frequency = .monthly
        case "yearly":
            frequency = .yearly
        default:
            return nil
        }

        let recurrenceEnd: EKRecurrenceEnd?
        if let endDateString = endDate, let date = parseDate(endDateString) {
            recurrenceEnd = EKRecurrenceEnd(end: date)
        } else {
            recurrenceEnd = nil
        }

        return EKRecurrenceRule(
            recurrenceWith: frequency,
            interval: 1,
            end: recurrenceEnd
        )
    }

    private func describeRecurrence(_ rule: EKRecurrenceRule) -> String {
        let frequency: String
        switch rule.frequency {
        case .daily: frequency = "Daily"
        case .weekly: frequency = "Weekly"
        case .monthly: frequency = "Monthly"
        case .yearly: frequency = "Yearly"
        @unknown default: frequency = "Unknown"
        }

        if let end = rule.recurrenceEnd {
            if let endDate = end.endDate {
                return "\(frequency) until \(formatDate(endDate))"
            } else if end.occurrenceCount > 0 {
                return "\(frequency) for \(end.occurrenceCount) occurrences"
            }
        }

        return "\(frequency) (no end date)"
    }

    private func parseDate(_ dateString: String) -> Date? {
        Self.makeDateFormatter().date(from: dateString)
    }

    private func formatDate(_ date: Date) -> String {
        Self.makeDateFormatter().string(from: date)
    }

    private func createErrorOutput(error: Error) -> GeneratedContent {
        GeneratedContent(properties: [
            "status": "error",
            "error": error.localizedDescription,
            "message": "Failed to perform calendar operation"
        ])
    }
}

// MARK: - Calendar Errors

enum CalendarError: Error, LocalizedError {
    case accessDenied
    case invalidAction
    case missingTitle
    case invalidStartDate
    case invalidEndDate
    case missingEventId
    case eventNotFound
    case invalidDateCalculation

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Access to calendar denied. Please grant permission in Settings."
        case .invalidAction:
            return "Invalid action. Use 'create', 'query', 'read', 'update', 'delete', or 'findAvailable'."
        case .missingTitle:
            return "Title is required to create an event."
        case .invalidStartDate:
            return "Invalid start date format. Use YYYY-MM-DD HH:mm:ss"
        case .invalidEndDate:
            return "Invalid end date format. Use YYYY-MM-DD HH:mm:ss"
        case .missingEventId:
            return "Event ID is required."
        case .eventNotFound:
            return "Event not found with the provided ID."
        case .invalidDateCalculation:
            return "Failed to calculate date range."
        }
    }
}
