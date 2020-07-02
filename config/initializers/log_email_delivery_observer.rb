# This line is a little odd, but prevents a deprecation warning on startup
# about autoloading constants during initialization
require_relative '../../app/mailers/log_email_delivery_observer'

ActionMailer::Base.register_observer(LogEmailDeliveryObserver)
