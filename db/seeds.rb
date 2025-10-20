# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

require 'faker'

puts 'Seeding database with test data...'

def hash_password(password)
  BCrypt::Password.create(password)
end


# Create a system user for shared lists
system_user = User.find_or_create_by!(email: 'system@habittracker.com') do |u|
  u.password = hash_password('systempassword')
  u.first_name = 'System'
  u.last_name = 'User'
end

users = [
  { email: 'alice@example.com', password: hash_password(Faker::Internet.password(min_length: 8)) },
  { email: 'bob@example.com', password: hash_password(Faker::Internet.password(min_length: 8)) },
  { email: 'carol@example.com', password: hash_password(Faker::Internet.password(min_length: 8)) }
]

user_records = users.map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.password = attrs[:password]
  end
end

tag_names = [
  { name: 'Fitness', color: '#4CAF50', shared: true },
  { name: 'Health', color: '#F44336', shared: true },
  { name: 'Work', color: '#2196F3', shared: true },
  { name: 'Morning Routine', color: '#FFC107', shared: true },
  { name: 'Reading', color: '#9C27B0', shared: true },
  { name: 'Mindfulness', color: '#00BCD4', shared: true },
  { name: 'Productivity', color: '#FF9800', shared: true }
]

tags = tag_names.map do |t|
  Habits::Tag.find_or_create_by!(name: t[:name]) do |tag|
    tag.color = t[:color]
    tag.shared = t[:shared]
  end
end


# Shared list templates
list_templates = [
  { name: 'Morning Routine', description: 'Start your day right with these habits.' },
  { name: 'Fitness', description: 'Daily fitness and exercise habits.' },
  { name: 'Work Tasks', description: 'Stay productive at work.' },
  { name: 'Wellness', description: 'Habits for a healthy mind and body.' }
]

# Create shared lists for the system user
shared_lists = list_templates.map do |lt|
  Habits::List.find_or_create_by!(user: system_user, name: lt[:name]) do |list|
    list.description = lt[:description]
  end
end

habit_items = [
  { name: 'Drink Water', tags: [ 'Health', 'Morning Routine' ], data: { target_value: 1, target_unit: 'liter', duration_minutes: 0 } },
  { name: 'Meditate', tags: [ 'Mindfulness', 'Morning Routine' ], data: { target_value: 10, target_unit: 'minutes', duration_minutes: 10 } },
  { name: 'Read Book', tags: [ 'Reading', 'Productivity' ], data: { target_value: 20, target_unit: 'pages', duration_minutes: 30 } },
  { name: 'Push Ups', tags: [ 'Fitness' ], data: { target_value: 20, target_unit: 'reps', duration_minutes: 5 } },
  { name: 'Check Emails', tags: [ 'Work', 'Productivity' ], data: { target_value: 1, target_unit: 'session', duration_minutes: 15 } },
  { name: 'Walk', tags: [ 'Fitness', 'Health' ], data: { target_value: 30, target_unit: 'minutes', duration_minutes: 30 } },
  { name: 'Plan Day', tags: [ 'Productivity', 'Morning Routine' ], data: { target_value: 1, target_unit: 'session', duration_minutes: 10 } }
]


user_records.each do |user|
  lists = list_templates.map do |lt|
    Habits::List.find_or_create_by!(user: user, name: lt[:name]) do |list|
      list.description = lt[:description]
    end
  end

  lists.each do |list|
    # Add a random selection of items to each list
    habit_items.sample(3).each do |item_template|
      item = list.items.create!(
        name: item_template[:name],
        item_type: 'habit',
        frequency: %w[daily weekly].sample,
        data: item_template[:data],
        due_on: Date.today + rand(1..7).days
      )
      # Tag the item
      item_template[:tags].each do |tag_name|
        tag = tags.find { |t| t.name == tag_name }
        Habits::ItemTag.create!(item: item, tag: tag) if tag
      end
    end
  end
end

puts 'Seeding complete!'
