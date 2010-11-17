desc 'Create custom fields needed for CMI'

namespace :cmi do
  task :create_custom_fields => :environment do
    begin
      CMI::Loaders::CustomFields.load
      puts 'Default cmi configuration data loaded.'
    rescue => error
      puts "Error: #{error}"
      puts 'Default cmi configuration data was not loaded.'
    end
  end
end
