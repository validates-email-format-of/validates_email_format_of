require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => [:clean_log, :test]

desc 'Remove the old log file'
task :clean_log do
  "rm -f #{File.dirname(__FILE__)}/test/debug.log" if File.exists?(File.dirname(__FILE__) + '/test/debug.log')
end

desc 'Test the validates_email_format_of plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = FileList['test/**/*_test.rb']
  t.verbose = true
end

desc 'Generate documentation for the validates_email_format_of plugin and gem.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'validates_email_format_of plugin and gem'
  rdoc.options << '--line-numbers --inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end