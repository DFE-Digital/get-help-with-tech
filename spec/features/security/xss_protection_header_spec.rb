require 'rails_helper'

RSpec.describe 'X-XSS-Protection header' do
  it 'is set to 0' do
    visit '/'
    expect(response_headers['X-XSS-Protection']).to eql('0')
  end
end
