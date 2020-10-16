require 'rails_helper'

describe Support::EmailAuditListComponent do
  let(:emails_sent_on) { Time.zone.parse('2020-06-01') }
  let(:school_user_a) { create(:school_user, full_name: 'Jane Smith', email_address: 'jsmith@school.sch.uk') }
  let(:school_user_b) { create(:school_user, full_name: 'Adam Jones', email_address: 'ajones@school.sch.uk') }
  let(:email_audits) do
    Timecop.freeze(emails_sent_on) do
      [
        create(:email_audit, user: school_user_a, message_type: 'user_can_order_but_action_needed'),
        create(:email_audit, user: school_user_b, message_type: 'user_can_order'),
      ]
    end
  end

  subject(:result) { render_inline(described_class.new(email_audits)) }

  it 'displays the user name and email address' do
    expect(result.text).to include('Jane Smith <jsmith@school.sch.uk>')
    expect(result.text).to include('Adam Jones <ajones@school.sch.uk>')
  end

  it 'displays the timestamp when the emails were sent (created_at date)' do
    expect(result.text).to include('1 June 2020 at 12:00am')
  end

  it 'displays the type of message' do
    expect(result.text).to include('User can order but action needed')
  end
end
