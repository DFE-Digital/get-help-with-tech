require 'rails_helper'

RSpec.feature ResponsibleBody do
  scenario 'visiting the page' do
    visit responsible_body_path

    expect(page.status_code).to eq 200
  end
end
