# frozen_string_literal: true

require 'rake'

Gem::Specification.new do |s|
  s.authors  = ['Em Zhan']
  s.homepage = 'https://github.com/zqianem/sciolyff'
  s.files    = FileList['lib/sciolyff.rb',
                        'lib/sciolyff/*.rb',
                        'lib/sciolyff/interpreter/*.rb',
                        'lib/sciolyff/interpreter/html/*',
                        'lib/sciolyff/validator/*.rb',
                        'bin/*']
  s.license  = 'MIT'
  s.name     = 'sciolyff'
  s.summary  = 'A file format for Science Olympiad tournament results.'
  s.version  = '0.9.1'
  s.executables << 'sciolyff'
  s.add_runtime_dependency 'optimist', '~> 3.0'
  s.add_development_dependency 'rake', '~> 12.3'
  s.required_ruby_version = '>= 2.6.0'
end
