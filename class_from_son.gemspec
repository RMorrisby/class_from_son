Gem::Specification.new do |s|
  s.name        = 'class_from_son'
  s.version     = '0.1.7'
  s.licenses    = ['MIT']
  s.summary     = "Generates classes from Serialised-Object-Notation (e.g. JSON)"
  s.description = "This gem will attempt to generate code of a class of an object representing the contents of a Serialised-Object-Notation (SON) string (or file). E.g. it will generate code of a object's class from some JSON."
  s.authors     = ["Richard Morrisby"]
  s.email       = 'rmorrisby@gmail.com'
  s.files       = Dir["lib/**"]
  s.homepage    = 'https://rubygems.org/gems/class_from_son'
  s.required_ruby_version = '>=1.9'
  s.test_files = Dir["test/test*.rb"]
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md"]
end