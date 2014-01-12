module Hyde
  
  class Site
    attr_accessor :options, :pages, :posts
    attr_accessor :source, :template, :dest
    attr_accessor :time, :files
    
    def initialize(options)
      self.options = options
      
      self.pages = options['pages']
      self.posts = options['posts']

      self.source = File.expand_path(options['source'])
      self.template = File.expand_path(options['template']['directory'])
      self.dest = File.expand_path(options['intermediary']['directory'])
      
      self.reset
      self.setup
    end
    
    def process
      self.reset
      self.copy_template
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
      if options['destination']['branch']
        clone_directory(options['destination'])
      else
        FileUtils.rm_rf(dest)
      end
      
      clone_directory(options['template']) if options['template']['branch']
      
      FileUtils.rm_rf(dest)
      FileUtils.mkdir_p(dest)
    end
      
    private
    
    def clone_directory(options)
      directory = options['directory']
      branch = options['branch']
      update = (options['update'] == true || options['update'] == 'true')
      
      unless File.directory?('.git')
        Hyde.logger.abort_with "Not a git repo:", "The current directory is not a git repository."
      end
      
      if File.exists?(directory)
        if File.directory?(directory)
          # if git: cd && git pull
          if File.directory?(File.join(directory, '.git')) and update
            Hyde.logger.info 'Updating directory:', "Pulling branch #{branch} in #{directory}..."
            `cd #{directory} && git pull`
            Hyde.logger.info '', 'done'
          elsif update
            Hyde.logger.warn 'Expected git repo:', "Expected #{directory} to be a git repo"
            Hyde.logger.warn '', 'as a branch was supplied to pull from.'
          end
        else
          Hyde.logger.abort_with 'Expected directory:', "#{directory} but found file"
        end
      else
        Hyde.logger.info 'Cloning template:', "Cloning branch #{branch} into #{directory}..."
        `git new-workdir . #{directory} #{branch}`
        Hyde.logger.info '', 'done.'
      end
    end
    
    public
    
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
    
    def copy_template
      FileUtils.cp_r(Dir[File.join(template, '*')], dest, :preserve => true)
    end
    
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
        source = File.join(self.source, source)
        
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
      self.files = Array.new
      FileUtils.rm_rf(self.dest) unless options['keep'] or options['watching'] or options['serving']
    end
    
    # runs Jekyll
    def build
      jekyll_options = Hash.new
      
      %w[safe verbose].each do |c|
        jekyll_options[c] = options[c] if options[c]
      end

      jekyll_options['destination'] = options['destination']['directory']
      jekyll_options['source'] = self.dest

      jekyll_options = Jekyll::configuration(jekyll_options)
      Jekyll::Commands::Build.process(jekyll_options)
    end
  end
  
end