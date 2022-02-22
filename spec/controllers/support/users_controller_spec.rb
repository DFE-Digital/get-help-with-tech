require 'rails_helper'

RSpec.describe Support::UsersController do
  let(:support_user) { create(:support_user, full_name: 'Jenny Jones') }
  let(:user_who_has_seen_privacy_notice) do
    create(:school_user,
           :has_seen_privacy_notice,
           email_address: 'privacy_note_seen@example.com',
           full_name: 'Jane Smith')
  end
  let(:user_who_has_not_seen_privacy_notice) do
    create(:school_user,
           :has_not_seen_privacy_notice,
           email_address: 'privacy_note_not_seen@example.com',
           full_name: 'John Smith')
  end
  let(:user_who_is_deleted) do
    create(:school_user,
           :has_seen_privacy_notice,
           :deleted,
           email_address: 'deleted@example.com',
           full_name: 'July Smith')
  end
  let(:existing_user) { create(:local_authority_user, responsible_body:) }
  let(:responsible_body) { create(:local_authority) }
  let(:school) { create(:school) }

  describe '#new' do
    context 'when inviting to a responsible body' do
      it 'is successful for support users' do
        expect {
          get :new, params: { responsible_body_id: responsible_body.id }
        }.to receive_status_ok_for(support_user)
      end

      it 'is forbidden for computacenter users' do
        expect {
          get :new, params: { responsible_body_id: responsible_body.id }
        }.to be_forbidden_for(create(:computacenter_user))
      end
    end

    context 'when inviting to a school' do
      it 'is successful for support users' do
        sign_in_as support_user
        get :new, params: { school_urn: school.urn }
        expect(response).to be_successful
      end

      it 'is forbidden for computacenter users' do
        expect {
          get :new, params: { school_urn: school.urn }
        }.to be_forbidden_for(create(:computacenter_user))
      end

      context 'when RB orders' do
        before do
          stub_computacenter_outgoing_api_calls
          SchoolSetWhoManagesOrdersService.new(school, :responsible_body).call
        end

        it 'does not allow school users to be added' do
          sign_in_as support_user
          get :new, params: { school_urn: school.urn }
          expect(response).not_to be_successful
        end
      end
    end
  end

  describe '#create' do
    before { stub_computacenter_outgoing_api_calls }

    context 'when inviting to a responsible body' do
      context 'for support users', versioning: true do
        before do
          sign_in_as support_user
        end

        def perform_create!
          post :create, params: { responsible_body_id: responsible_body.id,
                                  user: attributes_for(:user) }
        end

        it 'creates users' do
          expect { perform_create! }.to change(User, :count).by(1)
        end

        it 'sets orders_devices to true' do
          perform_create!

          user = User.last
          expect(user.orders_devices).to be_truthy
        end

        it 'does not set the school on the user' do
          perform_create!

          user = User.last
          expect(user.school).to be_blank
        end

        it 'audits changes with reference to user that requested the changes' do
          perform_create!

          expect(User.last.versions.last.whodunnit).to eql("User:#{support_user.id}")
        end
      end

      it 'is forbidden for MNO users' do
        expect {
          post :create, params: { responsible_body_id: responsible_body.id, user: { some: 'data' } }
        }.to be_forbidden_for(create(:mno_user))
      end

      it 'is forbidden for responsible body users' do
        expect {
          post :create, params: { responsible_body_id: responsible_body.id, user: { some: 'data' } }
        }.to be_forbidden_for(create(:trust_user))
      end

      it 'is forbidden for Computacenter users' do
        expect {
          post :create, params: { responsible_body_id: responsible_body.id, user: { some: 'data' } }
        }.to be_forbidden_for(create(:computacenter_user))
      end

      it 'redirects to / for unauthenticated users' do
        post :create, params: { responsible_body_id: responsible_body.id, user: { some: 'data' } }

        expect(response).to redirect_to(sign_in_path)
      end
    end

    context 'when inviting to a school' do
      context 'for a support user, with valid new user details' do
        before do
          sign_in_as support_user
        end

        def post!
          post :create, params: {
            school_urn: school.urn,
            user: {
              full_name: 'John Doe',
              email_address: 'john@example.com',
              orders_devices: '0',
            },
          }
        end

        it 'creates a new user' do
          expect { post! }.to change(User, :count).by(1)
        end

        it 'associates user and school' do
          post!

          expect(User.last.school).to eql(school)
        end

        it 'sets attributes correctly' do
          post!
          record = User.last
          expect(record.orders_devices).to be_falsey
        end

        it 'redirects to the user page' do
          post!
          expect(response).to redirect_to support_user_path(User.last)
        end

        it 'sends out an email', sidekiq: true do
          expect { post! }.to change {
            ActionMailer::Base.deliveries.size
          }.by(1)
        end
      end

      context 'for a support user, when there is an error' do
        before do
          sign_in_as support_user
        end

        def post!
          post :create, params: {
            school_urn: school.urn,
            user: {
              full_name: '',
              email_address: 'john@example.com',
              orders_devices: '0',
            },
          }
        end

        it 'does not create a user' do
          expect { post! }.not_to change(User, :count)
        end

        it 're-renders :new' do
          post!
          expect(response).to render_template(:new)
        end
      end

      it 'is forbidden for a computacenter user' do
        expect {
          post :create, params: {
            school_urn: school.urn,
            user: {
              full_name: 'John Doe',
              email_address: 'john@example.com',
              orders_devices: '0',
            },
          }
        }.to be_forbidden_for(create(:computacenter_user))
      end
    end
  end

  describe '#search' do
    it 'is successful for support users' do
      expect {
        get :search
      }.to receive_status_ok_for(support_user)
    end

    it 'is successful for computacenter users' do
      expect {
        get :search
      }.to receive_status_ok_for(create(:computacenter_user))
    end
  end

  describe '#results' do
    before do
      user_who_has_seen_privacy_notice
      user_who_has_not_seen_privacy_notice
      user_who_is_deleted
    end

    it 'returns all matching school and RB users for support users' do
      sign_in_as support_user
      post :results, params: { support_user_search_form: { email_address_or_full_name: 'Smith' } }

      expect(assigns[:results]).to contain_exactly(user_who_has_seen_privacy_notice, user_who_has_not_seen_privacy_notice)
    end

    it 'returns all matching school and RB users who have seen the privacy notice for Computacenter users' do
      sign_in_as create(:computacenter_user, full_name: 'Ralph Wort')
      post :results, params: { support_user_search_form: { email_address_or_full_name: 'Smith' } }

      expect(assigns[:results]).to contain_exactly(user_who_has_seen_privacy_notice)
    end
  end

  describe '#edit' do
    it 'is successful for support users' do
      expect {
        get :edit, params: { id: existing_user.id }
      }.to receive_status_ok_for(support_user)
    end

    it 'is forbidden for computacenter users' do
      expect {
        get :edit, params: { id: existing_user.id }
      }.to be_forbidden_for(create(:computacenter_user))
    end

    it 'does not edit deleted users' do
      sign_in_as support_user

      deleted_user = create(:school_user, :deleted)

      get :edit, params: { id: deleted_user }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe '#update' do
    it 'is successful for support users' do
      sign_in_as support_user

      put :update, params: {
        id: existing_user.id,
        user: {
          full_name: 'someone_else',
        },
      }

      expect(response).to redirect_to(support_user_path(existing_user))
    end

    it 'is forbidden for computacenter users' do
      expect {
        put :update, params: {
          id: existing_user.id,
          user: {
            full_name: 'someone_else',
          },
        }
      }.to be_forbidden_for(create(:computacenter_user))
    end
  end

  describe '#destroy' do
    let(:responsible_body) { create(:local_authority) }
    let(:school) { create(:school) }

    context 'for support users' do
      before do
        sign_in_as support_user
      end

      context 'with confirmed TechSource account' do
        let(:existing_user) { create(:local_authority_user, :with_a_confirmed_techsource_account, orders_devices: true) }

        it 'sets user deleted_at timestamp' do
          delete :destroy, params: { id: existing_user.id }
          expect(existing_user.reload.deleted_at).to be_present
        end

        it 'marks the user as being no longer able to order' do
          expect {
            delete :destroy, params: { id: existing_user.id }
          }.to change { existing_user.reload.orders_devices }.from(true).to(false)
        end

        it 'redirects back to the RB page when called from the responsible body area' do
          delete :destroy, params: { id: existing_user.id, user: { responsible_body_id: responsible_body.id } }
          expect(response).to redirect_to(support_responsible_body_path(responsible_body))
        end

        it 'redirects back to the school page when called from the school area' do
          delete :destroy, params: { id: existing_user.id, user: { school_urn: school.urn } }
          expect(response).to redirect_to(support_school_path(school))
        end
      end

      context 'WITHOUT a confirmed TechSource account' do
        let(:existing_user) { create(:local_authority_user, orders_devices: true) }

        it 'hard deletes the user completely' do
          delete :destroy, params: { id: existing_user.id }
          expect(User.find_by(id: existing_user.id)).to be_nil
        end

        it 'redirects back to the RB page when called from the responsible body area' do
          delete :destroy, params: { id: existing_user.id, user: { responsible_body_id: responsible_body.id } }
          expect(response).to redirect_to(support_responsible_body_path(responsible_body))
        end

        it 'redirects back to the school page when called from the school area' do
          delete :destroy, params: { id: existing_user.id, user: { school_urn: school.urn } }
          expect(response).to redirect_to(support_school_path(school))
        end
      end
    end

    context 'for computacenter users' do
      it 'is forbidden' do
        expect {
          delete :destroy, params: { id: existing_user.id }
        }.to be_forbidden_for(create(:computacenter_user))
      end
    end
  end
end
