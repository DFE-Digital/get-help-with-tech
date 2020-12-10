require 'rails_helper'

RSpec.describe 'support/schools/show.html.erb' do
  let(:school) { create(:school, :with_std_device_allocation, increased_allocations_feature_flag: true) }

  before do
    create(:support_user)

    controller.singleton_class.class_eval do
    protected

      def policy(_klass)
        OpenStruct.new(new?: true, edit?: true)
      end
      helper_method :policy

      def current_user
        User.where(is_support: true).first!
      end
      helper_method :current_user
    end

    assign(:school, school)
  end

  describe 'banners' do
    context 'when feature flags disabled' do
      it 'shows banners' do
        render
        expect(rendered).not_to include('No orders over Christmas')
        expect(rendered).not_to include('Your allocation has increased to')
      end
    end

    context 'when feature flags enabled', with_feature_flags: { christmas_banner: 'active', increased_allocations_banner: 'active' } do
      it 'shows banners' do
        render
        expect(rendered).to include('No orders over Christmas')
        expect(rendered).to include("Your allocation has increased to #{school.std_device_allocation.allocation} devices")
      end
    end
  end
end
