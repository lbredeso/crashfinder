# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

if Rails.env.production? && ENV['SECRET_TOKEN'].blank?
  raise 'SECRET_TOKEN environment variable must be set!'
end

Crashfinder::Application.config.secret_token = ENV['SECRET_TOKEN'] || '140f3ab8222d4c3f2aebb9772c91dbe1b3a33e4ab919b602e02d8e70d9741e02f78a2e3cb47b21535dae9a98278d7650e135b50f6424bbb27c714c9d8ffda2ba'