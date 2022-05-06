require 'rails_helper'

RSpec.describe Computacenter::ImportRawOrdersService do
  describe '#call' do
    let(:path) { Rails.root.join('spec/fixtures/files/orders.csv') }
    let(:service) { Computacenter::ImportRawOrdersService.new(path:) }

    context 'with a valid csv file' do
      it 'imports the raw orders' do
        expect { service.call }.to change(Computacenter::RawOrder, :count).by(2)
      end
    end
  end
end
