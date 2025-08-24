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
class Habits::List < ApplicationRecord
  belongs_to :user

  has_many :items, class_name: "Habits::Item", dependent: :destroy
end
