module Hyde
  
  class Site
    attr_accessor :config, :map, :source, :jekyll_source, :dest, :time, :files
    
    def initialize(config)
      self.config = config
      
      self.map = config['map'] || {}
      self.source = File.expand_path(config['source'])
      self.jekyll_source = File.expand_path(config['jekyll'])
      self.dest = File.expand_path(config['jekyll-out'])
      
      self.reset
      self.setup
    end
    
    def process
      self.reset
      self.directories
      self.read
      self.write
      self.build
      self.cleanup
    end
    
    # reset the time
    def reset
      self.time = if self.config['time']
                    Time.parse(self.config['time'].to_s)
                  else
                    Time.now
                  end
    end
    
    # copy Jekyll source files
    def setup
      FileUtils.rm_rf(self.dest)
      FileUtils.cp_r(self.jekyll_source, self.dest, :preserve => true)
    end
    
    # create the Hyde-to-Jekyll output directories
    def directories
      self.map.each do |source_d, dest_d|
        source = File.join(self.source, source_d)
        if File.exists?(source)
          dest = File.join(self.dest, dest_d)
          if File.exists?(dest)
            Hyde.logger.abort_with 'Illegal file:' "Expected destination file #{dest_d}/_posts to be a directory but found a file" unless File.directory?(dest)
            Hyde.logger.warn 'Destination exists:', "Destination directory #{dest_d} exists, deleting content" unless self.config['watching']
            
            Dir[File.join(dest, '*')].each do |f|
              FileUtils.rm_rf(f)
            end
          else
            FileUtils.mkdir_p(dest)
          end
        else
          Hyde.logger.warn 'File not found:', "Directory #{source_d} does not exist, skipping directory"
        end
      end
    end
    
    # read files
    def read
      self.files ||= Hash.new
      self.map.each do |source_d, dest_d|
        files = Hash.new
        Hyde.logger.error 'Duplicate source:', "directory \"#{source_d}\"" if self.files[source_d]
        self.files[source_d] = files
        
        read_directory(source_d, files, File.join(self.dest, dest_d))
      end
    end
    
    private
    
    def read_directory(directory, data, destination)
      Dir[File.join(directory, '*')].sort.each do |file|
        if File.directory?(file)
          fdata = Hash.new
          read_directory(file, fdata, destination)
          data[File.basename(file)] = fdata
        else
          data[File.basename(file)] = JekyllFile.new(file, destination)
        end
      end
    end
    
    public
    
    # write jekyll files
    def write
      self.files.each do |name, files|
        write_recursive(files, File.join(self.dest, self.map[name]))
      end
    end
    
    private
    
    def write_recursive(files, directory)
      files.each do |name, file|
        if file.is_a?(JekyllFile)
          file.write
        else
          write_recursive(file, directory)
        end
      end
    end
    
    public
    
    # cleanup
    def cleanup
      self.files = Hash.new
      FileUtils.rm_rf(self.dest) unless self.config['keep'] or self.config['watching']
    end
    
    # runs Jekyll
    def build
      jekyll_options = Hash.new
      
      %w[safe destination verbose].each do |c|
        jekyll_options[c] = self.config[c] if self.config[c]
      end

      jekyll_options['source'] = self.dest

      jekyll_options = Jekyll::configuration(jekyll_options)
      Jekyll::Commands::Build.process(jekyll_options)
    end
  end
  
end