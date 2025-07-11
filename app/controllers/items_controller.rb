class ItemsController < ApplicationController
  def index
    @custom_prices = custom_prices_store.all
    @crafting_disabled = crafting_disabled_store.all
    AtlanticaOnlineCraftCalculator::Item.load_data_from_yaml
    AtlanticaOnlineCraftCalculator::Item.configure_custom_prices(@custom_prices)
    AtlanticaOnlineCraftCalculator::Item.configure_items_with_crafting_disabled(@crafting_disabled)
    if params[:item_name].present?
      begin
        @item = AtlanticaOnlineCraftCalculator::Item.find(params[:item_name])
        @crafter = AtlanticaOnlineCraftCalculator::Crafter.new(custom_skills_store.auto_craft || 1)
        count = if params[:count].blank?
          @item.batch_size
        else
          IntegerExtractor.non_negative_integer_from_string(params[:count])
        end
        @item_craft = AtlanticaOnlineCraftCalculator::ItemCraft.new(@item, count)
      rescue AtlanticaOnlineCraftCalculator::InvalidItem
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end
end
