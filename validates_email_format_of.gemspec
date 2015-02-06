# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('../lib', __FILE__)
require 'validates_email_format_of/version'

spec = Gem::Specification.new do |s|
  s.name          = 'validates_email_format_of'
  s.version       = ValidatesEmailFormatOf::VERSION
  s.summary       = 'Validate e-mail addresses against RFC 2822 and RFC 3696.'
  s.description   = s.summary
  s.authors       = ['Alex Dunae', 'Isaac Betesh']
  s.email         = ['code@dunae.ca', 'iybetesh@gmail.com']
  s.homepage      = 'https://github.com/validates-email-format-of/validates_email_format_of'
  s.license       = 'MIT'
  s.test_files    = s.files.grep(%r{^test/})
  s.files         = `git ls-files`.split($/)
  s.require_paths = ['lib']

  if RUBY_VERSION < "1.9.3"
    s.add_dependency 'i18n', '< 0.7.0'
  else
    s.add_dependency 'i18n'
  end

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
end
