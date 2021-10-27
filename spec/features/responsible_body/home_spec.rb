require 'rails_helper'

RSpec.feature ResponsibleBody do
  let(:sign_in_page) { PageObjects::SignInPage.new }
  let(:responsible_body_home_page) { PageObjects::ResponsibleBody::HomePage.new }

  let(:responsible_body) { create(:local_authority) }
  let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body) }
  let(:mno_user) { create(:mno_user) }

  context 'not signed-in' do
    scenario 'visiting the page redirects to sign-in' do
      visit responsible_body_home_path

      expect(sign_in_page).to be_displayed
    end
  end

  context 'signed in as non-RB user' do
    before do
      sign_in_as mno_user
    end

    scenario 'visiting the page shows a :forbidden error' do
      visit responsible_body_home_path

      expect(page).to have_content('You’re not allowed to do that')
      expect(page).to have_http_status(:forbidden)
    end
  end

  context 'visiting the RB home page signed in as an RB user' do
    describe 'top of the page' do
      before do
        sign_in_as rb_user
        visit responsible_body_home_path
      end

      it 'displays the school name' do
        expect(page).to have_content(responsible_body.name)
      end

      it 'displays your account title' do
        expect(page).to have_content('Your account')
      end

      it 'displays the tranche allocation' do
        expect(page).to have_css('#tranche_allocation')
      end
    end

    describe 'access support portal section' do
      before { sign_in_as rb_user }

      specify { expect(page).to have_link('Manage your schools and users') }
    end

    describe 'reset devices section' do
      context 'has NOT ordered anything' do
        before { sign_in_as rb_user }

        it 'does not show this section' do
          expect(page).not_to have_content('Reset devices')
        end
      end

      context 'has ordered' do
        let(:school) { create(:school, laptops: [2, 2, 1], responsible_body: responsible_body) }

        before do
          school.reload

          sign_in_as rb_user
        end

        it 'shows title' do
          expect(page).to have_content('Reset')
        end

        it 'shows the link to view device details' do
          expect(page).to have_link('view your device details and BIOS/admin passwords')
        end

        it 'shows the link to Huawei router password' do
          expect(page).to have_link('See your Huawei router password')
        end
      end
    end

    describe 'order history' do
      context 'has NOT ordered anything' do
        before { sign_in_as rb_user }

        it 'does not show the order history section' do
          expect(page).not_to have_content('Order history')
        end
      end

      context 'has ordered' do
        let(:school) { create(:school, laptops: [2, 2, 1], responsible_body: responsible_body) }

        before do
          school.reload

          sign_in_as rb_user
        end

        it 'shows the title' do
          expect(page).to have_content('Order history')
        end

        it 'shows link to view your schools and colleges' do
          expect(page).to have_link('View your schools and colleges')
        end

        context 'user can order devices' do
          let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body, orders_devices: true) }

          it 'shows the link to the TechSource order history' do
            expect(page).to have_link('See your order history on TechSource')
          end
        end

        context 'has NOT ordered routers' do
          it 'does NOT show the link to the extra mobile data requests page' do
            expect(page).not_to have_link('View your requests for extra mobile data')
          end
        end
      end
    end
  end

  context 'as a first-time RB user' do
    let(:rb_user) { create(:local_authority_user, privacy_notice_seen_at: nil) }

    it 'shows the privacy notice for the first time' do
      sign_in_as rb_user
      expect(page).to have_content('How we look after personal information as part of the Get help with technology programme')

      click_on 'Continue'
      expect(responsible_body_home_page).to be_displayed

      sign_out
      sign_in_as rb_user
      expect(responsible_body_home_page).to be_displayed
    end
  end
end
