module Hyde
  class Configuration < Hash
    
    DEFAULTS = {
      'source' => Dir.pwd,
      'jekyll' => File.join(Dir.pwd, '_jekyll'),
      'jekyll-out' => File.join(Dir.pwd, '_jekyll-out'),
      'destination' => File.join(Dir.pwd, '_site'),
      
      'keep' => false,
      
      'encoding' => nil,
      
      'safe' => false,
      'detach' => false,
      
      'port'          => Jekyll::Configuration::DEFAULTS['port'],
      'host'          => Jekyll::Configuration::DEFAULTS['host']
    }
    
    # Public: Turn all keys into string
    #
    # Return a copy of the hash where all its keys are strings
    def stringify_keys
      reduce({}) { |hsh,(k,v)| hsh.merge(k.to_s => v) }
    end

    # Public: Directory of the Jekyll source folder
    #
    # override - the command-line options hash
    #
    # Returns the path to the Jekyll source directory
    def source(override)
      override['source'] || self['source'] || DEFAULTS['source']
    end

    def safe_load_file(filename)
      case File.extname(filename)
      when '.toml'
        TOML.load_file(filename)
      when /\.y(a)?ml/
        YAML.safe_load_file(filename)
      else
        raise ArgumentError, "No parser for '#{filename}' is available. Use a .toml or .y(a)ml file instead."
      end
    end

    # Public: Generate list of configuration files from the override
    #
    # override - the command-line options hash
    #
    # Returns an Array of config files
    def config_files(override)
      # Get configuration from <source>/_config.yml or <source>/<config_file>
      config_files = override.delete('config')
      if config_files.to_s.empty?
        config_files = File.join(source(override), "_config.yml")
        @default_config_file = true
      end
      config_files = [config_files] unless config_files.is_a? Array
      config_files
    end

    # Public: Read configuration and return merged Hash
    #
    # file - the path to the YAML file to be read in
    #
    # Returns this configuration, overridden by the values in the file
    def read_config_file(file)
      next_config = safe_load_file(file)
      raise ArgumentError.new("Configuration file: (INVALID) #{file}".yellow) unless next_config.is_a?(Hash)
      Hyde.logger.info "Configuration file:", file
      next_config
    rescue SystemCallError
      if @default_config_file
        Hyde.logger.warn "Configuration file:", "none"
        {}
      else
        Hyde.logger.error "Fatal:", "The configuration file '#{file}' could not be found."
        raise LoadError, "The Configuration file '#{file}' could not be found."
      end
    end

    # Public: Read in a list of configuration files and merge with this hash
    #
    # files - the list of configuration file paths
    #
    # Returns the full configuration, with the defaults overridden by the values in the
    # configuration files
    def read_config_files(files)
      configuration = clone

      begin
        files.each do |config_file|
          new_config = read_config_file(config_file)
          configuration = configuration.deep_merge(new_config)
        end
      rescue ArgumentError => err
        Hyde.logger.warn "WARNING:", "Error reading configuration. " +
                     "Using defaults (and options)."
        $stderr.puts "#{err}"
      end

      configuration.fix_common_issues.backwards_compatibilize
    end
    
    def fix_common_issues
      clone
    end
    
    def backwards_compatibilize
      clone
    end
    
  end
end