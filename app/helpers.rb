# encoding: UTF-8

# Helper methods defined here can be accessed in any controller or view in the application

CraftCalculator.helpers do
  include CycleHelper

  def cycle_table_row_colors
    cycle("light", "dark")
  end

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

  def skill_names
    AtlanticaOnlineCraftCalculator::Item.ordered_item_skills
  end

  def item_names
    AtlanticaOnlineCraftCalculator::Item.ordered_craftable_items.map{ |i| i.name }
  end

  def item_names_for_skill(skill)
    AtlanticaOnlineCraftCalculator::Item.craftable_items_for_skill_ordered_by_skill_lvl(skill).map{ |i| [ "#{i.name} – #{i.skill_lvl}", i.name ] }
  end

  def item_names_for_skill_or_all(skill)
    if skill.blank?
      item_names
    else
      item_names_for_skill(skill)
    end
  end

  def items_select_tag
    select_tag(:item_name, :options => item_names_for_skill_or_all(params[:skill]), :selected => params[:item_name], :include_blank => "", :id => :item_name)
  end

  def item_custom_prices_url
    url(:"custom-prices", :item_name => params[:item_name])
  end

  def zero_price?(item, custom_price)
    if custom_price
      return true if custom_price.zero?
    else
      return true if item.unit_price.zero?
    end

    return false
  end

  # def simple_helper_method
  #  ...
  # end
end
