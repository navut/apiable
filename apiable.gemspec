# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)

Gem::Specification.new do |g|
  g.name = 'Apiable'
  g.version = '0.0.1'
  g.platform = Gem::Platform::RUBY
  g.authors = ['Matheus Paschoal', 'Gustavo Burckhardt']
  g.email = ['matheus@navut.com']
  g.homepage = 'https://github.com/navut/apiable'
  g.summary = 'Simplified version of ruby objects'
  g.description = 'Add simplified version of instance for easy and safe operation'
  g.add_development_dependency 'rspec', '3.5.0'
  g.files = Dir.glob("{lib}/**/*") + %w(LICENSE README.md)
  g.require_path = 'lib'
end
