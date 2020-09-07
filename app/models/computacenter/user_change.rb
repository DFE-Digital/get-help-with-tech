class Computacenter::UserChange < ApplicationRecord
  self.table_name = 'computacenter_user_changes'

  enum type_of_update: { New: 0, Change: 1, Remove: 2 }
end
