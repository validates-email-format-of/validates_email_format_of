require 'rake'

spec = Gem::Specification.new do |s|
  s.name = 'validates_email_format_of'
  s.version = '1.4.2'
  s.summary = 'Validate e-mail addresses against RFC 2822 and RFC 3696.'
  s.description = s.summary
  s.extra_rdoc_files = ['README.rdoc', 'CHANGELOG.rdoc', 'MIT-LICENSE']
  s.test_files = FileList['test/**/*.rb', 'test/**/*.yml'].to_a
  s.files = FileList['MIT-LICENSE', '*.rb', '*.rdoc', 'lib/**/*.rb', 'test/**/*.rb', 'test/**/*.yml'].to_a
  s.require_path = 'lib'
  s.has_rdoc = true
  s.rdoc_options << '--title' <<  'validates_email_format_of'
  s.author = "Alex Dunae"
  s.email = "code@dunae.ca"
  s.homepage = "https://github.com/alexdunae/validates_email_format_of"
end

