require 'rails_helper'

RSpec.describe Timeline::School, versioning: true do
  let(:school) { create(:school) }

  describe '#changesets' do
    subject(:timeline) { described_class.new(school: school) }

    context 'when there are no changes' do
      it 'returns empty collection' do
        expect(timeline.changesets).to be_empty
      end
    end

    context 'when there are no relevant changes' do
      before do
        school.update!(address_1: 'new address line 1')
      end

      it 'returns empty collection' do
        expect(timeline.changesets).to be_empty
      end
    end

    context 'when there are relevant changes' do
      before do
        school.update!(status: 'closed')
      end

      it 'returns changesets' do
        expect(timeline.changesets).not_to be_empty
      end

      it 'returns Changeset populated correctly' do
        changeset = timeline.changesets.first

        expect(changeset).to be_a(Timeline::Changeset)
        expect(changeset.item).to eql(school)
        expect(changeset.updated_at).to be_within(10.seconds).of(school.updated_at)
      end
    end
  end
end
