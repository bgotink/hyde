module Hyde
  
  class Post < Page
    def index?
      name.match(/index(\.[^\.]+)?/)
    end
    
    def dest_filename
      if index?
        name
      else
        "#{time.strftime('%Y-%m-%d')}-#{name}"
      end
    end
    
    def dest_dir
      if index?
        super
      else
        File.join(super, '_posts')
      end
    end
  end
  
end