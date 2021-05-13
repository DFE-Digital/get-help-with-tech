require 'view_component/test_helpers'
require 'capybara/rspec'

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component

  config.define_derived_metadata(file_path: Regexp.new('spec/components/')) do |metadata|
    metadata[:type] = :component
  end
end
