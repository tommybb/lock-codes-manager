source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'coffee-rails', '~> 4.2'
gem 'delayed_job_active_record', '~> 4.1.3'
gem 'devise', '~> 4.5.0'
gem 'httparty', '~> 0.16.2'
gem 'jbuilder', '~> 2.5'
gem 'phony_rails', '~> 0.14.7'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.6'
gem 'ransack', '~> 1.8.8'
gem 'rspec-tapas'
gem 'sass-rails', '~> 5.0'
gem 'sqlite3'
gem 'turbolinks', '~> 5'
gem 'twilio-ruby', '~> 5.12.4'
gem 'uglifier', '>= 1.3.0'
gem 'webmock', '~> 3.4.2'

group :development, :test do
  gem 'capybara', '~> 3.6.0'
  gem 'dotenv-rails'
  gem 'factory_bot_rails', '~> 4.11.0'
  gem 'faker', :git => 'https://github.com/stympy/faker.git', :branch => 'master'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.7'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop', '~> 0.59.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end
