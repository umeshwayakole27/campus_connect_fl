# Flutter Project Conventions

## Code Style
- Follow official Dart style guide
- Use flutter_lints package for linting
- Prefer const constructors where possible
- Use meaningful variable and function names

## File Organization
- Widget files should be in `lib/widgets/`
- Screen/page files should be in `lib/screens/` or `lib/pages/`
- Models should be in `lib/models/`
- Services should be in `lib/services/`
- Utilities should be in `lib/utils/`

## Widget Guidelines
- Extract reusable widgets into separate files
- Use StatelessWidget when possible
- Keep build methods clean and readable
- Use const constructors for performance

## State Management
- Consider using provider, bloc, riverpod, or other state management solutions as the app grows

## Testing
- Write unit tests for business logic
- Write widget tests for UI components
- Follow the AAA pattern (Arrange, Act, Assert)

## Platform-Specific Code
- Use platform channels when needed
- Keep platform-specific code in respective directories
- Use conditional imports for platform-specific implementations
