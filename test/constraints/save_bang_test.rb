class SaveBangTest < Minitest::Test
  def test_raises_with_bang
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)
    record_errors = nil

    begin
      Iry.save!(fail_user)
    rescue Iry::ConstraintViolation => err
      record_errors = err.record.errors
    end

    assert { record_errors.details.fetch(:unique_text) == [{error: :taken}] }
  end

  def test_true_on_success
    user = User.new(unique_text: SecureRandom.uuid)
    result = nil

    result = Iry.save!(user)

    assert { result == true }
  end
end
