# == Schema Information
#
# Table name: habits_tags
#
#  id         :bigint           not null, primary key
#  color      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_habits_tags_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Habits::Tag < ApplicationRecord
  belongs_to :user

  has_many :item_tags, class_name: "Habits::ItemTag", dependent: :destroy
  has_many :items, through: :item_tags, class_name: "Habits::Item"
end
