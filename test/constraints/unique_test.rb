class UniqueConstraintTest < Minitest::Test
  def test_main
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.create(unique_text: user.unique_text)

    assert { user.unique_text == fail_user.unique_text }
    assert { fail_user.errors.details.fetch(:unique_text) == [{error: :not_unique}] }
  end
end
