class ConstraintsTest < Minitest::Test
  def test_no_constraint
    user = User.create!(unique_text: SecureRandom.uuid)

    assert { user.errors.empty? }
  end

  def test_unique
    user = User.create!(unique_text: SecureRandom.uuid)

    fail_user = User.create(unique_text: user.unique_text)

    assert { user.unique_text == fail_user.unique_text }
    assert { fail_user.errors.details.fetch(:unique_text) == [{error: :taken}] }
  end

  # def test_check
  #   user = User.create(unique_text: "invalid")

  #   assert { user.errors.details.fetch(:unique_text) == [{error: :taken}] }
  # end

  # def test_exclude
  #   user = User.create!(exclude_text: SecureRandom.uuid)

  #   fail_user = User.create(exclude_text: user.exclude_text)

  #   assert { user.exclude_text == fail_user.exclude_text }
  #   assert { fail_user.errors.details.fetch(:exclude_text) == [{error: :taken}] }
  # end

  # def test_foreign_key
  #   user = User.create(user_id: SecureRandom.uuid)

  #   assert { user.errors.details.fetch(:exclude_text) == [{error: :taken}] }
  # end
end
