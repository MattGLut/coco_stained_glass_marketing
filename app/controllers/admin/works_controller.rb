# frozen_string_literal: true

module Admin
  class WorksController < BaseController
    before_action :set_work, only: [:show, :edit, :update, :destroy, :publish, :unpublish, :feature, :unfeature, :remove_image]

    def index
      @works = policy_scope(Work).includes(:categories).ordered

      if params[:status] == "published"
        @works = @works.published
      elsif params[:status] == "draft"
        @works = @works.draft
      end

      set_meta_tags(title: "Manage Works")
    end

    def show
      authorize @work
      set_meta_tags(title: @work.title)
    end

    def new
      @work = Work.new
      authorize @work
      @categories = Category.ordered

      set_meta_tags(title: "New Work")
    end

    def create
      @work = Work.new(work_params)
      authorize @work
      @categories = Category.ordered

      if @work.save
        redirect_to admin_work_path(@work), notice: "Work was successfully created.", status: :see_other
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @work
      @categories = Category.ordered

      set_meta_tags(title: "Edit: #{@work.title}")
    end

    def update
      authorize @work
      @categories = Category.ordered

      # Handle images separately to append rather than replace
      new_images = params[:work]&.delete(:images)

      if @work.update(work_params)
        @work.images.attach(new_images) if new_images.present?
        redirect_to admin_work_path(@work), notice: "Work was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @work
      @work.destroy
      redirect_to admin_works_path, notice: "Work was successfully deleted.", status: :see_other
    end

    def publish
      authorize @work
      @work.update(published: true)
      redirect_to admin_work_path(@work), notice: "Work has been published.", status: :see_other
    end

    def unpublish
      authorize @work
      @work.update(published: false)
      redirect_to admin_work_path(@work), notice: "Work has been unpublished.", status: :see_other
    end

    def feature
      authorize @work
      @work.update(featured: true)
      redirect_to admin_work_path(@work), notice: "Work has been featured.", status: :see_other
    end

    def unfeature
      authorize @work
      @work.update(featured: false)
      redirect_to admin_work_path(@work), notice: "Work has been unfeatured.", status: :see_other
    end

    def remove_image
      authorize @work
      image = @work.images.find(params[:image_id])
      image.purge
      redirect_to edit_admin_work_path(@work), notice: "Image removed.", status: :see_other
    end

    def update_positions
      authorize Work, :update_positions?
      params[:work_ids].each_with_index do |id, index|
        Work.where(id: id).update_all(position: index)
      end
      head :ok
    end

    private

    def set_work
      @work = Work.friendly.find(params[:id])
    end

    def work_params
      params.require(:work).permit(
        :title, :description, :dimensions, :medium, :year_created,
        :featured, :published, :position,
        images: [],
        category_ids: []
      )
    end
  end
end
