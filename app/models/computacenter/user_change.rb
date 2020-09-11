module Computacenter
  class UserChange < ApplicationRecord
    self.table_name = 'computacenter_user_changes'

    enum type_of_update: { New: 0, Change: 1, Remove: 2 }

    def self.read_from_version(version)
      UserChangeGenerator.new(version).call
    end
  end
end
