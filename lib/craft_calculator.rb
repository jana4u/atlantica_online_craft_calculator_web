module AtlanticaOnline
  module CraftCalculator
    CRAFT_XP_TO_WORKLOAD_RATIO = 50

    class Item
      def self.load_data_from_yaml(custom_prices = {}, data_file = File.join(File.dirname(__FILE__), 'data.yml'))
        require 'yaml'

        yaml_data = YAML::load(File.open(data_file))

        custom_prices.each do |item_name, price|
          if yaml_data[item_name]
            yaml_data[item_name]["market_price"] = price
          end
        end

        self.all = yaml_data
      end

      def self.all=(hash)
        @@all = {}

        hash.each do |item_name, item_data|
          @@all[item_name] = new(item_data.merge({ "name" => item_name}))
        end
      end

      def self.all
        @@all || {}
      end

      def self.find(item_name)
        item = all[item_name]

        raise InvalidItem, "No item '#{item_name}' found" unless item

        return item
      end

      def self.items
        all.values
      end

      def self.ordered_items
        items.sort_by { |i| i.name_for_sort }
      end

      def self.ordered_craftable_items
        ordered_items.select{ |i| i.craftable? }
      end

      def self.remove_leftovers_from_lists(craft_list, shopping_list, leftovers)
        leftovers.each do |leftover|
          if leftover.more_than_batch? && (cl_item = craft_list.detect { |i| i.name == leftover.name })
            leftover.ingredient_list.each do |li|
              existing_leftover = leftovers.detect { |l| l.item == li.item }
              leftover_count = li.count * leftover.complete_batches_count
              if existing_leftover
                existing_leftover.count += leftover_count
              else
                leftovers << LeftoverList::Item.new(li.item, leftover_count)
              end
            end

            do_not_craft_count = leftover.complete_batches_count * leftover.batch_size
            cl_item.count -= do_not_craft_count
            leftover.count -= do_not_craft_count
          elsif sl_item = shopping_list.detect { |i| i.name == leftover.name }
            sl_item.count -= leftover.count
            leftover.count = 0
          end
        end

        leftovers = leftovers.reject { |l| l.count.zero? }

        while leftovers.detect { |l| l.more_than_batch? } do
          craft_list, shopping_list, leftovers = remove_leftovers_from_lists(craft_list, shopping_list, leftovers)
        end

        return craft_list, shopping_list, leftovers
      end

      def initialize(hash)
        @data = hash
      end

      [
        :name,
        :ingredients,
        :workload,
        :skill,
        :skill_lvl,
        :market_price,
        :fixed_price,
      ].each do |method_name|
        define_method method_name do
          @data[method_name.to_s]
        end
      end

      def name_for_sort
        name.gsub("[I]", "1").gsub("[II]", "2").gsub("[III]", "3").gsub("[IV]", "4").gsub("[V]", "5")
      end

      def batch_size
        @data["batch_size"] || 1
      end

      def craftable?
        !ingredients.nil?
      end

      def crafting_is_cheaper?
        craftable? && (!direct_price || craft_price < direct_price)
      end

      def crafting_is_more_expensive?
        craftable? && direct_price && craft_price > direct_price
      end

      def money_saved_by_crafting
        return nil if !craftable? || !direct_price
        direct_price - craft_price
      end

      def ingredient_list
        list = IngredientList::ItemArray.new

        ingredients.each do |ingredient_name, ingredient_count|
          list << IngredientList::Item.new(self.class.find(ingredient_name), ingredient_count)
        end

        return list
      end

      def item_with_raw_craft_tree(count)
        batches_count = batches_count(count)

        list = CraftTree::ItemArray.new

        if crafting_is_cheaper?
          ingredient_list.each do |ingredient|
            list << ingredient.item.item_with_raw_craft_tree(ingredient.count * batches_count)
          end
          item_count = crafted_count(count)
        else
          item_count = count
        end


        return CraftTree::Item.new(self, count, item_count, list)
      end

      def direct_price
        send(direct_price_type)
      end

      def batch_craft_price
        return @batch_craft_price if defined?(@batch_craft_price)

        if craftable?
          result = ingredient_list.total_price
        else
          result = nil
        end

        @batch_craft_price = result
      end

      def craft_price
        batch_craft_price / batch_size
      end

      def price_type
        if crafting_is_cheaper?
          :craft_price
        else
          direct_price_type
        end
      end

      def direct_price_type
        if market_price && (!fixed_price || market_price < fixed_price)
          :market_price
        else
          :fixed_price
        end
      end

      def unit_price
        return send(price_type)
      end

      def crafted_count(count)
        batches_count(count) * batch_size
      end

      def batches_count(count)
        (count / batch_size.to_f).ceil.to_i
      end

      def craft(count)
        craft_list, shopping_list, leftovers =
          self.class.remove_leftovers_from_lists(
          raw_craft_list(count),
          raw_shopping_list(count),
          raw_leftovers(count)
        )
      end

      def raw_craft_list(count)
        item_with_raw_craft_tree(count).ordered_craft_list
      end

      def raw_shopping_list(count)
        item_with_raw_craft_tree(count).shopping_list
      end

      def raw_leftovers(count)
        item_with_raw_craft_tree(count).leftovers.reverse
      end

      def craft_xp_gained_per_batch
        workload / CRAFT_XP_TO_WORKLOAD_RATIO
      end

      def craft_xp_gained_per_item
        craft_xp_gained_per_batch / batch_size.to_f
      end
    end

    module ListItem
      def self.included(base)
        base.send(:attr_accessor, :count)
        base.send(:attr_reader, :item)
        base.extend(ClassMethods)
        base.send(:delegated_methods, :name)
      end

      def initialize(item, count)
        @item = item
        @count = count
      end

      module ClassMethods
        def delegated_methods(*args)
          args.each do |method_name|
            define_method method_name do
              @item && @item.send(method_name)
            end
          end
        end
      end
    end

    module ShoppingList
      class Item
        include ListItem
        delegated_methods :unit_price

        def total_price
          count * unit_price
        end
      end

      class ItemArray < Array
        def total_price
          result = 0

          self.each do |i|
            result += i.total_price
          end

          return result
        end
      end
    end

    module IngredientList
      class Item < ShoppingList::Item
      end

      class ItemArray < ShoppingList::ItemArray
      end
    end

    module CraftList
      class Item
        include ListItem
        delegated_methods :ingredients, :batch_size, :workload, :skill

        def batches_count
          count / batch_size
        end
      end

      class ItemArray < Array
        def total_workload_per_skill
          result = Hash.new(0)

          self.each do |i|
            result[i.skill] += i.batches_count * i.workload
          end

          return result
        end

        def total_craft_xp_gained_per_skill
          result = {}

          total_workload_per_skill.each do |skill, skill_workload|
            result[skill] = skill_workload / CRAFT_XP_TO_WORKLOAD_RATIO
          end

          return result
        end

        def total_workload
          result = 0

          self.each do |i|
            result += i.batches_count * i.workload
          end

          return result
        end

        def total_craft_xp_gained
          total_workload / CRAFT_XP_TO_WORKLOAD_RATIO
        end
      end
    end

    module LeftoverList
      class Item
        include ListItem
        delegated_methods :ingredients, :batch_size, :ingredient_list

        def complete_batches_count
          (count / batch_size.to_f).floor.to_i
        end

        def more_than_batch?
          complete_batches_count > 0
        end
      end

      class ItemArray < Array
      end
    end

    module CraftTree
      class Item
        include ListItem
        delegated_methods :unit_price
        attr_reader :crafted_count, :ingredients_craft_tree

        def initialize(item, count, crafted_count, ingredients_craft_tree)
          @item = item
          @count = count
          @crafted_count = crafted_count
          @ingredients_craft_tree = ingredients_craft_tree
        end

        def crafted?
          !ingredients_craft_tree.empty?
        end

        def total_price
          unit_price * crafted_count
        end

        def leftover_count
          crafted_count - count
        end

        def leftovers
          list = LeftoverList::ItemArray.new

          craft_list.each do |cl_item|
            list << LeftoverList::Item.new(cl_item.item, 0)
          end

          if leftover_count > 0
            list.detect { |l| l.name == name }.count += leftover_count
          end

          ingredients_craft_tree.each do |i|
            i.leftovers.each do |leftover|
              list.detect { |l| l.name == leftover.name }.count += leftover.count
            end
          end

          return list.reject { |i| i.count.zero? }
        end

        def shopping_list
          list = ShoppingList::ItemArray.new

          if crafted?
            ingredients_craft_tree.each do |ingredient|
              ingredient.shopping_list.each do |isl_item|
                if existing_sl_item = list.detect { |l| l.name == isl_item.name }
                  existing_sl_item.count += isl_item.count
                else
                  list << isl_item
                end
              end
            end
          else
            list << ShoppingList::Item.new(item, count)
          end

          return list
        end

        def craft_list
          list = CraftList::ItemArray.new

          if crafted?
            list << CraftList::Item.new(item, crafted_count)

            ingredients_craft_tree.each do |ingredient|
              ingredient.craft_list.each do |icl_item|
                if existing_cl_item = list.detect { |l| l.name == icl_item.name }
                  icl_item.count += existing_cl_item.count
                  list.delete(existing_cl_item)
                end

                list << icl_item
              end
            end
          end

          return list
        end

        def ordered_craft_list
          craft_list.reverse
        end
      end

      class ItemArray < Array
      end
    end

    class InvalidItem < RuntimeError
    end

    class Crafter
      def initialize(auto_craft_lvl)
        @auto_craft_lvl = auto_craft_lvl
      end

      def tick_workload
        100 + (@auto_craft_lvl - 1) * 20
      end

      def tick_count_for_workload(workload)
        (workload / tick_workload.to_f).ceil
      end

      def seconds_duration_for_workload(workload)
        (tick_count_for_workload(workload) * 5.35).ceil
      end

      def batches_per_hour(workload, hours = 1)
        (hours * 3600 / seconds_duration_for_workload(workload)).floor
      end

      def items_per_hour(workload, batch_size, hours = 1)
        batches_per_hour(workload, hours) * batch_size
      end
    end
  end
end
