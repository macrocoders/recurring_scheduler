$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'recurring_scheduler/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'recurring_scheduler'
  s.version     = RecurringScheduler::VERSION
  s.authors     = ['Anton Fefilov']
  s.email       = ['anton.fefilov@flatstack.com']
  s.homepage    = 'https://github.com/antonfefilov/recurring_scheduler'
  s.summary     = 'Recurring scheduler gem'
  s.description = 'Recurring scheduler gem'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '4.1.6'

  s.add_development_dependency 'rake'
  # s.add_development_dependency 'pg'
end
