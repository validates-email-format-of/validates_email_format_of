# CHANGELOG

## [Unreleased]

[Unreleased]: https://github.com/validates-email-format-of/validates_email_format_of/compare/v1.8.1...master

## [1.8.1]

* Fix IDN->Punycode conversion when domain names start with periods - https://github.com/validates-email-format-of/validates_email_format_of/issues/109
* Add jruby to test matrix - https://github.com/validates-email-format-of/validates_email_format_of/pull/108

[Unreleased]: https://github.com/validates-email-format-of/validates_email_format_of/compare/v1.8.0...1.8.1

## [1.8.0]

* Add Internationalized Domain Name support - https://github.com/validates-email-format-of/validates_email_format_of/pull/103 - thanks https://github.com/sbilharz !
* Add Turkish locale - https://github.com/validates-email-format-of/validates_email_format_of/pull/101 - thanks https://github.com/@krmbzds !
* Added Indonesian locale - https://github.com/validates-email-format-of/validates_email_format_of/commit/129ebfc3a3b432b4df0334bcbdd74b1d17d765e0 - thanks https://github.com/khoerodin !
* Fix inconsistent `generate_messages` behaviour - https://github.com/validates-email-format-of/validates_email_format_of/pull/105
* ⚠️ Deprecate `:with` option - https://github.com/validates-email-format-of/validates_email_format_of/issues/42
* Require i18n >= 0.8.0 in modern Ruby versions - https://github.com/advisories/GHSA-34hf-g744-jw64

[1.8.0]: https://github.com/validates-email-format-of/validates_email_format_of/compare/v1.7.2...master

## [1.7.2]

* Fix regression that disallowed domains starting with number - https://github.com/validates-email-format-of/validates_email_format_of/issues/88

[1.7.2]: https://github.com/validates-email-format-of/validates_email_format_of/compare/v1.7.1...v1.7.2

## [1.7.1] (3 Aug 2022)

* Fix invalid symbols being allowed in the local part - https://github.com/validates-email-format-of/validates_email_format_of/issues/86
* Fix rspec_matcher when using a custom error message - https://github.com/validates-email-format-of/validates_email_format_of/pull/85 - thanks https://github.com/luuqnhu !

[1.7.1]: https://github.com/validates-email-format-of/validates_email_format_of/compare/v1.7.0...v1.7.1

## [1.7.0] (29 July 2022)

* Use Standard.rb for internal code formatting - https://github.com/validates-email-format-of/validates_email_format_of/commit/db1b0a86af58e478b7f9f2f269bf93bf48dc13c1
* Add support for comments in the local part and improve quoted character handling - https://github.com/validates-email-format-of/validates_email_format_of/issues/69
* Improve grammar for parsing domain part and validate domain part lengths - https://github.com/validates-email-format-of/validates_email_format_of/commit/2554b55e547c1fae6599d13b0c99296752888c91
* Do not strip spaces before validating - https://github.com/validates-email-format-of/validates_email_format_of/issues/61 and https://github.com/validates-email-format-of/validates_email_format_of/issues/72
* Allow setting check_mx_timeout and reduce the default timeout to 3 seconds - https://github.com/validates-email-format-of/validates_email_format_of/issues/66
* Fix regex duplicate character warning - https://github.com/validates-email-format-of/validates_email_format_of/pull/71
* Update CI to include Ruby 2.6 to 3.1 and Rails 4.2 to 7.0

[1.7.0]: https://github.com/validates-email-format-of/validates_email_format_of/compare/v1.6.1...v1.7.0
## [1.6.1] (8 Sept 2014)

* In a Rails context, this gem now uses ActiveModel's default logic for constructing I18n keys, to make it easier to override them on a model/attribute basis.

[1.6.1]: https://github.com/validates-email-format-of/validates_email_format_of/compare/v1.6.0...v1.6.1
