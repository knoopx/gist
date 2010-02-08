require 'rubygems'
require 'fileutils'
require './lib/gist'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "knoopx-gist"
    gem.summary = "Command-line interface for http://gist.github.com"
    gem.description = "Command-line interface for http://gist.github.com"
    gem.email = "knoopx@gmail.com"
    gem.homepage = "http://github.com/knoopx/gist"
    gem.authors = ["V’ctor Mart’nez"]
    gem.add_dependency('commander', '~> 4.0.2')
    gem.add_dependency('terminal-table', '~> 1.4.2')
    gem.add_dependency('httparty', '~> 0.5.2')
    gem.add_dependency('hpricot', '~> 0.8.2')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end