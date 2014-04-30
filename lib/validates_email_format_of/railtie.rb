module ValidatesEmailFormatOf
  class Railtie < Rails::Railtie
    initializer 'validates_email_format_of.load_i18n_locales' do |app|
      I18n.load_path += Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'locales', '*.yml')))
    end
  end
end
