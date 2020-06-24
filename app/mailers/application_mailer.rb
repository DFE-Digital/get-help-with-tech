class ApplicationMailer < Mail::Notify::Mailer
  default from: 'from@example.com'
  layout 'mailer'

private

  def url(named_route, *args)
    url_helper.send(named_route.to_sym, Rails.configuration.action_mailer.default_url_options.merge(*args))
  end

  def url_helper
    Rails.application.routes.url_helpers
  end
end
