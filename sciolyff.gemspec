require 'rake'

Gem::Specification.new do |s|
  s.authors  = ['Em Zhan']
  s.homepage = 'https://github.com/zqianem/sciolyff'
  s.files    = FileList['lib/sciolyff.rb', 'lib/sciolyff/*.rb', 'bin/*']
  s.license  = 'MIT'
  s.name     = 'sciolyff'
  s.summary  = 'A file format for Science Olympiad tournament results.'
  s.version  = '0.1.1'
  s.executables << 'sciolyff'
  s.add_runtime_dependency 'minitest', '~> 5.11'
  s.add_runtime_dependency 'optimist', '~> 3.0'
  s.add_development_dependency 'rake', '~> 12.3'
end
