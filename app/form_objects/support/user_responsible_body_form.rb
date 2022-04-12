class Support::UserResponsibleBodyForm
  include ActiveModel::Model

  attr_accessor :user, :change, :possible_responsible_bodies
  attr_writer :responsible_body_id

  def new_responsible_body_id
    case change
    when 'add', 'move' then responsible_body_id
    when 'remove' then nil
    else
      raise "Unexpected change #{change}"
    end
  end

  def responsible_body_id
    @responsible_body_id || @user.responsible_body&.id
  end

  def select_responsible_body_options
    @possible_responsible_bodies.pluck(:id, :name).map do |id, name|
      OpenStruct.new(id:, name:)
    end
  end
end
