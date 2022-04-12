require 'rails_helper'

describe UserSummaryListComponent do
  let(:user) { create(:school_user, email_address: 'davy.jones@school.sch.uk', telephone: '12345') }

  subject(:result) { render_inline(described_class.new(user:)) }

  it 'displays the user email address' do
    expect(result.css('dd')[0].text).to include('davy.jones@school.sch.uk')
  end

  it 'displays the user telephone' do
    expect(result.css('dd')[1].text).to include('12345')
  end

  context 'when the user has never signed in' do
    before do
      user.update(last_signed_in_at: nil)
    end

    it 'displays that they have never signed in' do
      expect(result.css('dd')[2].text).to include('Never')
    end
  end

  context 'when the user has signed in before' do
    before do
      user.update(last_signed_in_at: Time.zone.local(2020, 8, 28, 14, 3))
    end

    it 'displays when they last signed in' do
      expect(result.css('dd')[2].text).to include('28 Aug 14:03')
    end
  end
end
