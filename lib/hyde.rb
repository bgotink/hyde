$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

require 'jekyll'

def require_all(directory)
  glob = File.join(File.dirname(__FILE__), directory, '*.rb')
  Dir[glob].each do |f|
    require f
  end
end

require 'hyde/configuration'
require 'hyde/page'
require 'hyde/post'
require 'hyde/site'
require 'hyde/command'
require 'hyde/stevenson'

require_all 'hyde/commands'

module Hyde
  VERSION = '0.2.1'

  # Public: Generate a Hyde configuration Hash by merging the default
  # options with anything in _config.yml, and adding the given options on top.
  #
  # override - A Hash of config directives that override any options in both
  #            the defaults and the config file. See Hyde::Configuration::DEFAULTS for a
  #            list of option names and their defaults.
  #
  # Returns the final configuration Hash.
  def self.configuration(override)
    config = Configuration[Configuration::DEFAULTS]
    override = Configuration[override].stringify_keys
    config = config.read_config_files(config.config_files(override))

    # Merge DEFAULTS < _config.yml < override
    config = config.deep_merge(override).stringify_keys
    set_timezone(config['timezone']) if config['timezone']

    config
  end
  
  def self.jekyll_configuration(configuration)
    config = Jekyll::Configuration[Jekyll::Configuration::DEFAULTS]
    override = Jekyll::Configuration[{
      'source' => configuration['intermediary']['directory'],
      'destination' => configuration['destination']['directory']
    }].stringify_keys
    config = config.read_config_files(config.config_files(override))
    
    config.stringify_keys
  end
  
  def self.logger
    @logger ||= Stevenson.new
  end
end
