require 'httparty'

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
    self.get("/gists/#{username}", :query => options)["gists"]
  end
end