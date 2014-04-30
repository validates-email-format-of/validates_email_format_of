module ValidatesEmailFormatOf
  class Railtie < Rails::Railtie
    initializer 'validates_email_format_of.load_i18n_locales' do |app|
      ValidatesEmailFormatOf::load_i18n_locales
    end
  end
end
