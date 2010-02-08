module Gist::Scraper
  class Gist < Scraper
    attr_accessor :privacity

    def initialize(doc)
      super
      @privacity = self.doc.attributes['class'].value.split(/\s+/).include?("public") ? "Public" : "Private"
    end

    element 'div.info a' => :id, :with => lambda { |v| v.attributes['href'].value.delete("/") }
    element 'div.info span:last-child' => :description
    element 'div.date abbr' => :created_at
  end
end