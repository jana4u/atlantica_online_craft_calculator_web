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

      def self.craftable_items_for_skill_ordered_by_skill_lvl(skill)
        ordered_craftable_items.select{ |i| i.skill == skill }.sort_by { |i| i.skill_lvl_and_name_for_sort }
      end

      def self.ordered_ingredient_items
        ingredient_names = []

        items.each do |item|
          if item.craftable?
            ingredient_names += item.ingredients.keys
          end
        end

        ingredient_names = ingredient_names.uniq

        ingredients = []

        ingredient_names.each do |ingredient_name|
          ingredients << find(ingredient_name)
        end

        ingredients.sort_by { |i| i.name_for_sort }
      end

      def self.item_skills
        all.values.map { |i| i.skill }.compact.uniq
      end

      def self.ordered_item_skills
        item_skills.sort
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
        name.gsub("[I]", "1").gsub("[II]", "2").gsub("[III]", "3").gsub("[IV]", "4").gsub("[V]", "5").gsub("[VI]", "6")
      end

      def skill_lvl_and_name_for_sort
        "#{skill_lvl.to_s.rjust(3, "0")} #{name_for_sort}"
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
        return @ingredient_list if defined?(@ingredient_list)

        @ingredient_list = IngredientList::ItemArray.new

        if craftable?
          ingredients.each do |ingredient_name, ingredient_quantity|
            @ingredient_list << IngredientList::Item.new(self.class.find(ingredient_name), ingredient_quantity)
          end
        end

        return @ingredient_list
      end

      def ordered_ingredient_items
        ingredient_items.sort_by { |i| i.name_for_sort }
      end

      def ingredient_items
        list = []

        ingredient_list.each do |ingredient_item|
          list << ingredient_item.item
          list += ingredient_item.ingredient_items
        end

        return list.uniq
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
        if batch_craft_price
          batch_craft_price / batch_size
        else
          nil
        end
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

      def craft_xp_gained_per_batch
        workload / CRAFT_XP_TO_WORKLOAD_RATIO
      end

      def craft_xp_gained_per_item
        craft_xp_gained_per_batch / batch_size.to_f
      end
    end

    class ItemCraft
      def self.remove_leftovers_from_lists(craft_list, shopping_list, leftovers)
        leftovers.each do |leftover|
          if leftover.more_than_batch? && (cl_item = craft_list.detect { |i| i.name == leftover.name })
            leftover.ingredient_list.each do |li|
              existing_leftover = leftovers.detect { |l| l.item == li.item }
              leftover_quantity = li.quantity * leftover.whole_batches
              if existing_leftover
                existing_leftover.quantity += leftover_quantity
              else
                leftovers << LeftoverList::Item.new(li.item, leftover_quantity)
              end
            end

            do_not_craft_quantity = leftover.whole_batches * leftover.batch_size
            cl_item.quantity -= do_not_craft_quantity
            leftover.quantity -= do_not_craft_quantity
          elsif sl_item = shopping_list.detect { |i| i.name == leftover.name }
            sl_item.quantity -= leftover.quantity
            leftover.quantity = 0
          end
        end

        leftovers = leftovers.reject { |l| l.quantity.zero? }

        while leftovers.detect { |l| l.more_than_batch? } do
          craft_list, shopping_list, leftovers = remove_leftovers_from_lists(craft_list, shopping_list, leftovers)
        end

        return craft_list, shopping_list, leftovers
      end

      attr_reader :item, :requested_quantity

      def initialize(item, requested_quantity = nil)
        @item = item
        @requested_quantity = requested_quantity || item.batch_size
      end

      [
        :total_workload,
        :total_workload_per_skill,
        :total_craft_xp_gained,
        :total_craft_xp_gained_per_skill,
        :skills,
      ].each do |method_name|
        define_method method_name do
          craft_list.send(method_name)
        end
      end

      [
        :total_price,
      ].each do |method_name|
        define_method method_name do
          shopping_list.send(method_name)
        end
      end

      def quantity
        @quantity ||= batches * item.batch_size
      end

      def batches
        @batches ||= (requested_quantity / item.batch_size.to_f).ceil.to_i
      end

      def price
        item.unit_price * quantity
      end

      def workload
        @workload ||= batches * @item.workload
      end

      def craft_xp_gained
        @craft_xp_gained ||= workload / CRAFT_XP_TO_WORKLOAD_RATIO
      end

      def ingredient_list
        return @ingredient_list if defined?(@ingredient_list)

        @ingredient_list = IngredientList::ItemArray.new

        if item.craftable?
          item.ingredient_list.each do |ingredient|
            @ingredient_list << IngredientList::Item.new(ingredient.item, ingredient.quantity * batches)
          end
        end

        return @ingredient_list
      end

      def item_with_raw_craft_tree
        return @item_with_raw_craft_tree if defined?(@item_with_raw_craft_tree)

        list = CraftTree::ItemArray.new

        if item.crafting_is_cheaper?
          item.ingredient_list.each do |ingredient|
            list << self.class.new(ingredient.item, ingredient.quantity * batches).item_with_raw_craft_tree
          end
          item_quantity = quantity
        else
          item_quantity = requested_quantity
        end

        @item_with_raw_craft_tree = CraftTree::Item.new(item, requested_quantity, item_quantity, list)

        return @item_with_raw_craft_tree
      end

      def craft_list
        @craft_list || create_lists[0]
      end

      def shopping_list
        @shopping_list || create_lists[1]
      end

      def leftovers
        @leftovers || create_lists[2]
      end

      def raw_craft_list
        item_with_raw_craft_tree.ordered_craft_list
      end

      def raw_shopping_list
        item_with_raw_craft_tree.shopping_list
      end

      def raw_leftovers
        item_with_raw_craft_tree.leftovers.reverse
      end

      def craft_tree_leftovers
        @craft_tree_leftovers ||= item_with_raw_craft_tree.leftovers
      end

      private

      def create_lists
        @craft_list, @shopping_list, @leftovers =
          self.class.remove_leftovers_from_lists(
          raw_craft_list,
          raw_shopping_list,
          raw_leftovers
        )
      end
    end

    module ListItem
      def self.included(base)
        base.send(:attr_accessor, :quantity)
        base.send(:attr_reader, :item)
        base.extend(ClassMethods)
        base.send(:delegated_methods, :name)
      end

      def initialize(item, quantity)
        @item = item
        @quantity = quantity
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
        delegated_methods :unit_price, :price_type

        def total_price
          quantity * unit_price
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
        delegated_methods :ingredient_items
      end

      class ItemArray < ShoppingList::ItemArray
      end
    end

    module CraftList
      class Item
        include ListItem
        delegated_methods :unit_price, :ingredients, :batch_size, :workload, :skill, :skill_lvl

        def batches
          quantity / batch_size
        end

        def total_price
          unit_price * quantity
        end

        def total_workload
          batches * workload
        end

        def total_craft_xp_gained
          total_workload / CRAFT_XP_TO_WORKLOAD_RATIO
        end
      end

      class ItemArray < Array
        def skills
          result = SkillList::ItemArray.new

          self.each do |i|
            if skill = result.find(i.skill)
              skill.workload += i.total_workload
              if i.skill_lvl > skill.lvl
                skill.lvl = i.skill_lvl
              end
            else
              result << SkillList::Item.new(i.skill, i.skill_lvl, i.total_workload)
            end
          end

          return result.sort_by { |s| s.name }
        end

        def total_workload
          result = 0

          self.each do |i|
            result += i.total_workload
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

        def whole_batches
          (quantity / batch_size.to_f).floor.to_i
        end

        def more_than_batch?
          whole_batches > 0
        end
      end

      class ItemArray < Array
      end
    end

    module CraftTree
      class Item
        include ListItem
        delegated_methods :unit_price, :price_type
        attr_reader :requested_quantity, :ingredients_craft_tree

        def initialize(item, requested_quantity, quantity, ingredients_craft_tree)
          @item = item
          @requested_quantity = requested_quantity
          @quantity = quantity
          @ingredients_craft_tree = ingredients_craft_tree
        end

        def crafted?
          !ingredients_craft_tree.empty?
        end

        def total_price
          unit_price * quantity
        end

        def leftover_quantity
          quantity - requested_quantity
        end

        def leftovers
          list = LeftoverList::ItemArray.new

          craft_list.each do |cl_item|
            list << LeftoverList::Item.new(cl_item.item, 0)
          end

          if leftover_quantity > 0
            list.detect { |l| l.name == name }.quantity += leftover_quantity
          end

          ingredients_craft_tree.each do |i|
            i.leftovers.each do |leftover|
              list.detect { |l| l.name == leftover.name }.quantity += leftover.quantity
            end
          end

          return list.reject { |i| i.quantity.zero? }
        end

        def shopping_list
          list = ShoppingList::ItemArray.new

          if crafted?
            ingredients_craft_tree.each do |ingredient|
              ingredient.shopping_list.each do |isl_item|
                if existing_sl_item = list.detect { |l| l.name == isl_item.name }
                  existing_sl_item.quantity += isl_item.quantity
                else
                  list << isl_item
                end
              end
            end
          else
            list << ShoppingList::Item.new(item, requested_quantity)
          end

          return list
        end

        def craft_list
          list = CraftList::ItemArray.new

          if crafted?
            list << CraftList::Item.new(item, quantity)

            ingredients_craft_tree.each do |ingredient|
              ingredient.craft_list.each do |icl_item|
                if existing_cl_item = list.detect { |l| l.name == icl_item.name }
                  icl_item.quantity += existing_cl_item.quantity
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

    module SkillList
      class Item
        attr_reader :name
        attr_accessor :lvl, :workload

        def initialize(name, lvl, workload)
          @name = name
          @lvl = lvl
          @workload = workload
        end

        def craft_xp_gained
          workload / CRAFT_XP_TO_WORKLOAD_RATIO
        end
      end

      class ItemArray < Array
        def find(skill_name)
          detect { |s| s.name == skill_name }
        end
      end
    end

    class InvalidItem < RuntimeError
    end

    class Crafter
      if RUBY_VERSION >= "1.9"
        require 'csv'
        FasterCSV = CSV
      else
        require 'rubygems'
        require 'fastercsv'
      end

      def self.load_data_from_csv(data_file = File.join(File.dirname(__FILE__), 'experience.csv'))
        csv_data = FasterCSV.read(data_file, :headers => true)

        self.levels = csv_data
      end

      def self.levels=(array)
        @@levels = []

        array.each do |item|
          @@levels << { :lvl => item["lvl"].to_i, :xp => item["xp"].to_i }
        end
      end

      def self.levels
        @@levels || {}
      end

      attr_reader :auto_craft_lvl

      def initialize(auto_craft_lvl)
        @auto_craft_lvl = auto_craft_lvl
      end

      def tick_workload
        100 + (@auto_craft_lvl - 1) * 20
      end

      def ticks_for_workload(workload)
        (workload / tick_workload.to_f).ceil
      end

      def seconds_duration_for_workload(workload)
        (ticks_for_workload(workload) * 5.35).ceil
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
