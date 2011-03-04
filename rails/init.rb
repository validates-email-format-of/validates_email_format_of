require 'validates_email_format_of'

Dir[File.join(File.dirname(__FILE__), "..", "config", "locales", "*.yml")].each do |loc|
  I18n.load_path << loc
end