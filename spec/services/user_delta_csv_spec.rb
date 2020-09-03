require 'rails_helper'

RSpec.describe UserDeltaCsv, versioning: true do
  let(:now) { Time.now.utc }
  let(:expected_headers) do
    [
      'First Name',
      'Last Name',
      'Email',
      'Telephone',
      'Responsible Body',
      'Responsible Body URN',
      'CC Sold To Number',
      'School',
      'School URN',
      'CC Ship To Number',
      'Date of Update',
      'Time of Update',
      'Timestamp of Update',
      'Type of Update',
      'Original Email'
    ]
  end

  describe '#to_csv' do
    it 'adds headers to csv' do
      rows = CSV.parse(subject.to_csv)

      expect(rows[0]).to eql(expected_headers)
    end

    context "when a new trust user is created" do
      let(:user) { create(:trust_user) }

      before do
        Timecop.freeze(now) do
          user
        end
      end

      it "adds user details with new type" do
        rows = CSV.parse(subject.to_csv)

        expect(rows[1]).to eql([
          user.first_name,
          user.last_name,
          user.email_address,
          user.telephone,
          user.responsible_body.name,
          user.responsible_body.computacenter_identifier,
          user.responsible_body.computacenter_reference,
          nil,
          nil,
          nil,
          now.strftime('%d/%m/%Y'),
          now.strftime('%R'),
          now.iso8601,
          'New',
          nil
        ])
      end
    end

    context "when a new school user is created" do
      let(:user) { create(:school_user) }

      before do
        Timecop.freeze(now) do
          user
        end
      end

      it "adds user details with new type" do
        rows = CSV.parse(subject.to_csv)

        expect(rows[1]).to eql([
          user.first_name,
          user.last_name,
          user.email_address,
          user.telephone,
          nil,
          nil,
          nil,
          user.school.name,
          user.school.urn.to_s,
          user.school.computacenter_reference,
          now.strftime('%d/%m/%Y'),
          now.strftime('%R'),
          now.iso8601,
          'New',
          nil
        ])
      end
    end

    context "when a user is updated" do
      let(:user) { create(:school_user) }
      let(:original_user) { user.dup }

      before do
        Timecop.freeze(10.day.ago) do
          user
          original_user
        end

        Timecop.freeze(now) do
          user.update(full_name: 'John Doe', email_address: 'new@example.com')
        end
      end

      xit "adds user details with Change type" do
        rows = CSV.parse(subject.to_csv)

        expect(rows[1]).to eql([
          "John",
          "Doe",
          'new@example.com',
          user.telephone,
          nil,
          nil,
          nil,
          user.school.name,
          user.school.urn.to_s,
          user.school.computacenter_reference,
          now.strftime('%d/%m/%Y'),
          now.strftime('%R'),
          now.iso8601,
          'Change',
          original_user.email_address,
        ])
      end
    end

    context "when a user is deleted" do
      let(:user) { create(:school_user) }

      before do
        Timecop.freeze(10.day.ago) do
          user
        end

        Timecop.freeze(now) do
          user.destroy
        end
      end

      xit "adds user details with Change type" do
        rows = CSV.parse(subject.to_csv)

        expect(rows[1]).to eql([
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          now.strftime('%d/%m/%Y'),
          now.strftime('%R'),
          now.iso8601,
          'Remove',
          user.email_address
        ])
      end
    end
  end
end
