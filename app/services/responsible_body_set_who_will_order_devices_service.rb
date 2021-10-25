class ResponsibleBodySetWhoWillOrderDevicesService
  attr_reader :clear_preorder_information, :responsible_body, :who

  def initialize(responsible_body, who)
    @responsible_body = responsible_body
    @who = who
  end

  def call
    set_who_will_order_devices!
  rescue StandardError => e
    failed(e)
  end

private

  def set_who_will_order_devices!
    responsible_body.update!(who_will_order_devices: who)
    responsible_body.active_schools.each do |school|
      SchoolSetWhoManagesOrdersService.new(school,
                                           who,
                                           clear_preorder_information: true,
                                           recalculate_vcaps: false,
                                           notify: responsible_body.orders_managed_by_schools?).call
    end
    responsible_body.calculate_virtual_caps! if responsible_body.orders_managed_centrally?
    true
  end

  def failed(e)
    log_error(e)
    false
  end

  def log_error(e)
    responsible_body.errors.add(:base, e.message)
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end
end
