# frozen_string_literal: true

class WorksController < ApplicationController
  def index
    @categories = Category.with_published_works.ordered

    works = policy_scope(Work).includes(:categories).ordered
    works = works.in_category(params[:category]) if params[:category].present?

    @pagy, @works = pagy(works, items: 12)

    set_meta_tags(
      title: "Gallery",
      description: "Browse our collection of handcrafted stained glass art in Nashville, TN. Windows, panels, lamps, and custom pieces serving Middle Tennessee."
    )
  end

  def show
    @work = policy_scope(Work).friendly.find(params[:id])
    authorize @work

    @related_works = policy_scope(Work)
                         .where.not(id: @work.id)
                         .joins(:categories)
                         .where(categories: { id: @work.category_ids })
                         .distinct
                         .limit(4)

    set_meta_tags(
      title: @work.full_title,
      description: @work.meta_description,
      og: {
        title: @work.full_title,
        description: @work.meta_description,
        image: @work.primary_image.present? ? url_for(@work.primary_image.variant(:large)) : nil
      }
    )

    # Structured data for artwork
    @artwork_json_ld = {
      "@context": "https://schema.org",
      "@type": "VisualArtwork",
      "name": @work.title,
      "description": @work.description,
      "artform": "Stained Glass",
      "artMedium": @work.medium,
      "dateCreated": @work.year_created,
      "creator": {
        "@type": "Person",
        "name": "Coco"
      }
    }
  end
end
