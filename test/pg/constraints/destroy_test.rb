class DestroyTest < Minitest::Test
  def test_destroy_halted_constraint_error
    existing_text = SecureRandom.uuid
    deleting_user = User.create!(unique_text: existing_text)
    User.create!(friend_user: deleting_user)

    success = Iry.destroy(deleting_user)

    refute { success }
    assert { deleting_user.errors.details.dig(:friend_user, 0, :error) == :required }
  end

  def test_destroy_successful_when_no_error
    deleting_user = User.create!(unique_text: SecureRandom.uuid)

    model = Iry.destroy(deleting_user)

    refute { model.nil? }
    refute { model.persisted? }
  end
end
