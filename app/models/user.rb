# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  uid                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid                   (uid)
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :habits_lists, class_name: "Habits::List", dependent: :destroy
  has_many :habit_items, through: :habits_lists, source: :items

  after_commit :create_default_habits_list, on: :create

  def self.create_from_provider_data(provider_data)
    where(provider: provider_data.provider, uid: provider_data.uid).first_or_create do |user|
      user.email = provider_data.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def self.system_user
    find_by(email: 'system@habittracker.com')
  end

  def full_name
    [ first_name, last_name ].compact.join(" ")
  end


  def default_list
    habits_lists.find_by(name: Habits::List::DEFAULT_LIST[:name])
  end

  private

  def create_default_habits_list
    habits_lists.create(name: Habits::List::DEFAULT_LIST[:name], description: Habits::List::DEFAULT_LIST[:description])
  end
end
