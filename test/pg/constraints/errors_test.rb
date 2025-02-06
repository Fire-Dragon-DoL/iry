class ErrorsTest < Minitest::Test
  def test_errors_with_save
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)

    Iry.save(fail_user)

    assert { user.unique_text == fail_user.unique_text }
    assert { fail_user.errors.details.fetch(:unique_text) == [{error: :taken}] }
  end
end
