GEM = "benchwarmer"
VERSION = "0.5"
AUTHOR = "Yehuda Katz"
EMAIL = "wycats@gmail.com"
HOMEPAGE = "http://yehudakatz.com"
SUMMARY = "A gem that provides a prettier formatting and DSL for Ruby benchmarks"

GEMSPEC = Gem::Specification.new do |s|
  s.name = GEM
  s.version = VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README Rakefile lib/benchwarmer.rb lib/vendor/dictionary.rb)
end
