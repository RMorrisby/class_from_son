Gem::Specification.new do |s|
  s.name        = 'class_from_son'
  s.version     = '0.1.0'
  s.licenses    = ['MIT']
  s.summary     = "Generates classes from SON (e.g. JSON)"
  s.description = "This gem will attempt to generate code of a class of an object representing the contents of a Serialised-Object-Notation (SON) string (or file). E.g. it will generate code of a object's class from some JSON."
  s.authors     = ["Richard Morrisby"]
  s.email       = 'rmorrisby@gmail.com'
  s.files       = ["lib/class_from_SON.rb"]
  s.homepage    = 'https://rubygems.org/gems/class_from_son'
  s.required_ruby_version = '>=1.9'
  s.files = Dir['**/**']
  s.test_files = Dir["test/test*.rb"]
  s.has_rdoc = true
end