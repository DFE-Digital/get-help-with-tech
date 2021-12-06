require 'rails_helper'
require 'rubocop/cop/lint/unknown_feature_flag'

describe RuboCop::Cop::Lint::UnknownFeatureFlag, :config do
  subject(:cop) { described_class.new }

  context 'when the feature flag is not defined' do
    it 'registers an offense when code calls checks the feature flag is active' do
      expect_offense(<<~RUBY)
        FeatureFlag.active?(:no_existent_feature_flag)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unknown feature flag `no_existent_feature_flag`
      RUBY
    end

    it 'registers an offense when code calls checks the feature flag is inactive' do
      expect_offense(<<~RUBY)
        FeatureFlag.inactive?(:no_existent_feature_flag)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unknown feature flag `no_existent_feature_flag`
      RUBY
    end
  end

  context 'when the feature flag is defined' do
    it 'does not register an offense when the code checks the feature flag is active' do
      expect_no_offenses(<<~RUBY)
        FeatureFlag.active?(:gias_data_stage_pause)
      RUBY
    end

    it 'does not register an offense when the code checks the feature flag is inactive' do
      expect_no_offenses(<<~RUBY)
        FeatureFlag.inactive?(:gias_data_stage_pause)
      RUBY
    end
  end
end
