module Jekyll
  
  class Stevenson
    def formatted_topic(topic)
      "J " + "#{topic} ".rjust(22)
    end
  end
  
end

module Hyde
  
  class Stevenson < Jekyll::Stevenson
    def formatted_topic(topic)
      "H " + "#{topic} ".rjust(22)
    end 
  end
end