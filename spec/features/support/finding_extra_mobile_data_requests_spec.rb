require 'rails_helper'

RSpec.describe 'Finding ExtraMobileDataRequests in support' do
  let(:support_user) { create(:support_user) }
  let(:computacenter_user) { create(:computacenter_user) }
  let(:index_page) { PageObjects::Support::ExtraMobileDataRequests::IndexPage.new }

  context 'as a support_user' do
    before do
      sign_in_as support_user
    end

    context 'when I visit support home' do
      before do
        visit support_home_path
      end

      it 'shows me a link for Extra mobile data requests' do
        expect(page).to have_link 'Find requests for extra mobile data'
      end

      context 'clicking on the link' do
        before do
          click_on 'Find requests for extra mobile data'
        end

        it 'shows me the requests list' do
          expect(index_page).to be_displayed
        end
      end
    end
  end
end
