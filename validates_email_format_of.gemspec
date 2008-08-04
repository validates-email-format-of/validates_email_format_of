Gem::Specification.new do |s|
  s.name = %q{validates_email_format_of}
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new("= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Dunae"]
  s.date = %q{2008-07-02}
  s.description = %q{Validate e-mail addreses against RFC 2822 and RFC 3696}
  s.email = %q{code@code.dunae.ca}
  s.extra_rdoc_files = ["CHANGELOG", "lib/validates_email_format_of.rb", "README.markdown"]
  s.files = ["CHANGELOG", "init.rb", "lib/validates_email_format_of.rb", "MIT-LICENSE", "rails/init.rb", "rakefile", "README", "test/database.yml", "test/fixtures/people.yml", "test/fixtures/person.rb", "test/schema.rb", "test/test_helper.rb", "test/validates_email_format_of_test.rb", "Rakefile", "Manifest", "validates_email_format_of.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://code.dunae.ca/validates_email_format_of.html}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Validates_email_format_of"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{validates_email_format_of}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Validate e-mail addreses against RFC 2822 and RFC 3696}
  s.test_files = ["test/test_helper.rb", "test/validates_email_format_of_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
