require 'rails_helper'

describe Support::SchoolUserSummaryListComponent do
  subject(:result) { render_inline(described_class.new(user: user)) }
  let(:user) {
    build(:school_user, telephone: '12345')
  }

  it 'displays the email address' do
    expect(result.css('.govuk-summary-list__row')[0].text).to include(user.email_address)
  end

  it 'displays the telephone' do
    expect(result.css('.govuk-summary-list__row')[1].text).to include('12345')
  end
end
