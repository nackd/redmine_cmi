desc 'Load CMI needed data (trackers, issue statuses, issue priorities and custom fields)'

namespace :cmi do
  task :create_data => :environment do
    begin
      CMI::Loaders::CreateData.load
      puts 'Default cmi configuration data loaded.'
    rescue => error
      puts "Error: #{error}"
      puts 'Default cmi configuration data was not loaded.'
    end
  end
end
