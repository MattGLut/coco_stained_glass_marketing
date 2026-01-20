# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Visitor browsing", type: :system do
  before do
    driven_by :rack_test
  end

  describe "homepage" do
    it "displays the site header" do
      visit root_path
      expect(page).to have_content("Coco's Stained Glass")
    end

    it "has navigation links" do
      visit root_path
      expect(page).to have_link("Gallery")
      expect(page).to have_link("About")
      expect(page).to have_link("Contact")
    end

    context "with featured works" do
      let!(:featured_work) { create(:work, :featured, published: true, title: "Amazing Piece") }

      it "displays featured works section" do
        visit root_path
        expect(page).to have_content("Featured Works")
        expect(page).to have_content("Amazing Piece")
      end
    end
  end

  describe "gallery" do
    let!(:published_work) { create(:work, published: true, title: "Gallery Item") }
    let!(:draft_work) { create(:work, published: false, title: "Hidden Item") }

    it "displays published works" do
      visit works_path
      expect(page).to have_content("Gallery Item")
      expect(page).not_to have_content("Hidden Item")
    end

    it "allows clicking into work details" do
      visit works_path
      click_link "Gallery Item"
      expect(page).to have_current_path(work_path(published_work))
    end

    context "with categories" do
      let(:category) { create(:category, name: "Windows") }
      let!(:categorized_work) { create(:work, published: true, title: "Window Art", categories: [category]) }

      it "displays category filters" do
        visit works_path
        expect(page).to have_link("Windows")
      end

      it "filters works by category" do
        visit works_path(category: category.id)
        expect(page).to have_content("Window Art")
      end
    end
  end

  describe "contact form" do
    it "displays the contact form" do
      visit contact_path
      expect(page).to have_field("Name")
      expect(page).to have_field("Email")
      expect(page).to have_field("Message")
    end

    it "submits successfully with valid data" do
      visit contact_path
      fill_in "Name", with: "Test User"
      fill_in "Email", with: "test@example.com"
      fill_in "Message", with: "This is a test message for the contact form."
      click_button "Send Message"

      expect(page).to have_content("Thank you")
    end

    it "shows errors with invalid data" do
      visit contact_path
      click_button "Send Message"

      expect(page).to have_content("error")
    end
  end

  describe "authentication" do
    it "shows sign in link" do
      visit root_path
      expect(page).to have_link("Client Login")
    end

    describe "signing in" do
      let!(:user) { create(:user, :customer, email: "test@example.com", password: "password123") }

      it "allows users to sign in" do
        visit new_user_session_path
        fill_in "Email", with: "test@example.com"
        fill_in "Password", with: "password123"
        click_button "Sign In"

        expect(page).to have_content("My Projects")
      end
    end
  end
end
