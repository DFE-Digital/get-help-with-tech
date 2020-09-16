require 'rails_helper'

RSpec.feature 'Enabling orders for a school from the support area' do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school, order_state: :cannot_order) }
  let(:school_details_page) { PageObjects::Support::Devices::SchoolDetailsPage.new }

  before do
    create(:school_device_allocation, :with_std_allocation, allocation: 50, school: school)
    sign_in_as support_user
  end

  describe 'visiting a school details page' do
    before do
      visit support_devices_school_path(school.urn)
    end

    it 'shows a link to Change whether they can order devices' do
      expect(school_details_page.school_details_rows[3]).to have_text 'Can place orders?'
      expect(school_details_page.school_details_rows[3]).to have_link 'Change'
    end

    describe 'clicking Change' do
      before do
        click_on 'Change'
      end

      it 'shows the order status form' do
        expect(page).to have_text('Can they place orders?')
        expect(page).to have_field('No, orders cannot be placed yet')
        expect(page).to have_field('They can place orders for specific circumstances')
        expect(page).to have_field('They can order their full allocation because local coronavirus restrictions are confirmed')

        # the 'no' option should be chosen
        expect(find('#support-enable-orders-form-order-state-cannot-order-field')['checked']).to eq('checked')
      end

      context 'selecting They can place orders for specific circumstances' do
        before do
          choose 'They can place orders for specific circumstances'
        end

        it 'asks how many devices they can order' do
          expect(page).to have_field('How many devices can they order?')
        end

        context 'filling in a valid number and clicking Continue' do
          let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest, payload_id: 'abc123') }

          before do
            allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
            allow(mock_request).to receive(:post!)
            fill_in('How many devices can they order?', with: 2)
          end

          it 'pings the Computacenter CapUpdate API' do
            click_on 'Continue'
            expect(mock_request).to have_received(:post!)
          end

          context 'when the Computacenter CapUpdate API processes the update successfully' do
            # This will be the next PR
            it 'takes me to the Check your answers page', pending: true do
              click_on 'Continue'
              expect(page).to have_text 'Check your answers and confirm'
              expect(page).to have_text 'Yes, for specific circumstances'
              expect(page).to have_text 'Up to 2 from an allocation of 50'
            end

            # Remove this once the example above is coded
            it 'shows me the school details page with updated details and a success message' do
              click_on 'Continue'
              expect(school_details_page).to have_text("We've saved your choices")
              expect(school_details_page.school_details_rows[3]).to have_text 'Can place orders?'
              expect(school_details_page.school_details_rows[3]).to have_text 'Yes, for specific circumstances'
            end
          end

          context 'when the Computacenter CapUpdate API raises an error' do
            before do
              allow(mock_request).to receive(:post!).and_raise(Computacenter::OutgoingAPI::Error.new(cap_update_request: mock_request))
            end

            it 'shows an error' do
              click_on 'Continue'
              expect(page).to have_text('Could not update the cap on Computacenter\'s system - payload_id: abc123')
            end

            it 'shows the order status form' do
              click_on 'Continue'
              expect(page).to have_text('Can they place orders?')
              expect(page).to have_field('No, orders cannot be placed yet')
              expect(page).to have_field('They can place orders for specific circumstances')
              expect(page).to have_field('They can order their full allocation because local coronavirus restrictions are confirmed')
            end
          end
        end
      end
    end
  end
end
