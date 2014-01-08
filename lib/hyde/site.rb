module Hyde
  
  class Site
    attr_accessor :options, :pages, :posts, :source, :jekyll_source, :dest, :time, :files
    
    def initialize(options)
      self.options = options
      
      self.pages = options['pages']
      self.posts = options['posts']

      self.source = File.expand_path(options['source'])
      self.jekyll_source = File.expand_path(options['jekyll'])
      self.dest = File.expand_path(options['jekyll-out'])
      
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
      self.time = if options['time']
                    Time.parse(options['time'].to_s)
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
      directories_helper(pages)
      directories_helper(posts, '_posts')
    end
    
    private
    
    def directories_helper(data, dest_suffix = '')
      data.each do |source, dest|
        source = File.join(self.source, source)
        dest = File.join(self.dest, dest, dest_suffix)

        unless File.exists?(source)
          Hyde.logger.warn 'File not found:', "File/directory #{source} does not exist, skipping"
          return
        end

        if File.exists?(dest)
          unless File.directory?(source) == File.directory?(dest)
            Hyde.logger.abort_with 'Illegal file:', "Expected #{dest} to be a #{File.directory?(source) ? 'directory but found file.' : 'file but found directory.'}" 
          end

          FileUtils.rm_rf(dest)
        end

        # if directory: create directory, otherwise nop
        if File.directory?(source)
          FileUtils.mkdir_p(dest)
        end
      end
    end
    
    public
    
    # read files
    def read
      self.files ||= Array.new
      
      read_files(pages) do | source, destination |
        files << Page.new(source, File.join(self.dest, destination))
      end
      read_files(posts) do | source, destination |
        files << Post.new(source, File.join(self.dest, destination))
      end
    end
    
    private
    
    def read_files(files)
      files.each do | source, destination |
        if File.directory?(source)
          read_directory(source, destination) { |s,d| yield(s,d) }
        else
          yield(source, destination)
        end
      end
    end
    
    def read_directory(directory, destination)
      Dir[File.join(directory, '*')].sort.each do |source|
        if File.directory?(source)
          read_directory(source, destination) { |s,d| yield(s,d) }
        else
          yield(source, destination)
        end
      end
    end
    
    public
    
    # write jekyll files
    def write
      files.each do |file|
        file.write
      end
    end
    
    # cleanup
    def cleanup
      self.files = Hash.new
      FileUtils.rm_rf(self.dest) unless options['keep'] or options['watching']
    end
    
    # runs Jekyll
    def build
      jekyll_options = Hash.new
      
      %w[safe destination verbose].each do |c|
        jekyll_options[c] = options[c] if options[c]
      end

      jekyll_options['source'] = self.dest

      jekyll_options = Jekyll::configuration(jekyll_options)
      Jekyll::Commands::Build.process(jekyll_options)
    end
  end
  
end