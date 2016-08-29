$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'recurring_scheduler/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'recurring_scheduler'
  s.version     = RecurringScheduler::VERSION
  s.authors     = ['Anton Fefilov']
  s.email       = ['anton.fefilov@macrocoders.com']
  s.homepage    = 'https://github.com/macrocoders/recurring_scheduler'
  s.summary     = 'Recurring scheduler gem'
  s.description = 'Recurring scheduler gem'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'activejob', '~> 4.2'
  s.add_dependency 'ice_cube'

  s.add_development_dependency 'rake'
end
