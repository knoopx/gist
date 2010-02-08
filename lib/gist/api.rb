require 'httparty'
require 'hpricot'

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
    self.post("/new", :query => options)["gists"]
  end

  def self.get_gist(id)
    self.get(self.gist_url(id, :text))
  end

  def self.list_gists(username, options)
    if options.include?(:login) and options.include?(:token)
      doc = Hpricot(self.get("http://gist.github.com/mine", :query => options, :format => :html))
    else
      doc = Hpricot(self.get("http://gist.github.com/#{username}", :query => options, :format => :html))
    end
    
    gists = []
    doc.search('div#files div.file').each do |gist|
      gists << {
              :description => gist.search("div.info span").last.inner_text,
              :created_at => gist.at("div.date abbr").inner_text,
              :public => gist.attributes['class'].split(/\s+/).include?("public"),
              :repo => gist.at("div.info a").attributes['href'].delete("/")
      }
    end
    gists
  end
end