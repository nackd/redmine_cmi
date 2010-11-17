desc 'Load CMI default configuration data. Language is chosen interactively or by setting REDMINE_LANG environment variable.'

namespace :cmi do
  task :load_default_data => :environment do
    include Redmine::I18n
    set_language_if_valid('en')

    begin
      CMI::DefaultData::Loader.load(current_language)
      puts "Default cmi configuration data loaded."
    rescue CMI::DefaultData::DataAlreadyLoaded => error
      puts error
    rescue => error
      puts "Error: " + error
      puts "Default cmi configuration data was not loaded."
    end
  end
end
