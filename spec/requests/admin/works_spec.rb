# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Works", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }

  describe "authentication" do
    it "redirects to sign in when not authenticated" do
      get admin_works_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects customers to root with alert" do
      sign_in customer
      get admin_works_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end

  context "when signed in as admin" do
    before { sign_in admin }

    describe "GET /admin/works" do
      let!(:published_work) { create(:work, published: true, title: "Published Piece") }
      let!(:draft_work) { create(:work, published: false, title: "Draft Piece") }

      it "returns success" do
        get admin_works_path
        expect(response).to have_http_status(:success)
      end

      it "displays all works" do
        get admin_works_path
        expect(response.body).to include("Published Piece")
        expect(response.body).to include("Draft Piece")
      end

      it "filters by published status" do
        get admin_works_path(status: "published")
        expect(response.body).to include("Published Piece")
        expect(response.body).not_to include("Draft Piece")
      end

      it "filters by draft status" do
        get admin_works_path(status: "draft")
        expect(response.body).to include("Draft Piece")
        expect(response.body).not_to include("Published Piece")
      end
    end

    describe "GET /admin/works/:id" do
      let(:work) { create(:work, title: "Test Work") }

      it "returns success" do
        get admin_work_path(work)
        expect(response).to have_http_status(:success)
      end

      it "displays work details" do
        get admin_work_path(work)
        expect(response.body).to include("Test Work")
      end
    end

    describe "GET /admin/works/new" do
      it "returns success" do
        get new_admin_work_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/works" do
      let(:valid_params) do
        {
          work: {
            title: "New Stained Glass Piece",
            description: "A beautiful piece",
            dimensions: "24\" x 36\"",
            medium: "Stained glass, lead came",
            year_created: 2025
          }
        }
      end

      let(:invalid_params) do
        {
          work: {
            title: "",
            description: "Missing title"
          }
        }
      end

      context "with valid params" do
        it "creates a new work" do
          expect {
            post admin_works_path, params: valid_params
          }.to change(Work, :count).by(1)
        end

        it "redirects to the work page" do
          post admin_works_path, params: valid_params
          expect(response).to redirect_to(admin_work_path(Work.last))
        end
      end

      context "with invalid params" do
        it "does not create a work" do
          expect {
            post admin_works_path, params: invalid_params
          }.not_to change(Work, :count)
        end

        it "renders the form with errors" do
          post admin_works_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "GET /admin/works/:id/edit" do
      let(:work) { create(:work) }

      it "returns success" do
        get edit_admin_work_path(work)
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /admin/works/:id" do
      let(:work) { create(:work, title: "Original Title") }

      context "with valid params" do
        it "updates the work" do
          patch admin_work_path(work), params: { work: { title: "Updated Title" } }
          expect(work.reload.title).to eq("Updated Title")
        end

        it "redirects to the work page" do
          patch admin_work_path(work), params: { work: { title: "Updated Title" } }
          expect(response).to redirect_to(admin_work_path(work.reload))
        end
      end

      context "with invalid params" do
        it "renders the form with errors" do
          patch admin_work_path(work), params: { work: { title: "" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE /admin/works/:id" do
      let!(:work) { create(:work) }

      it "deletes the work" do
        expect {
          delete admin_work_path(work)
        }.to change(Work, :count).by(-1)
      end

      it "redirects to works index" do
        delete admin_work_path(work)
        expect(response).to redirect_to(admin_works_path)
      end
    end

    describe "PATCH /admin/works/:id/publish" do
      let(:work) { create(:work, published: false) }

      it "publishes the work" do
        patch publish_admin_work_path(work)
        expect(work.reload.published).to be true
      end

      it "redirects to the work page" do
        patch publish_admin_work_path(work)
        expect(response).to redirect_to(admin_work_path(work))
      end
    end

    describe "PATCH /admin/works/:id/unpublish" do
      let(:work) { create(:work, published: true) }

      it "unpublishes the work" do
        patch unpublish_admin_work_path(work)
        expect(work.reload.published).to be false
      end
    end

    describe "PATCH /admin/works/:id/feature" do
      let(:work) { create(:work, featured: false) }

      it "features the work" do
        patch feature_admin_work_path(work)
        expect(work.reload.featured).to be true
      end
    end

    describe "PATCH /admin/works/:id/unfeature" do
      let(:work) { create(:work, featured: true) }

      it "unfeatures the work" do
        patch unfeature_admin_work_path(work)
        expect(work.reload.featured).to be false
      end
    end

    describe "PATCH /admin/works/update_positions" do
      let!(:work1) { create(:work, position: 0) }
      let!(:work2) { create(:work, position: 1) }

      it "updates positions" do
        patch update_positions_admin_works_path, params: { work_ids: [work2.id, work1.id] }
        expect(work1.reload.position).to eq(1)
        expect(work2.reload.position).to eq(0)
      end

      it "returns ok status" do
        patch update_positions_admin_works_path, params: { work_ids: [work2.id, work1.id] }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
