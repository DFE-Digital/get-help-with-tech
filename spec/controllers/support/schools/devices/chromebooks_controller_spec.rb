require 'rails_helper'

RSpec.describe Support::Schools::Devices::ChromebooksController do
  let(:school) { create(:school, :manages_orders) }

  describe '#edit' do
    it 'is successful for support users' do
      expect {
        get :edit, params: { school_urn: school.urn }
      }.to receive_status_ok_for(create(:support_user))
    end

    it 'is successful for computacenter users' do
      expect {
        get :edit, params: { school_urn: school.urn }
      }.to receive_status_ok_for(create(:computacenter_user))
    end
  end

  describe '#update' do
    it 'is successful for support users' do
      sign_in_as create(:support_user)

      patch :update, params: {
        school_urn: school.urn,
        chromebook_information_form: {
          will_need_chromebooks: 'no',
        },
      }

      expect(response).to redirect_to(support_school_path(school))
    end

    it 'is successful for computacenter users' do
      sign_in_as create(:computacenter_user)

      patch :update, params: {
        school_urn: school.urn,
        chromebook_information_form: {
          will_need_chromebooks: 'no',
        },
      }

      expect(response).to redirect_to(support_school_path(school))
    end
  end
end
