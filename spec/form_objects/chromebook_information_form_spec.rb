require 'rails_helper'

RSpec.describe ChromebookInformationForm do
  it 'handles whitespace in the email address' do
    stub_request(:get, 'https://www.google.com/a/school.sch.uk/ServiceLogin')
      .to_return(status: 200, body: '', headers: {})

    form = described_class.new(will_need_chromebooks: 'yes',
                               recovery_email_address: ' ab@c.com ',
                               school_or_rb_domain: 'school.sch.uk')

    form.validate

    expect(form.errors[:recovery_email_address]).to be_blank
    expect(form.recovery_email_address).to eq('ab@c.com')
  end

  it 'handles whitespace in the school/RB domain' do
    request = stub_request(:get, 'https://www.google.com/a/school.sch.uk/ServiceLogin')
      .to_return(status: 200, body: '', headers: {})

    form = described_class.new(will_need_chromebooks: 'yes',
                               recovery_email_address: 'ab@c.com',
                               school_or_rb_domain: ' school.sch.uk ')

    form.validate

    expect(request).to have_been_made
  end
end
