require "securerandom"

class User < ApplicationRecord
  unique_constraint :unique_text
  unique_constraint [:unique_text, :untracked_text]
  check_constraint :unique_text

  after_initialize do
    self.unique_text ||= SecureRandom.uuid
    self.exclude_text ||= SecureRandom.uuid
    self.untracked_text ||= SecureRandom.uuid
  end
end
