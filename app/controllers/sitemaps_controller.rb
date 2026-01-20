# frozen_string_literal: true

class SitemapsController < ApplicationController
  def index
    @works = Work.published.includes(:categories)
    @categories = Category.with_published_works

    respond_to do |format|
      format.xml
    end
  end

  private

  def skip_pundit?
    true
  end
end
