Rails.application.config.middleware.use OmniAuth::Builder do
  provider :browser_id
end

if Rails.env.production?
  OmniAuth.config.full_host = 'www.crashfinder.org'
end
