# frozen_string_literal: true

module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [:show, :edit, :update, :destroy]

    def index
      @categories = Category.ordered.includes(:works)

      set_meta_tags(title: "Manage Categories")
    end

    def show
      @works = @category.works.ordered

      set_meta_tags(title: @category.name)
    end

    def new
      @category = Category.new

      set_meta_tags(title: "New Category")
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_categories_path, notice: "Category was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      set_meta_tags(title: "Edit: #{@category.name}")
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Category was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @category.destroy
      redirect_to admin_categories_path, notice: "Category was successfully deleted."
    end

    private

    def set_category
      @category = Category.friendly.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :description, :position)
    end
  end
end
