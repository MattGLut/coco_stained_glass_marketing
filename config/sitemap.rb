# frozen_string_literal: true

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = ENV.fetch("APP_HOST", "https://stainedglass.com")

# Configure S3 adapter for production
if Rails.env.production? && ENV["AWS_ACCESS_KEY_ID"].present?
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
    ENV.fetch("AWS_BUCKET"),
    aws_access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
    aws_region: ENV.fetch("AWS_REGION", "us-east-1")
  )
  SitemapGenerator::Sitemap.sitemaps_host = "https://#{ENV.fetch('AWS_BUCKET')}.s3.amazonaws.com/"
  SitemapGenerator::Sitemap.public_path = "tmp/"
  SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"
end

SitemapGenerator::Sitemap.create do
  # Add static pages
  add root_path, changefreq: "weekly", priority: 1.0
  add about_path, changefreq: "monthly", priority: 0.7
  add contact_path, changefreq: "monthly", priority: 0.8
  add works_path, changefreq: "weekly", priority: 0.9

  # Add all published works
  Work.published.find_each do |work|
    add work_path(work),
        lastmod: work.updated_at,
        changefreq: "monthly",
        priority: 0.8,
        images: work.images.map { |img|
          {
            loc: Rails.application.routes.url_helpers.rails_blob_url(img, host: SitemapGenerator::Sitemap.default_host),
            title: work.title
          }
        }
  end

  # Add categories with published works
  Category.with_published_works.find_each do |category|
    add works_path(category: category.id),
        lastmod: category.updated_at,
        changefreq: "weekly",
        priority: 0.6
  end
end
