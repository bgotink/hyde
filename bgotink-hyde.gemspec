Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'bgotink-hyde'
  s.version           = '0.1.0'
  s.license           = 'MIT'
  s.date              = '2014-01-08'
  s.rubyforge_project = 'bgotink-hyde'

  s.summary     = "A user-friendly front-end for Jekyll"
  s.description = "Hyde is a simple front-end for Jekyll, the simple, blog-aware static site generator."

  s.authors  = ["Bram Gotink"]
  s.email    = 'bram@gotink.me'
  s.homepage = 'http://github.com/bgotink/hyde'

  s.require_paths = %w[lib]

  s.executables = ["hyde"]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_runtime_dependency('jekyll', "~> 1.4.2")
  s.add_runtime_dependency('listen', "~> 1.3")
  s.add_runtime_dependency('commander', "~> 4.1.3")
  s.add_runtime_dependency('safe_yaml', "~> 0.9.7")

  s.add_development_dependency('rake', "~> 10.1")
  # s.add_development_dependency('rdoc', "~> 3.11")
  # s.add_development_dependency('redgreen', "~> 1.2")
  # s.add_development_dependency('shoulda', "~> 3.3.2")
  # s.add_development_dependency('rr', "~> 1.1")
  # s.add_development_dependency('cucumber', "~> 1.3")
  # s.add_development_dependency('RedCloth', "~> 4.2")
  # s.add_development_dependency('kramdown', "~> 1.2")
  # s.add_development_dependency('rdiscount', "~> 1.6")
  # s.add_development_dependency('launchy', "~> 2.3")
  # s.add_development_dependency('simplecov', "~> 0.7")
  # s.add_development_dependency('simplecov-gem-adapter', "~> 1.0.1")
  # s.add_development_dependency('coveralls', "~> 0.7.0")
  # s.add_development_dependency('mime-types', "~> 1.5")
  # s.add_development_dependency('activesupport', '~> 3.2.13')
  # s.add_development_dependency('jekyll_test_plugin')

  # = MANIFEST =
  s.files = %w[
    Gemfile
    History.md
    LICENSE
    README.md
    Rakefile
    bgotink-hyde.gemspec
    bin/hyde
    lib/hyde.rb
    lib/hyde/command.rb
    lib/hyde/commands/build.rb
    lib/hyde/commands/serve.rb
    lib/hyde/configuration.rb
    lib/hyde/jekyllfile.rb
    lib/hyde/site.rb
    lib/hyde/stevenson.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end
