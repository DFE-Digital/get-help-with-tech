class LogStashFormatter < SemanticLogger::Formatters::Raw
  def format_add_type
    hash[:type] = 'rails'
  end

  # Tidy up how the context field is presented for Sidekiq payloads.
  def format_sidekiq_json_message_context
    if hash[:message].present?
      context = JSON.parse(hash[:message])['context']
      hash[:sidekiq_job_context] = hash[:message]
      hash[:message] = context
    end
  rescue JSON::ParserError
    nil
  end

  # Place a more readable version of the exception into the message field.
  # Otherwise we can get a dump of the entire payload in this field in some
  # circumstances. Messy.
  def format_exception
    exception_message = hash.dig(:exception, :message)
    if exception_message.present?
      hash[:message] = "Exception occured: #{exception_message}"
    end
  end

  # Some payloads place the backtrace into the message field. This is messy and
  # unreadable, so place these into a field named 'backtrace'.
  def format_backtrace
    if hash[:message]&.start_with?('/')
      message_lines = hash[:message].split("\n")
      if message_lines.all? { |line| line.start_with?('/') }
        hash[:backtrace] = hash[:message]
        hash[:message] = "Exception occured: #{message_lines.first}"
      end
    end
  end

  # The value here appears to break logging to logstash / elasticsearch
  def format_duration
    hash[:duration] = hash[:duration_ms]
    hash[:duration_ms] = nil
  end

  # Add extra info for ActiveJob payloads.
  def format_job_data
    hash[:job_id] = RequestStore.store[:job_id] if RequestStore.store[:job_id].present?
    hash[:job_queue] = RequestStore.store[:job_queue] if RequestStore.store[:job_queue].present?
  end

  def call(log, logger)
    super(log, logger)

    format_add_type

    # Not using ActiveJob, enable if needed.
    # format_job_data

    format_duration
    format_exception

    # Not using Sidekiq, enable if needed.
    # format_sidekiq_json_message_context

    format_backtrace

    hash.to_json
  end
end

if Settings.logstash.host && Settings.logstash.port
  warn('logstash configured, sending logs there')

  # For some reason logstash / elasticsearch drops events where the payload
  # is a hash. These are more conveniently accessed at the top level of the
  # event, anyway, so we move it there.
  fix_payload = proc do |event|
    if event['payload'].present?
      event.append(event['payload'])
      event['payload'] = nil
    end
  end

  log_stash = LogStashLogger.new(Settings.logstash.to_h.merge(customize_event: fix_payload))
  SemanticLogger.add_appender(logger: log_stash, level: :info, formatter: LogStashFormatter.new)
end
