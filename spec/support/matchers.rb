Dir[Rails.root.join('spec/support/matchers/*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.include Support::Matchers, type: :feature
end
