module Hyde
  module Commands
    class Serve < Command
      def self.process(options)
        Hyde.logger.info "Starting server...", ''
        Jekyll::Commands::Serve.process(Hyde::jekyll_configuration(options))
      end
    end
  end
end