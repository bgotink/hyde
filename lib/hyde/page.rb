module Hyde
  
  class Page
    attr_accessor :original, :name
    
    def initialize(location, destination)
      @original = File.absolute_path(location)
      @dest_dir = destination
    
      @name = File.basename(location)
    end
    
    def data
      read_yaml(original)
    end
    
    def time
      data = self.data
      if data['hyde_date']
        Time.parse(data['hyde_date'])
      elsif data['date']
        Time.parse(data['date'])
      else 
        File.mtime(original)
      end
    end
    
    def dest_filename
      name
    end
    
    def dest_dir
      @dest_dir
    end
    
    def destination
      File.join(dest_dir, dest_filename)
    end
  
    def write
      FileUtils.cp(original, destination)
    end
    
    private
    
    # Read the YAML frontmatter.
    #
    # base - The String path to the dir containing the file.
    # name - The String filename of the file.
    # opts - optional parameter to File.read, default at site configs
    #
    # Returns nothing.
    def read_yaml(file)
      data = nil
      
      begin
        content = File.read_with_options(file, {})
        if content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
          data = YAML.safe_load($1)
        end
      rescue SyntaxError => e
        puts "YAML Exception reading #{File.join(base, name)}: #{e.message}"
      rescue Exception => e
        puts "Error reading file #{File.join(base, name)}: #{e.message}"
      end

      data ||= {}
    end
  end
end