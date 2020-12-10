require 'rails_helper'

RSpec.describe 'support/responsible_bodies/show.html.erb' do
  let(:responsible_body) { create(:trust) }
  let(:schools) { [] }

  before do
    controller.singleton_class.class_eval do
      protected
        def policy(klass)
          OpenStruct.new(:new? => true, :edit? => true)
        end
        helper_method :policy
    end

    assign(:responsible_body, responsible_body)
    assign(:schools, schools)
  end

  describe 'banners' do
    context 'when feature flags disabled' do
      it 'shows banners' do
        render
        expect(rendered).not_to include('No orders over Christmas')
        expect(rendered).not_to include('We’ve restored original device allocations')
      end
    end

    context 'when feature flags enabled', with_feature_flags: { christmas_banner: 'active', increased_allocations_banner: 'active' } do
      it 'shows banners' do
        render
        expect(rendered).to include('No orders over Christmas')
        expect(rendered).to include('We’ve restored original device allocations')
      end
    end
  end
end
