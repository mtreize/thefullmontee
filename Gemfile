source 'https://rubygems.org'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
ruby '2.4.9'
gem 'rails', '~> 5.1.0.rc2'
gem 'seed_dump'
gem 'pg'
gem "nokogiri", ">= 1.10.4"

gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'
group :development, :test do
  gem 'sqlite3'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13.0'
  gem 'selenium-webdriver'
end
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem "devise", ">= 4.7.1"
gem 'devise-i18n'
gem 'haml-rails'
gem 'jquery-rails'
# gem 'therubyracer', :platform=>:ruby
gem 'mini_racer', platforms: :ruby

group :development do
  gem 'better_errors'
  gem 'html2haml'
  gem 'rails_layout'
end

gem "passenger"

gem "font-awesome-rails"
gem "bootstrap", ">= 4.3.1"
gem 'jquery-easing-rails'
gem 'chartjs-ror'
gem 'filesaverjs-rails'
gem 'slack-poster'

gem "handle_invalid_percent_encoding_requests"

gem "simple_calendar", "~> 2.0"
gem "actionview", ">= 5.1.6.2"
gem "rubyzip", ">= 1.3.0"
gem "yaml_db"
gem 'rails_serve_static_assets'
