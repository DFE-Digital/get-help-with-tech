FactoryBot.define do
  factory :email_audit do
    template { SecureRandom.uuid }
    school
    user factory: :school_user
    email_address { user.email_address }
    message_type { %i[user_can_order user_can_order_but_action_needed nudge_rb_to_add_school_contact].sample }
  end
end
