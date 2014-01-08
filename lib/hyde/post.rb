module Hyde
  
  class Post < Page
    def dest_filename
      "#{time.strftime('%Y-%m-%d')}-#{name}"
    end
    
    def dest_dir
      File.join(super, '_posts')
    end
  end
  
end