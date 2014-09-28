User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
  puts "created user no. #{n+1}"
end

# Microposts
users = User.take(6)
500.times do |n|
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
  puts "created m-p no. #{n+1} of 500"
end

# Following relationships
users = User.all
user  = users.first
following = users[2..50]
followers = users[3..40]
following.each do |followed|
  user.follow(followed)
  puts "now follow user #{followed}"
end
followers.each { |follower| follower.follow(user) }
