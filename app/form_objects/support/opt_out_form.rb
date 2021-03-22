class Support::OptOutForm
  include ActiveModel::Model

  attr_accessor :school

  def opt_out
    !!school.opted_out_of_comms_at ? 1 : 0
  end
end
