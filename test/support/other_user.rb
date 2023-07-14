class OtherUser < ApplicationRecord
  self.table_name = "users"

  unique_constraint :untracked_text
end
