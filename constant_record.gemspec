Gem::Specification.new do |s|
  s.name        = 'constant_record'
  s.version     = '0.0.0'
  s.date        = '2014-09-29'
  s.summary     = ""
  s.description = "Retrieve data from a hash"
  s.authors     = ["Caleb K Matthiesen"]
  s.email       = ['c@calebkm.com']
  s.files       = ["lib/constant_record.rb"]
  s.homepage    = 'https://github.com/calebkm/constant_record'
  s.license     = 'MIT'

  s.add_dependency 'activemodel', '~> 4.1.6'
  s.add_dependency 'activesupport', '~> 4.1.6'
end