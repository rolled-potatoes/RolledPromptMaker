# Agent Guidelines for RolledPromptMaker

## Build Commands
- Build: `xcodebuild -project RolledPromptMaker.xcodeproj -scheme RolledPromptMaker -configuration Debug build`
- Clean: `xcodebuild -project RolledPromptMaker.xcodeproj -scheme RolledPromptMaker clean`
- Archive: `xcodebuild -project RolledPromptMaker.xcodeproj -scheme RolledPromptMaker archive`
- No test suite currently exists

## Project Structure
- `RolledPromptMaker/Models/` - SwiftData models (Template, History)
- `RolledPromptMaker/Views/` - SwiftUI views
- Entry point: `RolledPromptMakerApp.swift`

## Code Style
- **Language**: Swift 5.0, SwiftUI + SwiftData
- **Target**: macOS 14.0+
- **Imports**: Group by framework (Foundation, SwiftUI, SwiftData)
- **Naming**: camelCase for variables/functions, PascalCase for types
- **Types**: Use explicit types for stored properties, infer for local vars
- **Models**: Use `@Model` for SwiftData models, conform to Hashable where needed
- **Views**: Leverage SwiftUI property wrappers (@State, @Environment, @Query)
- **Error handling**: Use `try?` for non-critical errors, `fatalError()` for unrecoverable errors
- **Comments**: Korean comments for business logic explanations
