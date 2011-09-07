spec = Gem::Specification.new do |s|
  s.name = 'validates_email_format_of'
  s.version = '1.5.0'
  s.summary = 'Validate e-mail addresses against RFC 2822 and RFC 3696.'
  s.description = s.summary
  s.extra_rdoc_files = ['README.rdoc', 'MIT-LICENSE']
  s.test_files = Dir['test/**/*.rb', 'test/**/*.yml']
  s.files = Dir['MIT-LICENSE', '*.rb', '*.rdoc', 'lib/**/*.rb', 'test/**/*.rb', 'test/**/*.yml']
  s.require_path = 'lib'
  s.rdoc_options << '--title' <<  'validates_email_format_of'
  s.author = "Alex Dunae"
  s.email = "code@dunae.ca"
  s.homepage = "https://github.com/alexdunae/validates_email_format_of"
end

