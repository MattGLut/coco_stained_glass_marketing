# frozen_string_literal: true

module ApplicationHelper
  def set_meta_tags(options = {})
    @page_title = options[:title]
    @page_description = options[:description]
    @page_image = options[:image]
    @page_keywords = options[:keywords]
  end

  # Format currency
  def format_price(amount)
    return "—" if amount.blank?
    number_to_currency(amount)
  end

  # Format date nicely
  def format_date(date, format = :long)
    return "—" if date.blank?
    
    case format
    when :short
      date.strftime("%b %d, %Y")
    when :long
      date.strftime("%B %d, %Y")
    when :relative
      time_ago_in_words(date) + " ago"
    else
      date.strftime(format)
    end
  end

  # Active link helper
  def active_link_class(path, exact: false)
    if exact
      current_page?(path) ? "active" : ""
    else
      request.path.start_with?(path) ? "active" : ""
    end
  end

  # Status badge helper
  def status_badge(status, options = {})
    css_class = options[:class] || "status-badge--#{status.to_s.parameterize}"
    content_tag(:span, status.to_s.humanize, class: "status-badge #{css_class}")
  end
end
