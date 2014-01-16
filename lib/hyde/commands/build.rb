module Hyde
  module Commands
    class Build < Command
      
      def self.process(options)
        site = Hyde::Site.new(options)
        
        options['watching'] = true if options['watch']
        
        self.build(site, options)
        self.watch(site, options) if options['watch']
      end
      
      def self.build(site, options)
        source = options['source']
        jekyll = options['template']['directory']
        jekyll_out = options['intermediary']['directory']
        destination = options['destination']['directory']
        
        Hyde.logger.info "Source:", source
        Hyde.logger.info "Jekyll input:", jekyll
        Hyde.logger.info "Jekyll output:", jekyll_out
        Hyde.logger.info "Destination:", destination
        
        Hyde.logger.info "Running Jekyll...", ""
        
        site.process
        
        Hyde.logger.info "", "done."
      end
      
      def self.watch(site, options)
        require 'listen'
        
        source = options['source']
        template = options['template']['directory']

        ignored = Array.new
        %w[intermediary destination].each do |o|
          begin
            d = Pathname.new(options[o]['directory']).relative_path_from(Pathname.new(source)).to_s
            ignored << Regexp.escape(d)
          rescue ArgumentError
            # nop
          end
        end
        
        if ignored.empty?
          ignored = nil
        else
          ignored = Regexp.new(ignored.join('|'))
        end
        
        Hyde.logger.info 'Auto-regeneration:', 'enabled'
        
        listener = Listen::Listener.new([source, template], :ignore => ignored) do |modified, added, removed|
          t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          n = modified.length + added.length + removed.length
          Hyde.logger.info "Regenerating:", "#{n} files at #{t} "
          
          site.process
          
          Hyde.logger.info "", "done."
        end
        listener.start
        
        trap("USR1") do
          t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          Hyde.logger.info "Regenerating:", "received USR1 signal at #{t}"
          
          thread = Thread.new { site.process }
          thread.join
          
          Hyde.logger.info "", "done."
        end

        unless options['serving']
          trap("INT") do
            options['watching'] = false
            
            listener.stop
            site.cleanup
            
            puts "     Halting auto-regeneration."
            exit 0
          end

          loop { sleep 1000 }
        end
      end
      
    end
  end
end