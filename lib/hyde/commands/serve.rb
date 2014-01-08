module Hyde
  module Commands
    class Serve < Hyde::Command
      def self.process(options)
        Jekyll::Commands::Serve.process(Hyde::jekyll_configuration(options))
      end
    end
  end
end