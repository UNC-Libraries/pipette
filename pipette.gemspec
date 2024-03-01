require_relative "lib/pipette/version"

Gem::Specification.new do |spec|
  spec.name        = "pipette"
  spec.version     = Pipette::VERSION
  spec.authors     = ["lfarrell"]
  spec.email       = ["lfarrell@email.unc.edu"]
  spec.homepage    = "http://gitlab.lib.unc.edu"
  spec.summary     = "App to index content from ArchivesSpace to Arclight"
  spec.description = "App to index content from ArchivesSpace to Arclight."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://gitlab.lib.unc.edu"
  spec.metadata["changelog_uri"] = "http://gitlab.lib.unc.edu"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency 'archivesspace-client', '>= 0.2.0'
  spec.add_dependency 'bootstrap', '~> 5.1'
  spec.add_dependency 'devise', '~> 4.9.2'
  spec.add_dependency 'devise-guests', '~> 0.8.1'
  spec.add_dependency 'git', '~> 1.18'
  spec.add_dependency 'httparty', '>= 0.21.0'
  spec.add_dependency 'omniauth', '~> 2.0'
  spec.add_dependency 'omniauth-rails_csrf_protection'
  spec.add_dependency 'omniauth-shibboleth', '~> 1.3'
  spec.add_dependency 'rails', '~> 7.0.8'
  spec.add_dependency 'sidekiq', '~> 6.5.12'
  spec.add_dependency 'sidekiq-status', '~> 2.1.3'

  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'rspec-rails', '~> 6.0'
  spec.add_development_dependency 'selenium-webdriver'
  spec.add_development_dependency 'webdrivers'
  spec.add_development_dependency 'webmock', '~> 3.18'
end
