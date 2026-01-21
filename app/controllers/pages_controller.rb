# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @featured_works = Work.published.featured.ordered.limit(6)
    @recent_works = Work.published.recent.limit(4)

    set_meta_tags(
      title: "Stained Glass Repair & Custom Art - Nashville, TN",
      description: "Expert stained glass repair and restoration in Nashville, TN. Custom commissions, church window restoration, and handcrafted art serving Middle Tennessee."
    )
  end

  def about
    set_meta_tags(
      title: "About",
      description: "Learn about Coco's Stained Glass in Nashville, TN - the artistry, process, and passion behind each handcrafted piece serving Middle Tennessee."
    )
  end
end
