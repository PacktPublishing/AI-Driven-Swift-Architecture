//
//  GenerableView+Extension.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

extension GenerableView {

    // MARK: - Country Recommendation

    /// Generates a ``CountryRecommendation`` and formats the streamed result as Markdown.
    ///
    /// Sends a tourism-focused prompt and converts each `PartiallyGenerated` value
    /// into a formatted string containing country details, cities, cuisine, and logistics.
    func generateCountryRecommendation() {
        streamGeneration(
            prompt: "Recommend a country for tourism based on culture and nature.",
            type: CountryRecommendation.self
        ) { content in
            var lines = [String]()

            lines.append("🌍 **\(content.name ?? "Country")**")
            lines.append("")
            lines.append(content.overview ?? "")
            lines.append("")

            lines.append("**Best Time to Visit:** \(content.bestTimeToVisit ?? "?")")
            lines.append("**Budget Level:** \(content.budgetLevel ?? "?")")
            lines.append("**Languages:** \((content.languages ?? []).joined(separator: ", "))")
            lines.append("**Currency:** \(content.currency ?? "?")")
            lines.append("")

            lines.append("**Highlights:**")
            for highlight in content.highlights ?? [] {
                lines.append("✨ \(highlight)")
            }
            lines.append("")

            lines.append("**Must-Try Cuisine:**")
            for dish in content.cuisine ?? [] {
                lines.append("🍽️ \(dish)")
            }
            lines.append("")

            lines.append("**Cities to Visit:**")
            for city in content.cities ?? [] {
                lines.append("📍 **\(city.name ?? "?")**")
                lines.append("   \(city.description ?? "")")
                lines.append("   Recommended stay: \(city.recommendedDays.map { String($0) } ?? "?") days")

                if let attractions = city.attractions, !attractions.isEmpty {
                    lines.append("   Attractions: \(attractions.joined(separator: ", "))")
                }

                if let activities = city.activities, !activities.isEmpty {
                    lines.append("   Activities: \(activities.joined(separator: ", "))")
                }
                lines.append("")
            }

            return lines.joined(separator: "\n")
        }
    }

    // MARK: - Quiz

    /// Generates a ``Quiz`` and formats the streamed result as Markdown.
    ///
    /// Sends an educational prompt and converts each `PartiallyGenerated` value
    /// into a formatted string with questions, answer options, and explanations.
    func generateQuiz() {
        streamGeneration(
            prompt: "Create an educational quiz about world geography.",
            type: Quiz.self
        ) { content in
            var lines = [String]()

            lines.append("📚 **Quiz: \(content.topic ?? "?")**")
            lines.append("Difficulty: \(content.difficulty ?? "?") | Duration: ~\(content.estimatedDuration.map { String($0) } ?? "?") min")
            lines.append("")

            for (index, question) in (content.questions ?? []).enumerated() {
                lines.append("**Question \(index + 1):**")
                lines.append(question.question ?? "?")
                lines.append("")

                for (optIndex, option) in (question.options ?? []).enumerated() {
                    let marker = optIndex == (question.correctAnswerIndex ?? -1) ? "✓" : "○"
                    lines.append("\(marker) \(String(UnicodeScalar(65 + optIndex)!)). \(option)")
                }
                lines.append("")
                lines.append("💡 \(question.explanation ?? "")")
                lines.append("")
            }

            return lines.joined(separator: "\n")
        }
    }

    // MARK: - Story Idea

    /// Generates a ``StoryIdea`` and formats the streamed result as Markdown.
    ///
    /// Sends a creative writing prompt and converts each `PartiallyGenerated` value
    /// into a formatted string with characters, plot points, and conflict.
    func generateStoryIdea() {
        streamGeneration(
            prompt: "Generate a creative story idea for a science fiction adventure.",
            type: StoryIdea.self
        ) { content in
            var lines = [String]()

            lines.append("📖 **\(content.title ?? "Story")**")
            lines.append("Genre: \(content.genre ?? "?")")
            lines.append("")

            lines.append("**Premise:**")
            lines.append(content.premise ?? "...")
            lines.append("")

            lines.append("**Characters:**")
            for character in content.characters ?? [] {
                lines.append("• **\(character.name ?? "?")** (\(character.role ?? "?"))")
                lines.append("  Personality: \(character.personality ?? "")")
                lines.append("  Motivation: \(character.motivation ?? "")")
                lines.append("")
            }

            lines.append("**Central Conflict:**")
            lines.append(content.centralConflict ?? "...")
            lines.append("")

            lines.append("**Plot Points:**")
            for (index, point) in (content.plotPoints ?? []).enumerated() {
                lines.append("\(index + 1). \(point)")
            }
            lines.append("")

            lines.append("**Suggested Ending:**")
            lines.append(content.suggestedEnding ?? "...")

            return lines.joined(separator: "\n")
        }
    }
}
