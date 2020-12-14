class Support::UserResponsibleBodyForm
  include ActiveModel::Model

  attr_accessor :user

  def initialize(user:, possible_responsible_bodies: nil)
    @user = user
    @possible_responsible_bodies = possible_responsible_bodies
  end

  def responsible_body
    @user.responsible_body&.id
  end

  def select_responsible_body_options
    @possible_responsible_bodies.pluck(:id, :name).map do |id, name|
      OpenStruct.new(id: id, name: name)
    end
  end
end
