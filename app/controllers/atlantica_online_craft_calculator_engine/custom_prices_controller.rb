require_dependency "atlantica_online_craft_calculator_engine/application_controller"

module AtlanticaOnlineCraftCalculatorEngine
  class CustomPricesController < ApplicationController
    def index
      AtlanticaOnlineCraftCalculator::Item.load_data_from_yaml
      begin
        @items = AtlanticaOnlineCraftCalculator::Item.find(params[:item_name]).ordered_ingredient_items
      rescue AtlanticaOnlineCraftCalculator::InvalidItem
        @items = AtlanticaOnlineCraftCalculator::Item.ordered_ingredient_items
      end
      @custom_prices = custom_prices_store.all
      @crafting_disabled = crafting_disabled_store.all
      @customized_items = (@custom_prices.keys + @crafting_disabled).uniq.map do |name|
        begin
          AtlanticaOnlineCraftCalculator::Item.find(name)
        rescue nil
        end
      end.compact.sort { |x, y| x.name_for_sort <=> y.name_for_sort }
    end

    def update
      custom_prices_hash = {}

      if params[:custom_prices]
        params[:custom_prices].each do |key, value|
          custom_prices_hash[CGI::unescape(key)] = value
        end
      end

      custom_prices_store.update_all(custom_prices_hash)

      crafting_disabled_store.update_all(params[:crafting_disabled])

      redirect_to item_custom_prices_url
    end

    def destroy
      custom_prices_store.delete_all
      crafting_disabled_store.delete_all

      redirect_to item_custom_prices_url
    end
  end
end
