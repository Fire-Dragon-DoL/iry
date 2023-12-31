class ConstraintsTest < Minitest::Test
  def test_no_constraint
    user = User.new(unique_text: SecureRandom.uuid)

    Iry.save!(user)

    assert { user.errors.empty? }
  end

  def test_check
    user = User.new(unique_text: "invalid")

    Iry.save(user)

    assert { user.errors.details.fetch(:unique_text) == [{error: :invalid}] }
  end

  def test_exclusion
    user = User.create!(exclude_text: SecureRandom.uuid)
    fail_user = User.new(exclude_text: user.exclude_text)

    Iry.save(fail_user)

    assert { user.exclude_text == fail_user.exclude_text }
    assert { fail_user.errors.details.fetch(:exclude_text) == [{error: :taken}] }
  end

  def test_foreign_key
    user = User.new(user_id: SecureRandom.uuid)

    Iry.save(user)

    assert { user.errors.details.fetch(:user_id) == [{error: :required}] }
  end

  def test_foreign_key_on_association
    user = User.new(friend_user_id: SecureRandom.uuid)

    Iry.save(user)

    assert { user.errors.details.fetch(:friend_user) == [{error: :required}] }
  end

  def test_unique
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)

    Iry.save(fail_user)

    assert { user.unique_text == fail_user.unique_text }
    assert { fail_user.errors.details.fetch(:unique_text) == [{error: :taken}] }
  end

  def test_untracked_constraint
    user = User.create!(untracked_text: SecureRandom.uuid)
    constraint_err = nil

    begin
      User.create(untracked_text: user.untracked_text)
    rescue ActiveRecord::StatementInvalid => err
      constraint_err = err
    end

    assert { constraint_err.cause.is_a?(PG::UniqueViolation) }
  end
end
