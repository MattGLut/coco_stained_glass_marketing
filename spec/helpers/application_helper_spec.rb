# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#set_meta_tags" do
    it "sets the page title" do
      helper.set_meta_tags(title: "Test Title")
      expect(helper.instance_variable_get(:@page_title)).to eq("Test Title")
    end

    it "sets the page description" do
      helper.set_meta_tags(description: "Test description")
      expect(helper.instance_variable_get(:@page_description)).to eq("Test description")
    end

    it "sets the page image" do
      helper.set_meta_tags(image: "https://example.com/image.jpg")
      expect(helper.instance_variable_get(:@page_image)).to eq("https://example.com/image.jpg")
    end

    it "sets the page keywords" do
      helper.set_meta_tags(keywords: "stained glass, art")
      expect(helper.instance_variable_get(:@page_keywords)).to eq("stained glass, art")
    end

    it "sets multiple meta tags at once" do
      helper.set_meta_tags(title: "Title", description: "Desc", image: "img.jpg")
      expect(helper.instance_variable_get(:@page_title)).to eq("Title")
      expect(helper.instance_variable_get(:@page_description)).to eq("Desc")
      expect(helper.instance_variable_get(:@page_image)).to eq("img.jpg")
    end
  end

  describe "#format_price" do
    it "returns em dash for blank amounts" do
      expect(helper.format_price(nil)).to eq("—")
      expect(helper.format_price("")).to eq("—")
    end

    it "formats amount as currency" do
      expect(helper.format_price(1500)).to eq("$1,500.00")
    end

    it "formats decimal amounts" do
      expect(helper.format_price(1234.56)).to eq("$1,234.56")
    end
  end

  describe "#format_date" do
    let(:date) { Date.new(2026, 1, 20) }

    it "returns em dash for blank dates" do
      expect(helper.format_date(nil)).to eq("—")
    end

    it "formats date with :short format" do
      expect(helper.format_date(date, :short)).to eq("Jan 20, 2026")
    end

    it "formats date with :long format (default)" do
      expect(helper.format_date(date, :long)).to eq("January 20, 2026")
      expect(helper.format_date(date)).to eq("January 20, 2026")
    end

    it "formats date with :relative format" do
      recent_date = 2.days.ago.to_date
      result = helper.format_date(recent_date, :relative)
      expect(result).to include("ago")
    end

    it "formats date with custom format string" do
      expect(helper.format_date(date, "%Y-%m-%d")).to eq("2026-01-20")
    end
  end

  describe "#active_link_class" do
    before do
      allow(helper).to receive(:request).and_return(double(path: "/admin/users/1"))
    end

    context "with exact matching" do
      it "returns 'active' when paths match exactly" do
        allow(helper).to receive(:current_page?).with("/admin/users/1").and_return(true)
        expect(helper.active_link_class("/admin/users/1", exact: true)).to eq("active")
      end

      it "returns empty string when paths don't match" do
        allow(helper).to receive(:current_page?).with("/admin/users").and_return(false)
        expect(helper.active_link_class("/admin/users", exact: true)).to eq("")
      end
    end

    context "with prefix matching (default)" do
      it "returns 'active' when path starts with given prefix" do
        expect(helper.active_link_class("/admin/users")).to eq("active")
      end

      it "returns 'active' for parent paths" do
        expect(helper.active_link_class("/admin")).to eq("active")
      end

      it "returns empty string when path doesn't match prefix" do
        expect(helper.active_link_class("/portal")).to eq("")
      end
    end
  end

  describe "#status_badge" do
    it "generates a span with status-badge class" do
      result = helper.status_badge(:pending)
      expect(result).to have_css("span.status-badge")
    end

    it "includes status-specific class by default" do
      result = helper.status_badge(:pending)
      expect(result).to include("status-badge--pending")
    end

    it "humanizes the status text" do
      result = helper.status_badge(:in_progress)
      expect(result).to include("In progress")
    end

    it "accepts custom class option" do
      result = helper.status_badge(:pending, class: "custom-class")
      expect(result).to have_css("span.custom-class")
    end
  end
end
