require 'rails_helper'

RSpec.feature 'Enabling orders for a school from the support area' do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school) }
  let(:school_details_page) { PageObjects::Support::Devices::SchoolDetailsPage.new }
  let(:enable_orders_confirm_page) { PageObjects::Support::Devices::EnableOrdersConfirmPage.new }

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

          it 'takes me to the Check your answers page' do
            click_on 'Continue'
            expect(enable_orders_confirm_page).to be_displayed
            expect(enable_orders_confirm_page).to have_text 'Check your answers and confirm'
            expect(enable_orders_confirm_page.can_order_devices_row).to have_text 'They can place orders for specific circumstances'
            expect(enable_orders_confirm_page.how_many_devices_row).to have_text 'Up to 2 from an allocation of 50'
          end

          it 'shows links to change the order status and how many devices' do
            click_on 'Continue'
            expect(enable_orders_confirm_page.can_order_devices_row).to have_link 'Change'
            expect(enable_orders_confirm_page.how_many_devices_row).to have_link 'Change'
          end

          context 'clicking Change' do
            before do
              click_on 'Continue'
              within(enable_orders_confirm_page.can_order_devices_row) do
                click_on 'Change'
              end
            end

            it 'shows the order status form with my previously entered values preserved' do
              expect(page).to have_text('Can they place orders?')
              expect(page.find_field('support-enable-orders-form-order-state-can-order-for-specific-circumstances-field')).to be_checked
              expect(page).to have_field('How many devices can they order?', with: 2)
            end
          end

          context 'clicking Confirm' do
            it 'pings the Computacenter CapUpdate API' do
              click_on 'Continue'
              click_on 'Confirm'
              expect(mock_request).to have_received(:post!)
            end

            context 'when the Computacenter CapUpdate API processes the update successfully' do
              it 'shows me the school details page with updated details and a success message' do
                click_on 'Continue'
                click_on 'Confirm'
                expect(school_details_page).to have_text("We've saved your choices")
                expect(school_details_page.school_details_rows[3]).to have_text 'Can place orders?'
                expect(school_details_page.school_details_rows[3]).to have_text 'Yes, for specific circumstances'
              end
            end

            context 'when the Computacenter CapUpdate API raises an error' do
              before do
                allow(mock_request).to receive(:post!).and_raise(Computacenter::OutgoingAPI::Error.new(cap_update_request: mock_request))
                click_on 'Continue'
                click_on 'Confirm'
              end

              it 'shows an error' do
                expect(page).to have_text('Could not update the cap on Computacenter\'s system - payload_id: abc123')
              end

              it 'shows the order status form' do
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
end
