require 'httparty'
require 'nokogiri'
require 'gist/scraper'
require 'gist/scraper/gist.rb'
require 'gist/scraper/gist_collection.rb'

class Gist::Gist
  attr_reader :id
  attr_reader :description
  attr_reader :created_at
  attr_reader :privacity

  def initialize(id, description, created_at, public = true)
    @id = id
    @description = description
    @created_at = created_at
    @privacity = public ? "Public" : "Private"
  end
end

class Gist::API
  include HTTParty

  format :yaml
  base_uri "gist.github.com/api/v1/#{default_options[:format]}"

  def self.gist_url(id, format = :none)
    case format
      when :none
        "http://gist.github.com/#{id}"
      when :text
        "http://gist.github.com/#{id}.txt"
      when :git
        "git://gist.github.com/#{id}.git"
    end
  end

  def self.post_gist(files, options = {})
    options[:files] ||= {}
    files.each do |filename|
      options[:files][filename] = File.read(filename)
    end
    gist = self.post("/new", :query => options)["gists"].first
    [Gist::Gist.new(gist[:repo], gist[:description], gist[:created_at], gist[:public])]
  end

  def self.get_gist(id)
    self.get(self.gist_url(id, :text))
  end
  
  def self.delete_gist(id, options)
    options.merge!({ :_method => :delete })
    self.post("http://gist.github.com/delete/#{id}", :query => options, :format => :html)
  end

  def self.list_gists(user, options)
    if options.include?(:login) and options.include?(:token)
      url = "http://gist.github.com/mine"
    else
      url = "http://gist.github.com/#{user}"
    end
    Gist::Scraper::GistCollection.parse(Nokogiri(self.get(url, :query => options, :format => :html))).gists
  end
end