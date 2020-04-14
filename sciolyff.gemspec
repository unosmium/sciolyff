# frozen_string_literal: true

Gem::Specification.new do |s|
  s.authors  = ['Em Zhan']
  s.homepage = 'https://github.com/zqianem/sciolyff'
  s.files    = `git ls-files -z`.split("\x0").reject do |f|
    f.start_with? 'examples/', '.'
  end
  s.license  = 'MIT'
  s.name     = 'sciolyff'
  s.summary  = 'A file format for Science Olympiad tournament results.'
  s.version  = '0.9.1'
  s.executables << 'sciolyff'
  s.add_runtime_dependency 'erubi', '~> 1.9'
  s.add_runtime_dependency 'optimist', '~> 3.0'
  s.add_runtime_dependency 'psych', '~> 3.1'
  s.required_ruby_version = '>= 2.5'
end
