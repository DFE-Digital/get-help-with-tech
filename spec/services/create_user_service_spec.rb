require 'rails_helper'

RSpec.describe CreateUserService do
  let(:last_email) { ActionMailer::Base.deliveries.last }

  describe 'invite_responsible_body_user' do
    let(:trust) { create(:trust) }

    context 'given valid new user params' do
      let(:valid_params) do
        {
          full_name: 'Vlad Valid',
          email_address: 'vlad@example.com',
          telephone: '01234 567890',
          responsible_body_id: trust.id,
        }
      end
      let(:result) { CreateUserService.invite_responsible_body_user(valid_params) }

      it 'creates a user with the given params' do
        expect { result }.to change(User, :count).by(1)
        expect(User.last).to have_attributes(valid_params)
      end

      it 'sends the correct email' do
        expect { perform_enqueued_jobs { result } }.to change(ActionMailer::Base.deliveries, :size).by(1)
        expect(last_email.to[0]).to eq(valid_params[:email_address])
        expect(last_email.header['template-id'].value).to eq(Settings.govuk_notify.templates.devices.invite_responsible_body_user)
      end

      it 'returns the user' do
        expect(result).to be_a(User)
        expect(result).to have_attributes(valid_params)
      end
    end

    context 'given invalid user params' do
      let(:invalid_params) do
        {
          full_name: '.',
          email_address: 'dunno',
          responsible_body_id: nil,
        }
      end
      let(:result) { CreateUserService.invite_responsible_body_user(invalid_params) }

      it 'does not create a user with the given params' do
        expect { result }.not_to change(User, :count)
      end

      it 'does not send any email' do
        expect { perform_enqueued_jobs { result } }.not_to change(ActionMailer::Base.deliveries, :size)
      end

      it 'returns the user unpersisted, with errors' do
        expect(result).to be_a(User)
        expect(result).to have_attributes(invalid_params)
        expect(result.errors.full_messages).not_to be_empty
      end
    end

    context 'given an email address that already exists' do
      let(:valid_params) do
        {
          full_name: 'Vlad Valid',
          email_address: 'existing@user.com',
          telephone: '01234 567890',
          responsible_body_id: trust.id,
        }
      end
      let(:result) { CreateUserService.invite_responsible_body_user(valid_params) }

      context 'on a school' do
        let!(:other_school) { create(:school) }
        let!(:existing_user) { create(:school_user, email_address: 'existing@user.com', school: other_school) }

        it 'returns the existing user' do
          expect(result).to be_a(User)
          expect(result).to eq(existing_user)
        end

        it 'adds this responsible_body to the existing user' do
          expect(result.responsible_body).to eq(trust)
        end

        it 'sends the correct email' do
          expect { perform_enqueued_jobs { result } }.to change(ActionMailer::Base.deliveries, :size).by(1)
          expect(last_email.to[0]).to eq(valid_params[:email_address])
          expect(last_email.header['template-id'].value).to eq(Settings.govuk_notify.templates.devices.invite_existing_user_to_responsible_body)
        end
      end

      context 'on a school and is a soft deleted user' do
        let!(:other_school) { create(:school) }

        before { create(:school_user, :deleted, email_address: 'existing@user.com', school: other_school) }

        it 'returns the existing user as undeleted' do
          expect(result.soft_deleted?).to be(false)
        end
      end

      context 'on a responsible_body' do
        before { create(:school_user, email_address: 'existing@user.com', responsible_body: create(:trust)) }

        it 'does not create a user with the given params' do
          expect { result }.not_to change(User, :count)
        end

        it 'does not send any email' do
          expect { perform_enqueued_jobs { result } }.not_to change(ActionMailer::Base.deliveries, :size)
        end

        it 'returns the user unpersisted, with errors on the base and the email_address' do
          expect(result).to be_a(User)
          expect(result).to have_attributes(valid_params)
          expect(result.errors[:base]).not_to be_empty
          expect(result.errors[:email_address]).not_to be_empty
        end
      end
    end
  end

  describe 'invite_school_user' do
    let(:school) { create(:school) }
    let(:preorder_information) { create(:preorder_information, school: school, who_will_order_devices: 'school') }

    before do
      preorder_information
    end

    context 'given an email address that already exists' do
      let(:params) do
        {
          full_name: 'Vlad Valid',
          email_address: 'existing@user.com',
          telephone: '01234 567890',
          school_id: school.id,
          orders_devices: true,
        }
      end
      let(:result) { CreateUserService.invite_school_user(params) }

      context 'user already a user on this school and belongs to a responsible body' do
        let!(:existing_user) { create(:school_user, email_address: 'existing@user.com', school: school, responsible_body_id: school.responsible_body_id) }

        it 'does not create a user with the given params' do
          expect { result }.not_to change(User, :count)
        end

        it 'does not send any email' do
          expect { perform_enqueued_jobs { result } }.not_to change(ActionMailer::Base.deliveries, :size)
        end

        it 'returns the existing user' do
          expect(result).to be_a(User)
          expect(result).to eq(existing_user)
        end
      end

      context 'on the given school' do
        before { create(:school_user, email_address: 'existing@user.com', school: school) }

        it 'does not create a user with the given params' do
          expect { result }.not_to change(User, :count)
        end

        it 'does not send any email' do
          expect { perform_enqueued_jobs { result } }.not_to change(ActionMailer::Base.deliveries, :size)
        end

        it 'returns the user unpersisted, with errors' do
          expect(result).to be_a(User)
          expect(result).to have_attributes(params)
          expect(result.errors.full_messages).not_to be_empty
        end
      end

      context 'on a different school and is a soft deleted user' do
        let!(:other_school) { create(:school) }

        before { create(:school_user, :deleted, email_address: 'existing@user.com', school: other_school) }

        it 'returns the existing user as undeleted' do
          expect(result.soft_deleted?).to be(false)
        end
      end

      context 'on a different school' do
        let!(:other_school) { create(:school) }
        let!(:existing_user) { create(:school_user, email_address: 'existing@user.com', school: other_school) }

        it 'returns the existing user' do
          expect(result).to be_a(User)
          expect(result).to eq(existing_user)
        end

        it 'adds this school to the existing users schools' do
          expect(result.schools).to include(other_school)
          expect(result.schools).to include(school)
        end

        context 'when the additional school has no value for who_will_order_devices' do
          before do
            school.preorder_information&.destroy!
            school.responsible_body.update!(who_will_order_devices: nil)
          end

          it 'creates a PreorderInformation, defaulting who_will_order_devices to "school"' do
            expect { result }.to change { school.reload&.who_will_order_devices }.from(nil).to('school')
            expect(school.who_will_order_devices).to eq('school')
          end
        end

        it 'sends the additional school added email' do
          expect { perform_enqueued_jobs { result } }.to change(ActionMailer::Base.deliveries, :size).by(1)
          expect(last_email.to[0]).to eq(existing_user[:email_address])
          expect(last_email.header['template-id'].value).to eq(Settings.govuk_notify.templates.devices.user_added_to_additional_school)
        end

        it 'updates the school status to reflect that the school has been contacted' do
          result
          expect(school.reload.device_ordering_status).to eq('school_contacted')
        end

        context 'when the existing user has a blank telephone number' do
          before do
            existing_user.update!(telephone: '')
          end

          it 'applies the given telephone number' do
            expect { result }.to(change { existing_user.reload.telephone }.to('01234 567890'))
          end
        end

        context 'when the existing user has a non-blank telephone number' do
          it 'retains the existing telephone number' do
            expect { result }.not_to(change { existing_user.reload.telephone })
          end
        end

        context 'when the existing user cannot order devices' do
          before do
            existing_user.update!(orders_devices: false)
          end

          it 'applies the new orders_devices value' do
            expect { result }.to(change { existing_user.reload.orders_devices }.to(true))
          end
        end

        context 'when the existing user can order devices, but the given orders_devices is false' do
          let(:params) do
            {
              full_name: 'Vlad Valid',
              email_address: 'existing@user.com',
              telephone: '01234 567890',
              school_id: school.id,
              orders_devices: false,
            }
          end

          before do
            existing_user.update!(orders_devices: true)
          end

          it 'retains the existing value' do
            expect { result }.not_to(change { existing_user.reload.orders_devices })
          end
        end
      end

      context 'on a responsible body' do
        let(:trust) { create(:trust) }
        let!(:existing_user) { create(:trust_user, email_address: 'existing@user.com', responsible_body: trust) }

        it 'returns the existing user' do
          expect(result).to be_a(User)
          expect(result).to eq(existing_user)
        end

        it 'adds this school to the existing users schools' do
          expect(result.schools).to include(school)
        end

        it 'leaves the responsible_body_id on the existing user as-is' do
          expect { result }.not_to change(existing_user.reload, :responsible_body_id)
        end

        it 'sends the additional school added email' do
          expect { perform_enqueued_jobs { result } }.to change(ActionMailer::Base.deliveries, :size).by(1)
          expect(last_email.to[0]).to eq(existing_user[:email_address])
          expect(last_email.header['template-id'].value).to eq(Settings.govuk_notify.templates.devices.user_added_to_additional_school)
        end

        it 'updates the school status to reflect that the school has been contacted' do
          result
          expect(school.reload.device_ordering_status).to eq('school_contacted')
        end

        context 'when the existing user has a blank telephone number' do
          before do
            existing_user.update!(telephone: '')
          end

          it 'applies the given telephone number' do
            expect { result }.to(change { existing_user.reload.telephone }.to('01234 567890'))
          end
        end

        context 'when the existing user has a non-blank telephone number' do
          it 'retains the existing telephone number' do
            expect { result }.not_to(change { existing_user.reload.telephone })
          end
        end

        context 'when the existing user cannot order devices' do
          before do
            existing_user.update!(orders_devices: false)
          end

          it 'applies the new orders_devices value' do
            expect { result }.to(change { existing_user.reload.orders_devices }.to(true))
          end
        end

        context 'when the existing user can order devices, but the given orders_devices is false' do
          let(:params) do
            {
              full_name: 'Vlad Valid',
              email_address: 'existing@user.com',
              telephone: '01234 567890',
              school_id: school.id,
              orders_devices: false,
            }
          end

          before do
            existing_user.update!(orders_devices: true)
          end

          it 'retains the existing value' do
            expect { result }.not_to(change { existing_user.reload.orders_devices })
          end
        end
      end
    end

    context 'given valid user params' do
      let(:valid_params) do
        {
          full_name: 'Vlad Valid',
          email_address: 'vlad@example.com',
          telephone: '01234 567890',
          school_id: school.id,
          orders_devices: true,
        }
      end

      let(:now) { Time.zone.now }

      let(:result) { CreateUserService.invite_school_user(valid_params) }

      it 'creates a user with the given params' do
        expect { result }.to change(User, :count).by(1)
        expect(User.last).to have_attributes(valid_params)
      end

      it 'sends the correct email' do
        expect { perform_enqueued_jobs { result } }.to change(ActionMailer::Base.deliveries, :size).by(1)
        expect(last_email.to[0]).to eq(valid_params[:email_address])
        expect(last_email.header['template-id'].value).to eq(Settings.govuk_notify.templates.devices.school_nominated_contact)
      end

      it 'returns the user' do
        expect(result).to be_a(User)
        expect(result).to have_attributes(valid_params)
      end

      it 'updates the school status to reflect that the school has been contacted' do
        expect(result.school.device_ordering_status).to eq('school_contacted')
      end

      context 'when the additional school has no value for who_will_order_devices' do
        before do
          school.preorder_information&.destroy!
          school.responsible_body.update!(who_will_order_devices: nil)
        end

        it 'creates a PreorderInformation, defaulting who_will_order_devices to "school"' do
          expect { result }.to change { school.reload&.who_will_order_devices }.from(nil).to('school')
          expect(school.who_will_order_devices).to eq('school')
        end
      end
    end

    context 'given invalid user params' do
      let(:invalid_params) do
        {
          full_name: '.',
          email_address: 'dunno',
          school_id: nil,
        }
      end
      let(:result) { CreateUserService.invite_school_user(invalid_params) }

      it 'does not create a user with the given params' do
        expect { result }.not_to change(User, :count)
      end

      it 'does not send any email' do
        expect { perform_enqueued_jobs { result } }.not_to change(ActionMailer::Base.deliveries, :size)
      end

      it 'returns the user unpersisted, with errors' do
        expect(result).to be_a(User)
        expect(result).to have_attributes(invalid_params)
        expect(result.errors.full_messages).not_to be_empty
      end
    end
  end
end
