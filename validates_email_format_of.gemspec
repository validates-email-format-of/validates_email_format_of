# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('../lib', __FILE__)
require 'validates_email_format_of'

spec = Gem::Specification.new do |s|
  s.name          = 'validates_email_format_of'
  s.version       = ValidatesEmailFormatOf::VERSION
  s.summary       = 'Validate e-mail addresses against RFC 2822 and RFC 3696.'
  s.description   = s.summary
  s.author        = 'Alex Dunae'
  s.email         = 'code@dunae.ca'
  s.homepage      = 'https://github.com/alexdunae/validates_email_format_of'
  s.license       = 'MIT'
  s.test_files    = s.files.grep(%r{^test/})
  s.files         = `git ls-files`.split($/)
  s.require_paths = ['lib']
end
