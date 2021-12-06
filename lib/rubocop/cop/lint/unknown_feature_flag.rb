require 'rubocop'
require_relative '../../../../app/services/feature_flag'

module RuboCop
  module Cop
    module Lint
      # Check if the code still references deleted feature flags.
      #
      # @example
      #   # good
      #   FeatureFlag::FEATURES = [:display_sign_in_token_links, :rate_limiting]
      #
      #   if FeatureFlag.active?(:display_sign_in_token_links)
      #      user = User.find_by(email_address: @token_form.email_address)
      #      identifier = user.sign_in_identifier(user.sign_in_token)
      #      flash[:sign_in] = "<a href='#{token_url}'>Click to sign-in</a>"
      #   end
      #
      #   # bad
      #   FeatureFlag::FEATURES = [:rate_limiting]
      #
      #   if FeatureFlag.active?(:display_sign_in_token_links)
      #      user = User.find_by(email_address: @token_form.email_address)
      #      identifier = user.sign_in_identifier(user.sign_in_token)
      #      flash[:sign_in] = "<a href='#{token_url}'>Click to sign-in</a>"
      #   end
      class UnknownFeatureFlag < RuboCop::Cop::Cop
        FEATURE_FLAGS = FeatureFlag::FEATURES
        MSG = 'Unknown feature flag `%<flag>s`'.freeze
        NODE_PATTERN = '(send (const nil? :FeatureFlag) {:active? | :inactive?} (sym $_))'.freeze
        RESTRICT_ON_SEND = %i[active? inactive?].freeze

        def_node_matcher :on_feature_flag, NODE_PATTERN

        def on_send(node)
          on_feature_flag(node) do |flag|
            add_offense(node, message: error_message(flag)) unless FEATURE_FLAGS.include?(flag.to_sym)
          end
        end

      private

        def error_message(flag)
          sprintf(MSG, flag: flag)
        end
      end
    end
  end
end
