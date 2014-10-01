Gem::Specification.new do |s|
  s.name        = 'permanent_record'
  s.version     = '0.0.2'
  s.date        = '2014-10-01'
  s.summary     = 'Persistent Data without a DB.'
  s.description = 'ActiveRecord type READ ONLY data storage for small amounts of simple, unchanging data.'
  s.authors     = ['Caleb K Matthiesen']
  s.email       = ['c@calebkm.com']
  s.files       = ["lib/permanent_record.rb"]
  s.homepage    = 'https://github.com/calebkm/permanent_record'
  s.license     = 'MIT'

  s.add_dependency 'activemodel', '~> 4.1'   # This helps with Rails path helpers
  s.add_dependency 'activesupport', '~> 4.1' # This gives us some nice string manipulation methods
  s.add_development_dependency 'rake', '~> 10.3'
end