# Helper methods defined here can be accessed in any controller or view in the application

CraftCalculator.helpers do
  def link_to_url(url, *args, &block)
    link_to(url, url, args, &block)
  end

  def seconds_to_human(seconds)
    seconds = seconds.ceil
    hours = seconds / 3600
    mins = (seconds - 3600 * hours) / 60
    secs = seconds - 3600 * hours - 60 * mins
    "#{hours}h#{mins}m#{secs}s"
  end

  def price_type_to_human(item)
    if @custom_prices[item.name]
      "Your price"
    else
      item.price_type.to_s.humanize
    end
  end

  # def simple_helper_method
  #  ...
  # end
end
