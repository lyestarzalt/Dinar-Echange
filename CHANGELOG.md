All notable changes to the DinarEchange project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.7] - 2024-06-14
### Changed
- Updated the Android minimum SDK requirement to 23 for Firebase Auth compatibility.

## [1.3.6] - 2024-06-13
### Changed
- Updated dependencies for newer versions required by third-party libraries.
- Improved error handling to manage cases when current day's data is not available, looking for previous day's cache.

### Maintenance
- Adjusted logger settings for more detailed output.
- Cleaned code and logs to remove obsolete and unused code.

## [1.3.5] - 2024-06-12
### Added
- Better error messages and direct link for app reviews on user demand.

## [1.3.4] - 2024-06-11
### Fixed
- Fixed Google Play reported accessibility issues to comply with updated standards.

## [1.3.3] - 2024-06-11
### Fixed
- Network fetch timings updated to ensure data freshness and reliability.

## [1.3.2] - 2024-06-11
### Added
- Enhanced event logging for improved diagnostics and monitoring.

## [1.3.1] - 2024-06-11
### Added
- Restored international support for the currency list app bar.
- Addressed the loading issues at app startup and resolved a memory leak in the graph provider.

## [1.3.0] - 2024-06-10
### Added
- Introduced fetching and displaying official exchange rates.

### Maintenance
- Improved accessibility by adding semantic labeling for screen readers in the ErrorApp widget.

## [1.2.4] - 2024-05-27
### Maintenance
- Improved user tracking and analytics with new firebase settings.

## [1.2.3] - 2024-05-27
### Fixed
- Resolved the issue with missing `build_runner` package which was causing build failures.

## [1.2.2] - 2024-05-03
### Added
- Implemented features for keystore management and automated actions triggered by new tags.

### Fixed
- Adjusted list tile dimensions and fixed environment variable configurations for consistent builds.

### Maintenance
- Refined user experience adjustments and debugged workflows for operational stability.

For detailed updates and more information on the changes, refer to the specific tagged versions and commit messages in the repository.
