desc 'Load CMI sample data'

namespace :cmi do
  task :load_sample_data => :environment do
    begin
      CMI::Loaders::SampleData.load
      puts 'Default cmi configuration data loaded.'
    rescue => error
      puts "Error: #{error}"
      puts 'Default cmi configuration data was not loaded.'
    end
  end
end
