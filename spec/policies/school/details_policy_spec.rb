require 'rails_helper'

describe School::DetailsPolicy do
  subject { described_class }

  permissions :show? do
    it { is_expected.to permit(build(:school_user), build(:school)) }
    it { is_expected.not_to permit(build(:local_authority_user), build(:iss_provision)) }
    it { is_expected.not_to permit(build(:local_authority_user), build(:scl_provision)) }
  end
end
