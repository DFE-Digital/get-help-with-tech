require 'rails_helper'

RSpec.describe 'layouts/multipage_guide.html.erb' do
  before do
    controller.singleton_class.class_eval do
      def hide_nav_menu?
        false
      end
      helper_method :hide_nav_menu?
    end
  end

  context 'when page has noindex set to true' do
    it 'has meta tag noindex' do
      assign(:page, OpenStruct.new(page_id: 'google_domain_for_care_leavers_and_children_with_social_worker', noindex: true))
      render
      expect(rendered).to include('noindex')
    end
  end

  context 'when page has noindex not set' do
    it 'has meta tag noindex' do
      assign(:page, OpenStruct.new(page_id: 'google_domain_for_care_leavers_and_children_with_social_worker'))
      render
      expect(rendered).not_to include('noindex')
    end
  end
end
