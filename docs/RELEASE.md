# Release Process

## Versioning

Use semantic versioning where possible:

- `major` for breaking changes
- `minor` for user-visible feature additions
- `patch` for bug fixes and documentation-only updates

## Before Release

1. Run `dart format --set-exit-if-changed .`
2. Run `flutter analyze`
3. Run `flutter test`
4. Verify app startup on at least one target platform
5. Review any new configuration values for secrets or environment-specific data
6. Update `CHANGELOG.md`
7. Add screenshots if the release notes will be published publicly

## Release Notes

Release notes should summarize:

- user-visible changes
- breaking changes
- configuration changes
- migration notes

## Tagging

- Tag releases in Git
- Keep changelog entries aligned with published tags
- Avoid publishing tags for documentation-only churn unless there is a reason
