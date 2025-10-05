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
class Habits::Tag < ApplicationRecord
  has_many :item_tags, class_name: "Habits::ItemTag", dependent: :destroy
  has_many :items, through: :item_tags, class_name: "Habits::Item"
end
