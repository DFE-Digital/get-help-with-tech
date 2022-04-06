require 'rails_helper'

RSpec.describe Asset, type: :model do
  subject(:asset) { build(:asset) }

  describe 'creation' do
    let(:bios_password) { 'secretbiospassword' }
    let(:admin_password) { 'secretadminpassword' }
    let(:hardware_hash) { 'secrethardwarehash' }
    let(:required_attributes) { { serial_number: '30040000', department_id: 'LEA800', department_sold_to_id: '8106000', location_id: '114000', location_cc_ship_to_account: '81065000' } }
    let(:secure_attributes) { { bios_password: bios_password, admin_password: admin_password, hardware_hash: hardware_hash } }
    let(:encryptor) { class_spy('EncryptionService') }

    before { stub_const('EncryptionService', encryptor) }

    describe '.new' do
      before { Asset.new(required_attributes.merge(secure_attributes)) }

      specify { expect(encryptor).to have_received(:encrypt).with(bios_password).once }
      specify { expect(encryptor).to have_received(:encrypt).with(admin_password).once }
      specify { expect(encryptor).to have_received(:encrypt).with(hardware_hash).once }
    end

    describe '.create' do
      before { Asset.create(required_attributes.merge(secure_attributes)) }

      specify { expect(encryptor).to have_received(:encrypt).with(bios_password).once }
      specify { expect(encryptor).to have_received(:encrypt).with(admin_password).once }
      specify { expect(encryptor).to have_received(:encrypt).with(hardware_hash).once }
    end

    context 'FactoryBot' do
      describe '.create' do
        before { create(:asset, required_attributes.merge(secure_attributes)) }

        specify { expect(encryptor).to have_received(:encrypt).with(bios_password).once }
        specify { expect(encryptor).to have_received(:encrypt).with(admin_password).once }
        specify { expect(encryptor).to have_received(:encrypt).with(hardware_hash).once }
      end

      describe '.build' do
        before { build(:asset, required_attributes.merge(secure_attributes)) }

        specify { expect(encryptor).to have_received(:encrypt).with(bios_password).once }
        specify { expect(encryptor).to have_received(:encrypt).with(admin_password).once }
        specify { expect(encryptor).to have_received(:encrypt).with(hardware_hash).once }
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:serial_number) }
    it { is_expected.to validate_presence_of(:department_sold_to_id) }

    it { is_expected.not_to validate_presence_of(:encrypted_bios_password) }
    it { is_expected.not_to validate_presence_of(:encrypted_admin_password) }
    it { is_expected.not_to validate_presence_of(:encrypted_hardware_hash) }
  end

  describe 'indices' do
    it { is_expected.to have_db_index(:serial_number) }
    it { is_expected.to have_db_index(:department_sold_to_id) }
    it { is_expected.to have_db_index(:location_cc_ship_to_account) }
  end

  describe 'encrypted fields' do
    let(:encryptor) { class_spy('EncryptionService') }

    subject { build(:asset) }

    before { stub_const('EncryptionService', encryptor) }

    describe '#sys_created_at' do
      context 'set' do
        context 'string' do
          let(:string_date) { '2020-11-22 18:03:04' }

          before { asset.sys_created_at = string_date }

          specify { expect(asset.sys_created_at).to eq(Time.zone.parse('22 Nov 2020 6:03:04pm')) }
        end

        context 'datetime' do
          let(:datetime) { Time.zone.parse('25 Dec 2020 9:00am') }

          before { asset.sys_created_at = datetime }

          specify { expect(asset.sys_created_at).to eq(datetime) }
        end
      end
    end

    describe '#bios_password' do
      context 'get' do
        before { asset.bios_password }

        specify { expect(encryptor).to have_received(:decrypt).once.with(asset.encrypted_bios_password) }
      end

      context 'set' do
        let(:plaintext) { 'secret' }

        before { asset.bios_password = 'secret' }

        specify { expect(encryptor).to have_received(:encrypt).once.with(plaintext) }
        specify { expect(asset.encrypted_bios_password).to be_present }
        specify { expect(asset.encrypted_bios_password).not_to eq(plaintext) }
      end
    end

    describe '#admin_password' do
      context 'get' do
        before { asset.admin_password }

        specify { expect(encryptor).to have_received(:decrypt).once.with(asset.encrypted_admin_password) }
      end
    end

    describe '#hardware_hash' do
      context 'get' do
        before { asset.hardware_hash }

        specify { expect(encryptor).to have_received(:decrypt).once.with(asset.encrypted_hardware_hash) }
      end
    end
  end

  describe '.owned_by' do
    context 'school' do
      let(:school_a) { create(:school) }
      let(:school_b) { create(:school) }

      context 'when the asset ship to matches the school computacenter reference' do
        let(:school_a_asset_1) { create(:asset, location_cc_ship_to_account: school_a.computacenter_reference) }
        let(:school_a_asset_2) { create(:asset, location_cc_ship_to_account: school_a.computacenter_reference) }
        let(:school_b_asset_1) { create(:asset, location_cc_ship_to_account: school_b.computacenter_reference) }

        specify { expect(Asset.owned_by(school_a)).to contain_exactly(school_a_asset_1, school_a_asset_2) }
      end

      context 'when a SCL asset department matches a school name' do
        let(:school_asset_1) { create(:asset, department: school_a.name) }

        specify { expect(Asset.owned_by(school_a)).to contain_exactly(school_asset_1) }
      end
    end

    context 'RB' do
      let(:rb) { create(:local_authority) }
      let(:other_rb) { create(:local_authority) }
      let(:rb_self_managed_school) { create(:school, :manages_orders, responsible_body_id: rb.id) }
      let(:rb_centrally_managed_school) { create(:school, :centrally_managed, responsible_body_id: rb.id) }

      context 'when the asset sold to matches the rb sold to' do
        let!(:rb_asset_1) { create(:asset, department_sold_to_id: rb.computacenter_reference) }
        let!(:rb_asset_2) { create(:asset, department_sold_to_id: rb.computacenter_reference) }

        before do
          create(:asset, department_sold_to_id: other_rb.computacenter_reference)
        end

        specify { expect(Asset.owned_by(rb)).to contain_exactly(rb_asset_1, rb_asset_2) }
      end

      context "when the asset ship to matches the one of the rb self-managed schools' ship to" do
        let!(:rb_school_asset) { create(:asset, location_cc_ship_to_account: rb_self_managed_school.computacenter_reference) }

        before do
          create(:asset, location_cc_ship_to_account: rb_centrally_managed_school.computacenter_reference)
        end

        specify { expect(Asset.owned_by(rb)).to contain_exactly(rb_school_asset) }
      end

      context 'when a SCL asset department_id points to the rb gias_id' do
        let!(:rb_sc_asset) { create(:asset, department_id: "SC#{rb.gias_id}") }

        before do
          create(:asset, department_id: "SD#{rb.gias_id}")
        end

        specify { expect(Asset.owned_by(rb)).to contain_exactly(rb_sc_asset) }
      end
    end

    context 'neither RB nor school' do
      specify { expect(Asset.owned_by(nil)).to eq(Asset.none) }
    end
  end

  describe '.first_viewed_between' do
    let!(:asset_just_after_start_of_period) { create(:asset, first_viewed_at: Time.zone.parse('1 Jan 2021 00:01')) }
    let!(:asset_just_before_end_of_period) { create(:asset, first_viewed_at: Time.zone.parse('31 Jan 2021 23:59')) }

    specify { expect(Asset.first_viewed_during_period(Time.zone.parse('1 Jan 2021').beginning_of_day..Time.zone.parse('31 Jan 2021').end_of_day)).to contain_exactly(asset_just_after_start_of_period, asset_just_before_end_of_period) }
  end

  describe '.search_by_serial_numbers' do
    let!(:asset_1) { create(:asset) }

    before do
      create(:asset, first_viewed_at: Time.zone.parse('31 Dec 2020 23:59'))
      create(:asset, first_viewed_at: Time.zone.parse('1 Feb 2021 00:01'))
    end

    context 'single serial number' do
      specify { expect(Asset.search_by_serial_numbers(asset_1.serial_number)).to contain_exactly(asset_1) }
      specify { expect(Asset.search_by_serial_numbers([asset_1.serial_number])).to contain_exactly(asset_1) }
    end

    context 'different case' do
      let(:upper_case_serial_number) { 'Z1' }
      let(:lower_case_serial_number) { 'z1' }
      let!(:upper_case_serial_number_asset) { create(:asset, serial_number: upper_case_serial_number) }

      specify { expect(Asset.search_by_serial_numbers(lower_case_serial_number)).to contain_exactly(upper_case_serial_number_asset) }
    end

    context 'multiple matches of same serial number' do
      let!(:asset_3) { create(:asset, serial_number: asset_1.serial_number) }

      it 'returns all assets with the same serial number' do
        expect(Asset.search_by_serial_numbers(asset_1.serial_number)).to contain_exactly(asset_1, asset_3)
      end
    end

    context 'matches for different serial numbers' do
      let!(:asset_a) { create(:asset) }
      let!(:asset_b) { create(:asset) }

      it 'returns both assets' do
        expect(Asset.search_by_serial_numbers([asset_a.serial_number, asset_b.serial_number])).to contain_exactly(asset_a, asset_b)
      end
    end

    it 'return no matches' do
      expect(Asset.search_by_serial_numbers('hax0r')).to be_empty
    end
  end

  describe '#==' do
    subject { build(:asset, tag: 'a', serial_number: 'b') }

    context 'same tag and serial number' do
      let(:other_asset) { build(:asset, tag: 'a', serial_number: 'b') }

      it { is_expected.to eq(other_asset) }
    end

    context 'different tag' do
      let(:other_asset) { build(:asset, tag: 'p', serial_number: 'b') }

      it { is_expected.not_to eq(other_asset) }
    end

    context 'different serial number' do
      let(:other_asset) { build(:asset, tag: 'a', serial_number: 'q') }

      it { is_expected.not_to eq(other_asset) }
    end
  end

  describe '#bios_unlockable?' do
    context 'Dynabook R50 models' do
      let(:asset) { build(:asset, model: 'Dynabook R50-xxx') }

      specify { expect(asset).to be_bios_unlockable }
    end

    context 'Non Dynabook R50 models' do
      let(:asset) { build(:asset, model: 'Non Dynabook R50-xxx') }

      specify { expect(asset).not_to be_bios_unlockable }
    end
  end

  describe '#viewed?' do
    let(:asset) { build(:asset) }

    context 'viewed' do
      before { asset.first_viewed_at = 1.day.ago }

      specify { expect(asset).to be_viewed }
    end

    context 'never viewed' do
      before { asset.first_viewed_at = nil }

      specify { expect(asset).not_to be_viewed }
    end
  end

  describe '#has_secret_information?' do
    context 'with BIOS password, admin password and hardware hash' do
      subject { build(:asset) }

      specify { expect([asset.bios_password, asset.admin_password, asset.hardware_hash]).to all be_present }
      it { is_expected.to have_secret_information }
    end

    context 'none of BIOS password, admin password and hardware hash' do
      subject { build(:asset, :lacks_bios_password, :lacks_admin_password, :lacks_hardware_hash) }

      it { is_expected.not_to have_secret_information }
    end

    context 'with BIOS password only' do
      subject { build(:asset, :lacks_admin_password, :lacks_hardware_hash) }

      it { is_expected.to have_secret_information }
    end

    context 'with admin password only' do
      subject { build(:asset, :lacks_bios_password, :lacks_hardware_hash) }

      it { is_expected.to have_secret_information }
    end

    context 'with hardware hash only' do
      subject { build(:asset, :lacks_bios_password, :lacks_admin_password) }

      it { is_expected.to have_secret_information }
    end

    context 'has two of BIOS password, admin password and hardware hash' do
      subject { build(:asset, :lacks_bios_password) }

      it { is_expected.to have_secret_information }
    end
  end

  describe '#to_support_csv' do
    let!(:school) { create(:school) }
    let!(:asset) { create(:asset, location_cc_ship_to_account: school.computacenter_reference) }

    let(:csv) { Asset.owned_by(school).to_support_csv }

    specify { expect(csv.split("\n").size).to eq(2) }

    specify { expect(csv).to start_with('Serial/IMEI,Model,Local Authority/Academy Trust,School/College,Sold To,Ship To,BIOS Password,Admin Password,Hardware Hash') }
    specify { expect(csv).to include("#{asset.serial_number},#{asset.model},#{asset.department},#{asset.location},#{asset.department_sold_to_id},#{asset.location_cc_ship_to_account},#{asset.bios_password},#{asset.admin_password},#{asset.hardware_hash}") }
  end

  describe '#to_non_support_csv' do
    context 'normal export' do
      context 'default index' do
        let!(:school) { create(:school) }
        let!(:asset_1) { create(:asset, location_cc_ship_to_account: school.computacenter_reference) }
        let!(:asset_2) { create(:asset, location_cc_ship_to_account: school.computacenter_reference) }
        let!(:other_asset) { create(:asset) }

        let(:csv) { Asset.owned_by(school).to_non_support_csv }

        specify { expect(csv.split("\n").size).to eq(3) }

        specify { expect(csv).to start_with('Serial/IMEI,Model,Local Authority/Academy Trust,School/College,BIOS Password,Admin Password,Hardware Hash') }
        specify { expect(csv).to include("#{asset_1.serial_number},#{asset_1.model},#{asset_1.department},#{asset_1.location},#{asset_1.bios_password},#{asset_1.admin_password},#{asset_1.hardware_hash}") }
        specify { expect(csv).to include("#{asset_2.serial_number},#{asset_2.model},#{asset_2.department},#{asset_2.location},#{asset_2.bios_password},#{asset_2.admin_password},#{asset_2.hardware_hash}") }

        specify { expect(csv).not_to include("#{other_asset.serial_number},#{other_asset.model},#{other_asset.department},#{other_asset.location},#{other_asset.bios_password},#{other_asset.admin_password},#{other_asset.hardware_hash}") }
      end
    end

    # https://owasp.org/www-community/attacks/CSV_Injection
    context 'input which could be interpreted as a formula' do
      let(:bad_input_1) { '=1+1' }
      let(:escaped_output_1) { %q("'=1+1") }

      let!(:school) { create(:school) }
      let!(:asset_1) { create(:asset, model: bad_input_1, location_cc_ship_to_account: school.computacenter_reference) }

      let(:csv) { Asset.owned_by(school).to_non_support_csv }

      specify { expect(csv).not_to include("#{asset_1.serial_number},#{bad_input_1},#{asset_1.department},#{asset_1.location},#{asset_1.bios_password},#{asset_1.admin_password},#{asset_1.hardware_hash}") }
      specify { expect(csv).to include("#{asset_1.serial_number},#{escaped_output_1},#{asset_1.department},#{asset_1.location},#{asset_1.bios_password},#{asset_1.admin_password},#{asset_1.hardware_hash}") }
    end
  end

  describe '#to_viewed_csv' do
    let!(:asset) { create(:asset, :viewed) }
    let!(:unviewed_asset) { create(:asset, :never_viewed) }
    let(:covering_range) { 5.minutes.before(asset.first_viewed_at)..5.minutes.after(asset.first_viewed_at) }
    let(:csv) { Asset.first_viewed_during_period(covering_range).to_viewed_csv }

    specify { expect(csv.split("\n").size).to eq(2) }

    specify { expect(csv).to start_with('serial_number,first_viewed_at') }
    specify { expect(csv).to include("#{asset.serial_number},#{asset.first_viewed_at}") }
    specify { expect(csv).not_to include("#{unviewed_asset.serial_number},#{unviewed_asset.first_viewed_at}") }
  end
end
