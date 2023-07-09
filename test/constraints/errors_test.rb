class ErrorsTest < Minitest::Test
  def test_errors_with_save
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)

    Iry.save(fail_user)

    assert { user.unique_text == fail_user.unique_text }
    assert { fail_user.errors.details.fetch(:unique_text) == [{error: :taken}] }
  end

  def test_raises_with_bang
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)
    record_errors = nil

    begin
      Iry.save!(fail_user)
    rescue Iry::RecordInvalid => err
      record_errors = err.record.errors
    end

    assert { record_errors.details.fetch(:unique_text) == [{error: :taken}] }
  end
end
