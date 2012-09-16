source 'http://rubygems.org'
ruby "1.9.3", :engine => "jruby", :engine_version => "1.7.0.preview2"

gem 'rails', '~> 3.2.0'
  	
gem 'mongo_mapper', '0.11.0'
gem 'haml'
 	
# Gems used only for assets and not required	  	
# in production environments by default.	  	
group :assets do
  gem 'sass-rails', "  ~> 3.2.0"	  	
  gem 'coffee-rails', "~> 3.2.0" 	
  gem 'closure-compiler'
  gem 'jquery-rails'
  gem 'jquery-ui-rails'
end

gem 'pry'	  	
gem 'pry-rails'
gem 'twitter-bootstrap-rails', :github => 'seyhunak/twitter-bootstrap-rails'
gem 'haml-rails'
gem 'jruby-openssl'
gem 'trinidad'
# gem 'puma'
gem 'sorcery'

# Use unicorn as the web server  	
# gem 'unicorn'

# To use debugger	
#gem 'ruby-debug19', :require => 'ruby-debug'

group :test, :development do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end
