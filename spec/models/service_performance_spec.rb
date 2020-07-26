require 'rails_helper'

RSpec.describe ServicePerformance, type: :model do
  subject(:stats) { ServicePerformance.new }

  describe '#total_signed_in_users' do
    it 'counts only signed-in responsible body and MNO users' do
      # the following should be counted
      create(:mno_user, :signed_in_before)
      create(:local_authority_user, :signed_in_before)

      # the following should be ignored
      create(:dfe_user, :signed_in_before)
      create(:mno_user, :never_signed_in)
      create(:local_authority_user, :never_signed_in)

      expect(stats.total_signed_in_users).to eq(2)
    end
  end

  describe '#number_of_different_mnos_signed_in' do
    it 'counts only the MNOs where at least one user has signed in' do
      mnos = create_list(:mobile_network, 4)

      # mno[0] should count
      create_list(:mno_user, 2, :signed_in_before, mobile_network: mnos[0])

      # mno[1] should count
      create(:mno_user, :signed_in_before, mobile_network: mnos[1])
      create(:mno_user, :never_signed_in, mobile_network: mnos[1])

      # mno[2] shouldn't count as nobody's signed in
      create(:mno_user, :never_signed_in, mobile_network: mnos[2])

      # mno[3] shouldn't count as it has no users

      expect(stats.number_of_different_mnos_signed_in).to eq(2)
    end
  end

  describe '#number_of_different_responsible_bodies_signed_in' do
    it 'counts only the responsible bodies where at least one user has signed in' do
      # this one should count
      local_authority = create(:local_authority)
      create_list(:local_authority_user, 2, :signed_in_before, responsible_body: local_authority)

      # this one should count
      trust = create(:trust)
      create(:trust_user, :signed_in_before, responsible_body: trust)
      create(:trust_user, :never_signed_in, responsible_body: trust)

      # this one shouldn't count as nobody's signed in
      create(:trust_user, :never_signed_in)

      # this one shouldn't count as it has no users
      create(:local_authority)

      expect(stats.number_of_different_responsible_bodies_signed_in).to eq(2)
    end
  end

  describe '#number_of_distributed_bt_wifi_vouchers' do
    it 'counts only the vouchers that have been downloaded by responsible bodies' do
      # these will count
      create_list(:bt_wifi_voucher, 3, responsible_body: create(:local_authority), distributed_at: 3.days.ago)
      create_list(:bt_wifi_voucher, 4, responsible_body: create(:trust), distributed_at: 5.days.ago)

      # these won't count
      create_list(:bt_wifi_voucher, 2, responsible_body: create(:trust), distributed_at: nil)

      expect(stats.number_of_distributed_bt_wifi_vouchers).to eq(7)
    end
  end

  describe '#number_of_responsible_bodies_with_distributed_bt_wifi_vouchers' do
    it 'counts the number of unique responsible bodies that downloaded BT wifi vouchers' do
      # these will count
      create_list(:bt_wifi_voucher, 3, responsible_body: create(:local_authority), distributed_at: 3.days.ago)
      create_list(:bt_wifi_voucher, 4, responsible_body: create(:trust), distributed_at: 5.days.ago)

      # these won't count
      create_list(:bt_wifi_voucher, 2, responsible_body: create(:trust), distributed_at: nil)

      expect(stats.number_of_responsible_bodies_with_distributed_bt_wifi_vouchers).to eq(2)
    end
  end
end
