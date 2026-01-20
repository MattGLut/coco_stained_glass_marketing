# frozen_string_literal: true

module Admin
  class WorksController < BaseController
    before_action :set_work, only: [:show, :edit, :update, :destroy, :publish, :unpublish, :feature, :unfeature, :remove_image]

    def index
      @works = Work.includes(:categories).ordered

      if params[:status] == "published"
        @works = @works.published
      elsif params[:status] == "draft"
        @works = @works.draft
      end

      set_meta_tags(title: "Manage Works")
    end

    def show
      set_meta_tags(title: @work.title)
    end

    def new
      @work = Work.new
      @categories = Category.ordered

      set_meta_tags(title: "New Work")
    end

    def create
      @work = Work.new(work_params)
      @categories = Category.ordered

      if @work.save
        redirect_to admin_work_path(@work), notice: "Work was successfully created.", status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @categories = Category.ordered

      set_meta_tags(title: "Edit: #{@work.title}")
    end

    def update
      @categories = Category.ordered

      if @work.update(work_params)
        redirect_to admin_work_path(@work), notice: "Work was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @work.destroy
      redirect_to admin_works_path, notice: "Work was successfully deleted.", status: :see_other
    end

    def publish
      @work.update(published: true)
      redirect_to admin_work_path(@work), notice: "Work has been published.", status: :see_other
    end

    def unpublish
      @work.update(published: false)
      redirect_to admin_work_path(@work), notice: "Work has been unpublished.", status: :see_other
    end

    def feature
      @work.update(featured: true)
      redirect_to admin_work_path(@work), notice: "Work has been featured.", status: :see_other
    end

    def unfeature
      @work.update(featured: false)
      redirect_to admin_work_path(@work), notice: "Work has been unfeatured.", status: :see_other
    end

    def remove_image
      image = @work.images.find(params[:image_id])
      image.purge
      redirect_to edit_admin_work_path(@work), notice: "Image removed.", status: :see_other
    end

    def update_positions
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
