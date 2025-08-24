# == Schema Information
#
# Table name: habits_item_tags
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  item_id    :bigint           not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_habits_item_tags_on_item_id             (item_id)
#  index_habits_item_tags_on_item_id_and_tag_id  (item_id,tag_id) UNIQUE
#  index_habits_item_tags_on_tag_id              (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => habits_items.id)
#  fk_rails_...  (tag_id => habits_tags.id)
#
class Habits::ItemTag < ApplicationRecord
  belongs_to :item, class_name: "Habits::Item"
  belongs_to :tag, class_name: "Habits::Tag"

  validates :item_id, uniqueness: { scope: :tag_id }
end
