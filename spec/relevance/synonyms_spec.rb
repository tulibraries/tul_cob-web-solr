# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Key Word Relevance" do
  solr = RSolr.connect(url: ENV["SOLR_WEB_URL"])

  let(:response) { solr.get("search", params: { q: search_term, rows: 10 }) }
  let(:docs) { (response.dig("response", "docs") || []) }

  describe "words in the synonyms.txt file should raise relevancy" do
    context "search term all fields = fines" do
      let(:search_term) { "fines" }
      let(:links) { docs.map { |doc| doc["web_url_display"] }.flatten }

      it "should return the borrowing service first" do
        expect(links.first).to eq("https://library.temple.edu/services/borrowing")
      end
    end
  end
end
