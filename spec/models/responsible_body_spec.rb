require 'rails_helper'

RSpec.describe ResponsibleBody, type: :model do
  subject(:local_authority) { create(:local_authority) }

  describe '#next_school_sorted_ascending_by_name' do
    it 'allows navigating down a list of alphabetically-sorted schools' do
      zebra = create(:school, name: 'Zebra', responsible_body: local_authority)
      aardvark = create(:school, name: 'Aardvark', responsible_body: local_authority)
      tiger = create(:school, name: 'Tiger', responsible_body: local_authority)

      expect(local_authority.next_school_sorted_ascending_by_name(aardvark)).to eq(tiger)
      expect(local_authority.next_school_sorted_ascending_by_name(tiger)).to eq(zebra)
    end
  end
end
