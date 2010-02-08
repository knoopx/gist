module Gist::Scraper
  class GistCollection < Scraper
    elements "div#files div.file" => :gists, :with => Gist
  end
end