# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "add site url"
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(
  fog_provider: 'AWS',
  aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  fog_directory: ENV['S3_PUBLIC_BUCKET_NAME'],
  fog_region: ENV['S3_REGION'])
SitemapGenerator::Sitemap.sitemaps_host = ENV['SITEMAP_HOST']

SitemapGenerator::Sitemap.create do
end
