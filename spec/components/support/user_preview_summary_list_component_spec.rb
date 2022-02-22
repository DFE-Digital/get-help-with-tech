require 'rails_helper'

describe Support::UserPreviewSummaryListComponent do
  subject(:result) { render_inline(described_class.new(user:)) }

  let(:school) { create(:school, :manages_orders) }
  let(:user) do
    create(:school_user, :has_seen_privacy_notice, telephone: '12345', school: school)
  end

  it 'displays the email address' do
    expect(result.css('.govuk-summary-list__row')[0].text).to include(user.email_address)
  end

  it 'displays the telephone' do
    expect(result.css('.govuk-summary-list__row')[1].text).to include('12345')
  end

  it 'displays when privacy notice was seen' do
    expect(result.css('.govuk-summary-list__row')[2].text).to include(user.privacy_notice_seen_at.strftime('%d'))
  end

  it 'does NOT display the Deleted row' do
    expect(result.css('.govuk-summary-list__row')[6]).to be_nil
  end

  context 'when privacy notice has not been seen' do
    let(:user) do
      build(:school_user, :has_not_seen_privacy_notice, telephone: '12345')
    end

    it 'displays privacy notice as not seen' do
      expect(result.css('.govuk-summary-list__row')[2].text).to include('No')
    end
  end

  context 'for a user who cannot order devices' do
    let(:user) do
      build(:school_user, telephone: '12345', orders_devices: false)
    end

    it 'displays the user as unable to order devices' do
      expect(result.css('.govuk-summary-list__row')[5].text).to include('No')
    end
  end

  context 'for a user who orders devices but has not seen the privacy notice' do
    let(:user) do
      create(:school_user, telephone: '12345', orders_devices: true, privacy_notice_seen_at: nil, school: school)
    end

    it 'displays the user as able to order devices once they sign in' do
      expect(result.css('.govuk-summary-list__row')[5].text).to include('No, will get a TechSource account once they sign in')
    end
  end

  context 'for a user who orders devices, has seen the privacy notice but has no TechSource account yet' do
    let(:user) do
      create(:school_user,
             telephone: '12345',
             orders_devices: true,
             privacy_notice_seen_at: 5.days.ago,
             techsource_account_confirmed_at: nil,
             school: school)
    end

    it "displays the user as able to order devices once it's confirmed that they have a TechSource account" do
      expect(result.css('.govuk-summary-list__row')[5].text).to include('No, waiting for TechSource account')
    end
  end

  context 'for a user who orders devices, has seen the privacy notice and has a TechSource account yet' do
    let(:user) do
      create(:school_user,
             telephone: '12345',
             orders_devices: true,
             privacy_notice_seen_at: 5.days.ago,
             techsource_account_confirmed_at: 4.days.ago,
             school: school)
    end

    it 'displays the user as able to order devices' do
      expect(result.css('.govuk-summary-list__row')[5].text).to include('Yes')
    end

    it 'displays the when the TechSource account was confirmed' do
      expect(result.css('.govuk-summary-list__row')[5].text).to include(user.techsource_account_confirmed_at.strftime('%d'))
    end
  end

  context 'soft-deleted user' do
    let(:user) do
      build(:school_user, :has_seen_privacy_notice, telephone: '12345', deleted_at: Time.zone.now)
    end

    it 'displays the user is deleted' do
      expect(result.css('.govuk-summary-list__row')[6].text).to include('Deleted')
      expect(result.css('.govuk-summary-list__row')[6].text).to include('Yes')
    end
  end
end
