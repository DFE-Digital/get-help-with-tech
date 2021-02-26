require 'rails_helper'

RSpec.describe 'layouts/multipage_guide.html.erb' do
  context 'when page has noindex set to true' do
    it 'has meta tag noindex' do
      assign(:page, OpenStruct.new(page_id: 'google_domain_for_care_leavers_and_children_with_social_worker', noindex: true))
      stub_template 'layouts/application.html.erb' => '<%= yield(:head) %>'
      render
      expect(rendered).to include('noindex')
    end
  end

  context 'when page has noindex not set' do
    it 'has meta tag noindex' do
      assign(:page, OpenStruct.new(page_id: 'google_domain_for_care_leavers_and_children_with_social_worker'))
      stub_template 'layouts/application.html.erb' => '<%= yield(:head) %>'
      render
      expect(rendered).not_to include('noindex')
    end
  end
end
