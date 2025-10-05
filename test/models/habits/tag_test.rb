# == Schema Information
#
# Table name: habits_tags
#
#  id         :bigint           not null, primary key
#  color      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class Habits::TagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
