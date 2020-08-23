require 'rails_helper'

describe SchoolDetailsSummaryListComponent do
  let(:school) { create(:school, :primary, :la_maintained) }

  it 'renders the status' do
    create(:preorder_information, school: school, who_will_order_devices: :school)
    create(:school_device_allocation, school: school, device_type: 'std_device', allocation: 3)

    result = render_inline(described_class.new(school: school))

    expect(result.css('dd')[0].text).to include('Needs a contact')
    expect(result.css('dd')[1].text).to include('3 devices')
    expect(result.css('dd')[2].text).to include('Primary school')
    expect(result.css('dd')[3].text).to include('The school orders devices')
  end

  context 'when the school has no PreorderInformation record' do
    before do
      school.responsible_body.update(who_will_order_devices: 'responsible_body')
    end

    it 'does not raise an error' do
      expect { render_inline(described_class.new(school: school)) }.not_to raise_error
    end

    it 'gets the default who_will_order_devices value from the responsible_body' do
      result = render_inline(described_class.new(school: school))
      expect(result.css('dd')[3].text).to include('The local authority orders devices')
    end
  end
end
