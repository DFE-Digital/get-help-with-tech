require 'rails_helper'

RSpec.describe Support::Gias::HomeController, type: :controller do
  let(:non_support_third_line_user) { create(:user, is_support: true, role: 'no') }
  let(:support_third_line_user) { create(:support_user, :third_line) }

  describe '#index' do
    context 'non support third line users' do
      before { sign_in_as non_support_third_line_user }

      specify { expect { get :index }.to be_forbidden_for(non_support_third_line_user) }
    end

    context 'support third line users' do
      let!(:staged_school_not_to_be_added) { create(:staged_school) }
      let!(:staged_school_to_be_closed) { create(:staged_school, :closed) }

      before do
        create(:staged_school)
        create(:school, urn: staged_school_not_to_be_added.urn)
        create(:school, urn: staged_school_to_be_closed.urn)
        create(:staged_school, :closed)
        sign_in_as support_third_line_user
        get :index
      end

      specify { expect(response).to be_successful }

      it 'shows the count of available schools to be added' do
        expect(assigns(:new_schools_count)).to eq(1)
      end

      it 'shows the count of available schools to be closed' do
        expect(assigns(:closed_schools_count)).to eq(1)
      end
    end
  end
end
