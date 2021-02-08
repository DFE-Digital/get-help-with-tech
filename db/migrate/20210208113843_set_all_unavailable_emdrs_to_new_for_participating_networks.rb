class SetAllUnavailableEmdrsToNewForParticipatingNetworks < ActiveRecord::Migration[6.1]
  def up
    reqs = ExtraMobileDataRequest.joins(:mobile_network)
                                 .where.not(mobile_network: { brand: 'Three' })
                                 .where(status: 'unavailable')
                                 .where(mobile_network: { participation_in_pilot: 'participating' })
    # we're updating each one individually rather than in bulk,
    # so that we get a PaperTrail record for each
    reqs.each do |req|
      req.update(status: 'new')
    end
  end

  def down
    # no-op
  end
end
