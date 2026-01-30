# frozen_string_literal: true
require "spec_helper"

RSpec.describe "Stopword handling" do
  solr = RSolr.connect(url: ENV["SOLR_WEB_URL"])

  let(:response) { solr.get("search", params: { q: search_term, rows: 10 }) }
  let(:docs) { (response.dig("response", "docs") || []) }

  context "search term begins with 'but' for art activism page" do
    let(:search_term) { "but is it art" }
    let(:titles) { docs.map { |doc| doc["web_title_display"] }.flatten }

    before(:all) do
      solr.add(
        "id" => "webpage_9999",
        "record_update_date" => "2026-01-30T00:00:00Z",
        "web_content_type_t" => "webpage",
        "web_content_type_facet" => "Pages",
        "web_content_type_boost_i" => 3,
        "web_title_display" => "But is it art? : the spirit of art as activism",
        "title_sort" => "But is it art? : the spirit of art as activism",
        "web_full_description_t" => "But Is It Art? is a groundbreaking anthology about the recent explosion of art that agitates for progressive social change."
      )
      solr.commit
    end

    after(:all) do
      solr.delete_by_id("webpage_9999")
      solr.commit
    end

    it "returns the art activism page first" do
      expect(titles.first).to eq("But is it art? : the spirit of art as activism"),
        "expected art activism page first, got: #{titles.first.inspect}"
    end
  end

  context "analyzer retains leading 'but' token" do
    let(:analysis) do
      solr.get("analysis/field", params: {
        wt: "json",
        "analysis.showmatch": "true",
        "analysis.fieldtype": "text_en",
        "analysis.fieldvalue": "but is it art"
      })
    end

    let(:tokens) do
      stages = analysis.dig("analysis", "field_types", "text_en", "index") || []
      token_stages = stages.select { |stage| stage.is_a?(Array) && stage.first.is_a?(Hash) }
      final_stage = token_stages.last || []
      final_stage.map { |token| token["text"] }
    end

    it "keeps 'but' when it is not a stopword" do
      expect(tokens).to include("but"),
        "expected analyzer tokens to include 'but'; tokens were: #{tokens.inspect}"
    end
  end
end
