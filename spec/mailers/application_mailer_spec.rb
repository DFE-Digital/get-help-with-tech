require 'rails_helper'

RSpec.describe ApplicationMailer do
  let(:personalisation) do
    {
      name: 'bob',
    }
  end

  subject(:mailer) { described_class.new }

  describe '#template_mail' do
    it 'sends emails' do
      expect {
        mailer.template_mail('some_template_id',
                             to: 'user1@example.com',
                             personalisation:).deliver
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    context 'when user has been deleted' do
      let(:user) { create(:school_user, deleted_at: 1.second.ago) }

      it 'does not send the email to deleted user' do
        expect {
          mailer.template_mail('some_template_id',
                               to: user.email_address,
                               personalisation:).deliver

          mailer.template_mail('some_template_id',
                               to: user.email_address,
                               personalisation:).deliver_now
        }.not_to change(ActionMailer::Base.deliveries, :size)
      end
    end
  end
end
