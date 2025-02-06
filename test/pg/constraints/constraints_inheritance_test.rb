class ConstraintsInheritanceTest < Minitest::Test
  def test_no_constraints_shared_when_nothing_set
    user_ct_names = Set.new(User.constraints.keys)
    other_user_ct_names = Set.new(OtherUser.constraints.keys)

    refute { user_ct_names.intersect?(other_user_ct_names) }
  end

  def test_constraints_when_inheriting
    inheriting_user_ct_names = Set.new(InheritingUser.constraints.keys)
    other_user_ct_names = Set.new(OtherUser.constraints.keys)

    assert { other_user_ct_names.intersect?(inheriting_user_ct_names) }
  end

  def test_application_record_no_constraints
    assert { ApplicationRecord.constraints.empty? }
  end
end
