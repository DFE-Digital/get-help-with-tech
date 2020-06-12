class Mno::RecipientsForm
  include ActiveModel::Model

  attr_accessor :recipients, :recipient_ids, :action

  def recipients_for_collection_select
    @recipients.map do |r|
      OpenStruct.new(id: r.id, label: '')
    end
  end
end
