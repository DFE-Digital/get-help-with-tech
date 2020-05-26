module InlineUser
  extend ActiveSupport::Concern

  included do
    attr_accessor :user_id, :user_name, :user_email, :user_organisation
    validates :user_name, presence: { message: 'Please tell us your full name, for example Jane Doe' }
    validates :user_email, presence: { message: 'Please tell us your email address, for example j.doe@example.com' }
    validates :user_organisation, presence: { message: 'Please tell us the organisation you work for, for example Lambeth Council' }

    private

    def construct_user
      User.new(full_name: @user_name, email_address: @user_email, organisation: @user_organisation)
    end

    def populate_from_user!
      @user_id = @user.id
      @user_name = @user.full_name
      @user_email = @user.email_address
      @user_organisation = @user.organisation
    end
  end
end
