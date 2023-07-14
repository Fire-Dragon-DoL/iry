class InheritingUser < OtherUser
  self.table_name = "users"

  unique_constraint :unique_text
end
