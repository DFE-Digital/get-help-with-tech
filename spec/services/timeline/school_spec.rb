require 'rails_helper'

RSpec.describe Timeline::School, versioning: true do
  let(:school) { create(:school) }

  describe '#changesets' do
    subject(:timeline) { described_class.new(school: school) }

    context 'when there are no relevant changes' do
      it 'add no changes to the result' do
        expect { school.update!(address_1: 'new address line 1') }
          .not_to(change { described_class.new(school: school).changesets.map(&:changes) })
      end
    end

    context 'when there are relevant changes' do
      it 'add a new changeset to the resulting collection' do
        expect { school.update!(status: 'closed') }
          .to(change { described_class.new(school: school).changesets.size }.from(1).to(2))
      end

      it 'returns Changeset populated correctly' do
        school.update!(status: 'closed')
        changeset = timeline.changesets.last

        expect(changeset).to be_a(Timeline::Changeset)
        expect(changeset.item).to eql(school)
        expect(changeset.updated_at).to be_within(10.seconds).of(school.updated_at)
        expect(changeset.changes).to eq({ 'status' => %w[open closed] })
      end
    end
  end
end
