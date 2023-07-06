class MacrosTest < Minitest::Test
  def test_macros_fail_with_duplicate
    assert_raises(ArgumentError) do
      Class.new(ActiveRecord::Base) do
        include(Iry)
        self.table_name = "users"

        unique_constraint(:unique_text)
        unique_constraint(:unique_text)
      end
    end
  end
end
