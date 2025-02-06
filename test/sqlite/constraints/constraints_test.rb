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

  def test_unique
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)

    Iry.save(fail_user)

    assert { user.unique_text == fail_user.unique_text }
    assert { fail_user.errors.details.fetch(:unique_text) == [{error: :taken}] }
  end

  def test_unique_two_columns
    user = User.create!(
      unique_text: SecureRandom.uuid,
      untracked_text: SecureRandom.uuid
    )
    fail_user = User.new(
      unique_text: user.unique_text,
      untracked_text: user.untracked_text
    )

    Iry.save(fail_user)

    assert { user.unique_text == fail_user.unique_text }
    assert { user.untracked_text == fail_user.untracked_text }
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

    assert { constraint_err.cause.is_a?(SQLite3::ConstraintException) }
  end
end
