module Hyde
  module Commands
    class Build < Command
      
      def self.process(options)
        site = Hyde::Site.new(options)
        
        options['watching'] = true if options['watch']
        
        self.clone_template(options) if options['jekyll-branch']
        
        site.setup
        
        self.build(site, options)
        self.watch(site, options) if options['watch']
      end
      
      def self.clone_template(options)
        jekyll = options['jekyll']
        branch = options['jekyll-branch']
        
        unless File.directory?('.git')
          Hyde.logger.abort_with "Not a git repo:", "The current directory is not a git repository."
        end
        
        if File.exists?(jekyll)
          if File.directory?(jekyll)
            # if git: cd && git pull
            if File.directory?(File.join(jekyll, '.git'))
              Hyde.logger.info 'Updating template:', "Updating template in #{jekyll}..."
              `cd #{jekyll} && git pull`
              Hyde.logger.info '', 'done'
            else
              Hyde.logger.warn 'Expected git repo:', "Expected #{jekyll} to be a git repo"
              Hyde.logger.warn '', 'as a branch was supplied to pull from.'
            end
          else
            Hyde.logger.abort_with 'Expected directory:', "Expected #{jekyll} to be a directory containing a jekyll template, but found file"
          end
        else
          Hyde.logger.info 'Cloning template:', "Cloning branch #{branch} into #{jekyll}..."
          `git new-workdir . #{jekyll} #{branch}`
          Hyde.logger.info '', 'done.'
        end
      end
      
      def self.build(site, options)
        source = options['source']
        jekyll = options['jekyll']
        jekyll_out = options['jekyll-out']
        destination = options['destination']
        
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
        
        # TODO check whether dest is in source?
        
        source = options['source']
        intermediary = options['jekyll-out']
        destination = options['destination']

        ignored = Array.new
        %w[jekyll-out destination].each do |o|
          begin
            d = Pathname.new(options[o]).relative_path_from(Pathname.new(source)).to_s
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
        
        listener = Listen::Listener.new(source, :ignore => ignored) do |modified, added, removed|
          t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          n = modified.length + added.length + removed.length
          Hyde.logger.info "Regenerating:", "#{n} files at #{t} "
          
          site.process
          
          Hyde.logger.info "", "done."
        end
        listener.start

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