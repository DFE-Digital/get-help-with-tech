require_relative '../../app/mailers/log_email_delivery_observer'

ActionMailer::Base.register_observer(LogEmailDeliveryObserver)
