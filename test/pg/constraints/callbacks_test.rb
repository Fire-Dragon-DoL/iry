class CallbacksTest < Minitest::Test
  def test_sql_usable_after_constraint_violation
    user = User.create!(unique_text: SecureRandom.uuid)
    sql_usable_after_constraint_violation = true
    fail_user = User.new(unique_text: user.unique_text)

    begin
      Iry.save(fail_user)
      some_user_after_sql = User.create!(unique_text: SecureRandom.uuid)
    rescue ActiveRecord::StatementInvalid
      sql_usable_after_constraint_violation = false
    end

    refute { some_user_after_sql.nil? }
    assert { some_user_after_sql.persisted? }
    assert { sql_usable_after_constraint_violation == true }
  end
end
