if redis_url = ENV['REDISCLOUD_URL']
  Sidekiq.configure_server do |config|
    config.redis = {url: redis_url, namespace: 'sidekiq'}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: redis_url, namespace: 'sidekiq'}
  end
end
