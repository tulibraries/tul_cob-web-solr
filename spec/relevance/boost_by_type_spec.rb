# frozen_string_literal: true
require 'spec_helper'

RSpec.describe "Key Word Relevance by type" do
  solr = RSolr.connect(url: ENV["SOLR_WEB_URL"])

  let(:response) { solr.get("search", params: { q: search_term, rows: 25 }) }
  let(:docs) { (response.dig("response", "docs") || []) }

  describe "lowering the relevance of events" do
    context "search term all fields = accommodations" do
      let(:search_term) { "accommodations" }
      let(:types) { docs.map { |doc| doc["web_content_type_t"]}.flatten }

      it "should not return events within the first 5 results" do
        expect(types.first(5).any? { |type| type == "event" }).to eq(false),
          "expected not to get event types, got: #{types}"
      end

      it "should return policy type first" do
        expect(types.first).to eq("policy")
      end
    end
  end

  describe "raise the relevance of finding aids over events" do
    context "search term all fields = Informatics" do
      let(:search_term) { "Informatics" }
      let(:types) { docs.map { |doc| doc["web_content_type_t"]}.flatten }

      it "should return finding aids before events" do
        expect(types.index("Finding Aids")).to be < types.index("event"),
          "expected Finding aid before event, got: #{types}"
      end
    end
  end

  describe "raise the relevance of finding aids over highlights" do
    context "search term all fields = Test+Highlight" do
      let(:search_term) { "Test Highlight" }
      let(:types) { docs.map { |doc| doc["web_content_type_t"]}.flatten }

      it "should return finding aids before highlights" do
        expect(types.index("Finding Aids")).to be < types.index("highlight"),
          "expected Finding aid before highlight, got: #{types}"
      end
    end
  end

  describe "Finding aids returns first when most relevant" do
    context "search term all fields = Pennsylvania Ballet" do
      let(:search_term) { "Pennsylvania Ballet" }
      let(:titles) { docs.map { |doc| doc["web_title_display"]}.flatten }

      it "should return finding aids first" do
        expect(titles.first).to eq("Pennsylvania Ballet Records")
      end
    end

    context "search term all fields = occupy" do
      let(:search_term) { "occupy" }
      let(:titles) { docs.map { |doc| doc["web_title_display"]}.flatten }

      it "should return finding aids first" do
        expect(titles.first).to eq("Occupy Philadelphia Records")
      end
    end
  end

  describe "Raising the relevance of people" do
    context "search term all fields = economics" do
      let(:search_term) { "economics" }
      let(:types) { docs.map { |doc| doc["web_content_type_t"]}.flatten }

      it "should return a person within the first 3 results" do
        expect(types.first(3).any? { |type| type == "person" }).to eq(true),
          "expected not to get event types, got: #{types}"
      end
    end
  end
end
