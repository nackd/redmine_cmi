namespace :cmi do
  desc 'Create CMI needed custom fields'
  task :create_data => :environment do
    begin
      CMI::Loaders::CreateData.load
      puts 'CMI custom fields created.'
    rescue => error
      puts "Error: #{error}"
      puts 'CMI custom fields NOT created.'
    end
  end
end
