spec = Gem::Specification.new do |s|
  s.name = 'validates_email_format_of'
  s.version = '1.3'
  s.summary = "Validate various formats of email address against RFC 2822."
  s.description = %{Validate various formats of email address against RFC 2822.}
  s.files = Dir['*'] + Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = Dir['[A-Z]*']
  s.rdoc_options << '--title' <<  'validates_email_format_of plugin'
  s.author = "Alex Dunae"
  s.email = "code@dunae.ca"
  s.homepage = "http://code.dunae.ca/validates_email_format_of.html"
end

