# frozen_string_literal: true

# Meta-Tags configuration for SEO
MetaTags.configure do |config|
  # How many characters to truncate title and description to
  config.title_limit = 70
  config.description_limit = 160
  config.keywords_limit = 255

  # Separator between title segments
  config.keywords_separator = ", "
end
