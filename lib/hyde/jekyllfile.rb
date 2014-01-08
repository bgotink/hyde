module Hyde
  
  class JekyllFile
    attr_accessor :original, :destination
    
    def initialize(location, destination)
      self.original = File.absolute_path(location)
      data = read_yaml(self.original)
    
      name = File.basename(location)
      time = if data['hyde_date']
               Time.parse(data['hyde_date'])
             else 
               File.mtime(location)
             end
    
      dest_file_name = "#{time.strftime('%Y-%m-%d')}-#{name}"
    
      self.destination = File.join(destination, dest_file_name)
    end
  
    def write
      File.symlink(self.original, self.destination)
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