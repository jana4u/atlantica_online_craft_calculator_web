# Helper methods defined here can be accessed in any controller or view in the application

CraftCalculator.helpers do
  def seconds_to_human(seconds)
    seconds = seconds.ceil
    hours = seconds / 3600
    mins = (seconds - 3600 * hours) / 60
    secs = seconds - 3600 * hours - 60 * mins
    "#{hours}h#{mins}m#{secs}s"
  end

  # def simple_helper_method
  #  ...
  # end
end
