class NestedAttributesCreateTest < Minitest::Test
  def test_create_with_nested_attributes_without_errors_succeeds
    params = {
      unique_text: SecureRandom.uuid,
      friend_users_attributes: [
        {unique_text: SecureRandom.uuid},
        {unique_text: SecureRandom.uuid}
      ]
    }
    user = User.new(params)

    Iry.save(user)

    assert { user.unique_text == params[:unique_text] }
    assert { user.friend_users[0].unique_text == params.dig(:friend_users_attributes, 0, :unique_text) }
    assert { user.friend_users[1].unique_text == params.dig(:friend_users_attributes, 1, :unique_text) }
  end

  def test_create_with_nested_attributes_errors_on_correct_model
    existing_text = SecureRandom.uuid
    User.create!(unique_text: existing_text)
    params = {
      unique_text: SecureRandom.uuid,
      friend_users_attributes: [
        {unique_text: SecureRandom.uuid},
        {unique_text: existing_text},
        {unique_text: SecureRandom.uuid}
      ]
    }
    user = User.new(params)

    Iry.save(user)

    # Params set
    assert { user.unique_text == params[:unique_text] }
    assert { user.friend_users[0].unique_text == params.dig(:friend_users_attributes, 0, :unique_text) }
    assert { user.friend_users[1].unique_text == params.dig(:friend_users_attributes, 1, :unique_text) }
    assert { user.friend_users[2].unique_text == params.dig(:friend_users_attributes, 2, :unique_text) }
    # Errors set on failug user
    assert { user.friend_users[1].errors.details.fetch(:unique_text) == [{error: :taken}] }
    assert { user.errors.empty? }
  end

  def test_create_with_nested_attributes_without_handling_constraints_unchanged
    existing_text = SecureRandom.uuid
    User.create!(unique_text: existing_text)
    params = {
      unique_text: SecureRandom.uuid,
      friend_users_attributes: [
        {unique_text: SecureRandom.uuid},
        {unique_text: existing_text},
        {unique_text: SecureRandom.uuid}
      ]
    }
    user = User.new(params)
    statement_invalid = nil

    begin
      user.save
    rescue Iry::StatementInvalid => err
      statement_invalid = err
    end

    refute { statement_invalid.nil? }
    assert { statement_invalid.is_a?(ActiveRecord::StatementInvalid) }
  end

  def test_create_with_nested_attributes_with_validation_errors_save_false
    existing_text = SecureRandom.uuid
    User.create!(unique_text: existing_text)
    params = {
      unique_text: SecureRandom.uuid,
      friend_users_attributes: [
        {unique_text: SecureRandom.uuid},
        {free_text: "["},
        {unique_text: SecureRandom.uuid}
      ]
    }
    user = User.new(params)
    save_result = nil

    save_result = user.save

    assert { save_result == false }
  end

  def test_save_bang_raises_validation_error
    existing_text = SecureRandom.uuid
    User.create!(unique_text: existing_text)
    params = {
      unique_text: SecureRandom.uuid,
      friend_users_attributes: [
        {unique_text: SecureRandom.uuid},
        {unique_text: existing_text},
        {unique_text: SecureRandom.uuid},
        {free_text: "["}
      ]
    }
    user = User.new(params)
    record_invalid = false

    begin
      user.save!
    rescue ActiveRecord::RecordInvalid
      record_invalid = true
    end

    assert { record_invalid }
  end

  def test_save_bang_with_no_validation_errors_raises_statement_invalid
    existing_text = SecureRandom.uuid
    User.create!(unique_text: existing_text)
    params = {
      unique_text: SecureRandom.uuid,
      friend_users_attributes: [
        {unique_text: SecureRandom.uuid},
        {unique_text: existing_text},
        {unique_text: SecureRandom.uuid}
      ]
    }
    user = User.new(params)
    statement_invalid = nil

    begin
      user.save!
    rescue Iry::StatementInvalid => err
      statement_invalid = err
    end

    refute { statement_invalid.nil? }
    assert { statement_invalid.is_a?(ActiveRecord::StatementInvalid) }
  end
end
