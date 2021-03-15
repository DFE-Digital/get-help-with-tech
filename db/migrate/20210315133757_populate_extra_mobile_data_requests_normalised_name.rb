class PopulateExtraMobileDataRequestsNormalisedName < ActiveRecord::Migration[6.1]
  def change
    ExtraMobileDataRequest.find_each do |record|
      record.update!(normalised_name: record.normalise_name)
    end
  end
end
