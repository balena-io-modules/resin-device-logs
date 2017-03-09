# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [3.1.0] - 2017-03-10

### Changed

- Upgrade to PubNub SDK v4
- Added the clear logs functionality (previously supported by the Resin.io UI)
	- New `clear` method
	- New `clear` event for subscriptions
	- New `historySinceLastClear` method that tolerates the clear logs functionality
	Note: the amount of historic messages for this method is limited to 200 by default. Can be overridden by passing the `{ count: N }` options object as the 3rd argument.

## [3.0.1] - 2016-10-04

### Changed

- Update dependencies and use granular lodash imports

## [3.0.0] - 2015-07-26

### Changed

- Emit metadata along with each message.

## [2.1.0] - 2015-07-24

### Added

- Add backwards compatible support for new Supervisor logs format.

## [2.0.2] - 2015-12-04

### Changed

- Omit tests from NPM package.

## [2.0.1] - 2015-11-24

### Changed

- Fix the way we construct channel names based on `logs_channel` property.

## [2.0.0] - 2015-11-24

### Changed

- Accept a device object instead of a uuid as argument to public functions.
- Give precedence to `logs_channel` device property.

[3.0.0]: https://github.com/resin-io/resin-device-logs/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/resin-io/resin-device-logs/compare/v2.1.0...v3.0.0
[2.1.0]: https://github.com/resin-io/resin-device-logs/compare/v2.0.2...v2.1.0
[2.0.2]: https://github.com/resin-io/resin-device-logs/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/resin-io/resin-device-logs/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/resin-io/resin-device-logs/compare/v1.0.0...v2.0.0
