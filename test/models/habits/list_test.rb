# == Schema Information
#
# Table name: habits_lists
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  description :text
#  name        :string           not null
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_habits_lists_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class Habits::ListTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
