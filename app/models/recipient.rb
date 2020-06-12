class Recipient < ApplicationRecord
  belongs_to :mobile_network

  enum status: {
    requested:   'requested',
    in_progress: 'in_progress',
    queried:     'queried',
    complete:    'complete',
    cancelled:   'cancelled',
  } 
end
