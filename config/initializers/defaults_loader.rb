config_file = File.read("#{File.dirname(__FILE__)}/../defaults.yml")
DEFAULT_VALUES = YAML.load(config_file)
