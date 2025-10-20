# == Schema Information
#
# Table name: habits_items
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  data        :jsonb            not null
#  days_mask   :integer
#  due_on      :datetime
#  frequency   :integer          default("daily"), not null
#  item_type   :integer          default("habit"), not null
#  name        :string           not null
#  position    :integer
#  status      :integer          default("draft"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  list_id     :bigint           not null
#
# Indexes
#
#  index_habits_items_on_list_id  (list_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => habits_lists.id)
#
require "test_helper"

class Habits::ItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
