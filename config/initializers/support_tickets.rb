Rails.configuration.support_tickets = YAML.load_file(Rails.root.join('config/support_tickets.yml')).deep_symbolize_keys
