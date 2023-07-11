class SaveTest < Minitest::Test
  def test_transaction_last_line_no_exceptions
    user = User.create!(unique_text: SecureRandom.uuid)
    other_user = User.new(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)

    User.transaction do
      Iry.save(other_user)
      Iry.save(fail_user)
    end

    assert { fail_user.errors.details.fetch(:unique_text) == [{error: :taken}] }
    assert { other_user.persisted? }
  end

  def test_transaction_next_line_execution_fails
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)
    other_user = User.new(unique_text: SecureRandom.uuid)
    transaction_err = false

    begin
      User.transaction do
        Iry.save(fail_user)
        Iry.save(other_user)
      end

    rescue ActiveRecord::StatementInvalid => err
      transaction_err = err
    end

    assert { transaction_err.cause.is_a?(PG::InFailedSqlTransaction) }
    refute { other_user.persisted? }
  end

  def test_normal_transaction_halted
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)
    other_user = User.new(unique_text: SecureRandom.uuid)
    unique_err_raised = false

    begin
      User.transaction do
        fail_user.save
        other_user.save
      end
    rescue ActiveRecord::RecordNotUnique
      unique_err_raised = true
    end

    assert { unique_err_raised == true }
    refute { other_user.persisted? }
  end

  def test_true_on_success
    user = User.new(unique_text: SecureRandom.uuid)

    result = Iry.save(user)

    assert { result == true }
    assert { user.persisted? }
  end

  def test_false_on_validation_error
    user = User.new(free_text: "[")

    result = Iry.save(user)

    assert { result == false }
    assert { user.errors.details.dig(:free_text, 0, :error) == :invalid }
  end

  def test_false_on_constraint_violation
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)

    result = Iry.save(fail_user)

    assert { result == false }
    assert { fail_user.errors.details.dig(:unique_text, 0, :error) == :taken }
  end
end
