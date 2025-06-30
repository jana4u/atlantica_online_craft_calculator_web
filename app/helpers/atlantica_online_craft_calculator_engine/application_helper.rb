# -*- encoding : utf-8 -*-
module AtlanticaOnlineCraftCalculatorEngine
  module ApplicationHelper
    def link_to_url(url, *args, &block)
      link_to(url, url, *args, &block)
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
        'Your price'
      else
        item.price_type.to_s.humanize
      end
    end

    def skill_names
      AtlanticaOnlineCraftCalculator::Item.ordered_item_skills
    end

    def filter_items_by_query(items, query)
      return items if query.blank?
      items.select { |item| item.name.match(Regexp.new(query, true)) }
    end

    def item_names(query)
      items = AtlanticaOnlineCraftCalculator::Item.ordered_craftable_items
      return filter_items_by_query(items, query).map { |i| i.name }
    end

    def item_names_for_skill(skill, query)
      items = AtlanticaOnlineCraftCalculator::Item.craftable_items_for_skill_ordered_by_skill_lvl(skill)
      return filter_items_by_query(items, query).map { |i| ["#{i.name} – #{i.skill_lvl}", i.name] }
    end

    def item_names_for_skill_or_all(skill, query)
      if skill.blank?
        item_names(query)
      else
        item_names_for_skill(skill, query)
      end
    end

    def items_select_tag
      select_tag(:item_name, options_for_select(item_names_for_skill_or_all(params[:skill], params[:query]), params[:item_name]), :include_blank => true, :id => :item_name)
    end

    def zero_price?(item, custom_price)
      if custom_price
        return true if custom_price.zero?
      else
        return true if item.unit_price.zero?
      end

      return false
    end
  end
end
