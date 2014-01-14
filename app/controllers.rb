# -*- encoding : utf-8 -*-
CraftCalculator.controllers  do
  include IntegerExtractor

  get :index, :provides => [:html, :js] do
    @custom_prices = session[:custom_prices] || {}
    AtlanticaOnlineCraftCalculator::Item.load_data_from_yaml
    AtlanticaOnlineCraftCalculator::Item.configure_custom_prices(@custom_prices)
    AtlanticaOnlineCraftCalculator::Item.configure_items_with_crafting_disabled(session[:crafting_disabled] || [])
    unless params[:item_name].blank?
      @item = AtlanticaOnlineCraftCalculator::Item.find(params[:item_name])
      @crafter = AtlanticaOnlineCraftCalculator::Crafter.new(session[:auto_craft] || 1)
      if params[:count].blank?
        count = @item.batch_size
      else
        count = non_negative_integer_from_string(params[:count])
      end
      @item_craft = AtlanticaOnlineCraftCalculator::ItemCraft.new(@item, count)
    end
    render 'index'
  end

  get :'experience-table' do
    AtlanticaOnlineCraftCalculator::CraftExperience.load_levels_from_csv
    render 'experience_table'
  end

  get :'custom-prices' do
    AtlanticaOnlineCraftCalculator::Item.load_data_from_yaml
    begin
      @items = AtlanticaOnlineCraftCalculator::Item.find(params[:item_name]).ordered_ingredient_items
    rescue AtlanticaOnlineCraftCalculator::InvalidItem
      @items = AtlanticaOnlineCraftCalculator::Item.ordered_ingredient_items
    end
    @custom_prices = session[:custom_prices] || {}
    @crafting_disabled = session[:crafting_disabled] || []
    @customized_items = (@custom_prices.keys + @crafting_disabled).uniq.
      map { |name| begin AtlanticaOnlineCraftCalculator::Item.find(name) rescue nil end }.
      compact.sort {|x,y| x.name_for_sort <=> y.name_for_sort }
    render 'custom_prices'
  end

  post :'custom-prices' do
    session[:custom_prices] = {}

    params[:custom_prices].each do |item_name, price|
      unless price.blank?
        session[:custom_prices][CGI::unescape(item_name)] = non_negative_integer_from_string(price)
      end
    end

    session[:crafting_disabled] = params[:crafting_disabled]

    redirect item_custom_prices_url
  end

  delete :'custom-prices' do
    session[:custom_prices] = {}

    redirect item_custom_prices_url
  end

  get :'custom-skills' do
    render 'custom_skills'
  end

  post :'custom-skills' do
    if params[:auto_craft].blank?
      session[:auto_craft] = nil
    else
      session[:auto_craft] = [ [ non_negative_integer_from_string(params[:auto_craft]), 1].max, 120 ].min
    end

    redirect url(:"custom-skills")
  end

  [:about].each do |page|
    get page do
      render page.to_s.gsub('-', '_')
    end
  end

  # get :index, :map => "/foo/bar" do
  #   session[:foo] = "bar"
  #   render 'index'
  # end

  # get :sample, :map => "/sample/url", :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get "/example" do
  #   "Hello world!"
  # end


end
