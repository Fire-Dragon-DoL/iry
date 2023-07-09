class HandleConstraintsTest < Minitest::Test
  def test_handle_constraints_return_nil_on_error
    user = User.create!(unique_text: SecureRandom.uuid)
    fail_user = User.new(unique_text: user.unique_text)

    result = Iry.handle_constraints(fail_user) { fail_user.save }

    assert { result.nil? }
  end

  def test_handle_constraints_return_model_on_success
    user = User.new(unique_text: SecureRandom.uuid)

    result = Iry.handle_constraints(user) { user.save }

    assert { result.object_id == user.object_id }
  end
end
