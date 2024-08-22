class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if params[:query].present?
      @workouts = Workout.search_by(params[:query])
      @exer
    else
      @workouts = Workout.all
    end
    @workout_sess = WorkoutSession.new
  end

  def calendar

  end

end
