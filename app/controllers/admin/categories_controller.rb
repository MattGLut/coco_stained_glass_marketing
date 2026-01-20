# frozen_string_literal: true

module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [:show, :edit, :update, :destroy]

    def index
      @categories = policy_scope(Category).ordered.includes(:works)

      set_meta_tags(title: "Manage Categories")
    end

    def show
      authorize @category
      @works = @category.works.ordered

      set_meta_tags(title: @category.name)
    end

    def new
      @category = Category.new
      authorize @category

      set_meta_tags(title: "New Category")
    end

    def create
      @category = Category.new(category_params)
      authorize @category

      if @category.save
        redirect_to admin_categories_path, notice: "Category was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @category
      set_meta_tags(title: "Edit: #{@category.name}")
    end

    def update
      authorize @category
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Category was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @category
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
