require 'rails_helper'

RSpec.describe Computacenter::ResponsibleBodyUrns do
  fe_klass = Class.new do
    include Computacenter::ResponsibleBodyUrns::InstanceMethods

    def type
      'FurtherEducationCollege'
    end

    def name
      'name of FurtherEducationCollege'
    end

    def schools
      [OpenStruct.new(ukprn: 12_345_678)]
    end
  end

  describe '#computacenter_name' do
    subject(:model) { fe_klass.new }

    it 'returns name' do
      expect(model.computacenter_name).to eql('name of FurtherEducationCollege')
    end
  end

  describe '#computacenter_identifier' do
    subject(:model) { fe_klass.new }

    it 'returns first school ukprn' do
      expect(model.computacenter_identifier).to eql('FE12345678')
    end
  end
end
