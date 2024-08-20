# require "open-uri"
# require "nokogiri"
require "faker"
require "roo"

puts " "
puts "Cleaning the DB..."
ExerciseAssignment.destroy_all
User.destroy_all
Exercise.destroy_all
Workout.destroy_all


puts " "
puts "Creating users accounts for Chae, Ryo and Nick..."

User.create!(
  email: "nk.matsumoto@gmail.com",
  password: "password",
  username: "nkmatsumoto"
)

User.create!(
  email: "chaewanshin@gmail.com",
  password: "password",
  username: "chaewanshin"
)
User.create!(
  email: "stuntpad@gmail.com",
  password: "password",
  username: "stuntpad"
)

user_count = 10
puts " "
puts "Creating #{user_count} random users..."

user_count.times do
  User.create(
    email: Faker::Internet.unique.email,
    password: Faker::Internet.password(min_length: 8),
    username: Faker::Internet.unique.username
  )
end


puts " "
puts "Creating workouts, exercises and exercise assignments ... "
xlsx = Roo::Excelx.new('./db/data/Calisthenics Skills.xlsx')

# Reading data from the first sheet
puts " "
puts "Parsing spreadsheet data  ... "
xlsx.sheet('Skills Workout').parse do |row|
  next if row[1..6].all?(nil)
  # Access the cell data with row[cell_index]
  p row[1..6] # Example: Print the value of the first cell
  if row[1] == "T"
    # create workout
    workout = Workout.new(
      name: row[6].gsub(/<\/?[^>]+>/, ""),
      category: row[3],
    )
    workout.save
    puts " "
    puts " ----------------------------------- "
    puts " Created new workout: #{workout.name} "
    puts " ----------------------------------- "
    puts " "
    # p workout.errors
  else
    # create exercise
    if row[5].end_with?("s")
      upper_reps = nil
      lower_reps = nil
    else
      reps_array = row[5]&.split('-')
      upper_reps = reps_array.nil? && reps_array.size >= 2 ? nil : reps_array[1].to_i
      lower_reps = reps_array.nil? && reps_array.size >= 2 ? nil : reps_array[0].to_i
    end

    hold_time = row[5].end_with?("s") ? row[5][0..-1].to_i : nil

    exercise = Exercise.new(
    name: row[6],
    upper_reps: upper_reps,
    lower_reps: lower_reps,
    reps: lower_reps,
    sets: row[4],
    hold_time: hold_time,
    duration: nil,
    rest: row[2].to_i,
    tempo: row[1].to_s,
    category: nil,
    exercise_type: row[3],
    progression_difficulty: nil,
    progression_name: nil
    )
    exercise.save!
    # create exercise assignment
    assignment = ExerciseAssignment.new(
      workout_id: Workout.last.id,
      exercise_id: Exercise.last.id
    )
    assignment.save
    puts "Created #{exercise.name} and added to #{assignment.workout.name}... "
    puts " "
  end


end

puts " "
puts "Created: #{User.all.count} users, #{Workout.all.count} workouts, #{Exercise.all.count} exercises and #{ExerciseAssignment.all.count} exercise assignments"

workout_session = WorkoutSession.create(
  user: User.first,
  workout: Workout.first,
  bodyweight: 70.0,
  sleep_time: 7 * 60,
)
