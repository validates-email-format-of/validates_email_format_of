require 'active_model' if Gem.loaded_specs.keys.include?('activemodel')

Dir[File.expand_path('spec/support/**/*.rb')].each { |f| require f }
