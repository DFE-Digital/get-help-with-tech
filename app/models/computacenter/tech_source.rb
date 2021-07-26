class Computacenter::TechSource
  def supplier_outages
    SupplierOutage.all # for now Computacenter's TechSource is the only supplier
  end

  def url
    Settings.computacenter.techsource_url
  end

  def available?
    !SupplierOutage.current.exists?
  end

  def current_supplier_outage
    outages = SupplierOutage.current
    outages.none? ? nil : any_current_outage(outages)
  end

private

  # we shouldn't really get overlapping outages
  def any_current_outage(outages)
    outages.first
  end
end
