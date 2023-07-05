# class CheckConstraintTest < Minitest::Test
#   def test_main
#     user = User.create(unique_text: "invalid")
#     binding.pry

#     assert { user.errors.details.fetch(:unique_text) == [{error: :not_unique}] }
#   end
# end
