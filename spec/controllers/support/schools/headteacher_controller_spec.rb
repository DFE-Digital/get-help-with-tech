require 'rails_helper'

RSpec.describe Support::Schools::HeadteacherController, type: :controller do
  let(:non_support_third_line_user) { create(:user, is_support: true, role: 'no') }
  let(:support_third_line_user) { create(:support_user, :third_line) }
  let!(:school) { create(:school) }

  describe '#edit' do
    context 'non support third line users' do
      before { sign_in_as non_support_third_line_user }

      specify do
        expect { get :edit, params: { school_urn: school.urn } }.to be_forbidden_for(non_support_third_line_user)
      end
    end

    context 'support third line users' do
      before do
        sign_in_as support_third_line_user
      end

      context 'when the school has no contacts at all' do
        before { get :edit, params: { school_urn: school.urn } }

        specify { expect(response).to be_successful }

        it 'exposes a blank form to create the headteacher contact of the school' do
          expect(assigns(:form)).to be_a(Support::School::ChangeHeadteacherForm)
          expect(assigns(:form).school).to eq(school)
          expect(assigns(:form).email_address).to be_nil
          expect(assigns(:form).full_name).to be_nil
          expect(assigns(:form).id).to be_nil
          expect(assigns(:form).phone_number).to be_nil
          expect(assigns(:form).role).to be_nil
          expect(assigns(:form).title).to be_nil
        end
      end

      context 'when the school has a non-headteacher contact' do
        let!(:contact) { create(:school_contact, :contact, school: school) }

        before { get :edit, params: { school_urn: school.urn } }

        specify { expect(response).to be_successful }

        it 'exposes a form initialized to set the contact as the headteacher of the school' do
          expect(assigns(:form).school).to eq(school)
          expect(assigns(:form).email_address).to eq(contact.email_address)
          expect(assigns(:form).full_name).to eq(contact.full_name)
          expect(assigns(:form).id).to eq(contact.id)
          expect(assigns(:form).phone_number).to eq(contact.phone_number)
          expect(assigns(:form).role).to eq(contact.role)
          expect(assigns(:form).title).to eq(contact.title)
        end
      end

      context 'when the school has a headteacher contact' do
        let!(:headteacher) { create(:school_contact, :headteacher, school: school) }

        before { get :edit, params: { school_urn: school.urn } }

        specify { expect(response).to be_successful }

        it 'exposes a form initialized to update the details of the headteacher of the school' do
          expect(assigns(:form).school).to eq(school)
          expect(assigns(:form).email_address).to eq(headteacher.email_address)
          expect(assigns(:form).full_name).to eq(headteacher.full_name)
          expect(assigns(:form).id).to eq(headteacher.id)
          expect(assigns(:form).phone_number).to eq(headteacher.phone_number)
          expect(assigns(:form).role).to eq(headteacher.role)
          expect(assigns(:form).title).to eq(headteacher.title)
        end
      end
    end
  end

  describe '#update' do
    let(:full_name) { Faker::Name.unique.name }
    let(:email_address) { Faker::Internet.unique.email }
    let(:id) { Faker::Number.unique.between(from: 1000, to: 100_000) }
    let(:phone_number) { Faker::PhoneNumber.phone_number }
    let(:title) { Faker::Lorem.sentence }
    let(:params) do
      {
        school_urn: school.urn,
        support_school_change_headteacher_form: {
          email_address: email_address,
          full_name: full_name,
          id: id,
          phone_number: phone_number,
          title: title,
        },
      }
    end

    context 'non support third line users' do
      before { sign_in_as non_support_third_line_user }

      specify do
        expect { patch :update, params: params }.to be_forbidden_for(non_support_third_line_user)
      end
    end

    context 'support third line users' do
      before do
        sign_in_as support_third_line_user
        patch :update, params: params
      end

      context 'when the headteacher can be updated' do
        it 'redirects back to school' do
          expect(response).to redirect_to(support_school_path(school))
        end

        it 'shows a successful change message to the user' do
          expect(flash[:success]).to eq("#{school.name}'s headteacher details updated")
        end
      end

      context 'when the headteacher cannot be updated for some reason' do
        let(:email_address) {}

        it 'display again the form with some errors' do
          expect(assigns(:form).errors).not_to be_empty
        end
      end
    end
  end
end
