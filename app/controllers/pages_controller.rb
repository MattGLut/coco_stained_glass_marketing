# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @featured_works = Work.published.featured.ordered.limit(6)
    @recent_works = Work.published.recent.limit(4)

    set_meta_tags(
      title: "Handcrafted Stained Glass Art",
      description: "Discover the beauty of handcrafted stained glass in Nashville, TN. Custom commissions, windows, panels, and decorative art pieces serving Middle Tennessee."
    )
  end

  def about
    set_meta_tags(
      title: "About",
      description: "Learn about Coco's Stained Glass in Nashville, TN - the artistry, process, and passion behind each handcrafted piece serving Middle Tennessee."
    )
  end
end
