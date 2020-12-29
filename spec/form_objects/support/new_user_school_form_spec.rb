require 'rails_helper'

RSpec.describe Support::NewUserSchoolForm, type: :model do
  it { is_expected.to validate_length_of(:name_or_urn).is_at_least(3) }
end
