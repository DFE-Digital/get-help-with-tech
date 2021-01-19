require 'rails_helper'

RSpec.describe SupportTicket do
  it 'has sensible defaults' do
    expect(support_ticket.user_type).to eq 'other_type_of_user'
    expect(support_ticket.school_name).to eq ''
    expect(support_ticket.school_unique_id).to eq ''
    expect(support_ticket.full_name).to eq ''
    expect(support_ticket.email_address).to eq ''
    expect(support_ticket.telephone_number).to eq ''
    expect(support_ticket.support_topics).to eq []
    expect(support_ticket.message).to eq ''
  end

  describe '#requires_school?' do
    it 'returns true for applicable user types' do
      %w[school_or_single_academy_trust multi_academy_trust local_authority college].each do |user_type|
        expect(support_ticket(user_type: user_type).requires_school?).to eq true
      end
    end

    it 'returns false for types that do not require school details' do
      %w[other_type_of_user parent_or_guardian_or_carer_or_pupil_or_care_leaver].each do |user_type|
        expect(support_ticket(user_type: user_type).requires_school?).to eq false
      end
    end
  end

private

  def support_ticket(params = {})
    SupportTicket.new(params: params)
  end
end
