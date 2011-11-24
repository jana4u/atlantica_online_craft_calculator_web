CraftCalculator.controllers  do
  include IntegerExtractor

  get :index, :provides => [:html, :js] do
    @custom_prices = session[:custom_prices] || {}
    AtlanticaOnline::CraftCalculator::Item.load_data_from_yaml(@custom_prices)
    render 'index'
  end

  post :index, :provides => [:html, :js] do
    @custom_prices = session[:custom_prices] || {}
    AtlanticaOnline::CraftCalculator::Item.load_data_from_yaml(@custom_prices)
    unless params[:item_name].blank?
      @item = AtlanticaOnline::CraftCalculator::Item.find(params[:item_name])
      @crafter_ac_1 = AtlanticaOnline::CraftCalculator::Crafter.new(1)
      @crafter_ac_120 = AtlanticaOnline::CraftCalculator::Crafter.new(120)
      if params[:count].blank?
        @count = @item.batch_size
      else
        @count = non_negative_integer_from_string(params[:count])
      end
      @craft_list, @shopping_list, @leftovers = @item.craft(@count)
      @item_with_raw_craft_tree = @item.item_with_raw_craft_tree(@count)
      @craft_tree_leftovers = @item_with_raw_craft_tree.leftovers
    end
    render 'index'
  end

  get :'experience-table' do
    AtlanticaOnline::CraftCalculator::Crafter.load_data_from_csv
    render 'experience_table'
  end

  get :'custom-prices' do
    AtlanticaOnline::CraftCalculator::Item.load_data_from_yaml
    begin
      @items = AtlanticaOnline::CraftCalculator::Item.find(params[:item_name]).ordered_ingredient_items
    rescue AtlanticaOnline::CraftCalculator::InvalidItem
      @items = AtlanticaOnline::CraftCalculator::Item.ordered_ingredient_items
    end
    @custom_prices = session[:custom_prices] || {}
    render 'custom_prices'
  end

  post :'custom-prices' do
    session[:custom_prices] = {}

    params[:custom_prices].each do |item_name, price|
      unless price.blank?
        session[:custom_prices][CGI::unescape(item_name)] = non_negative_integer_from_string(price)
      end
    end

    redirect item_custom_prices_url
  end

  delete :'custom-prices' do
    session[:custom_prices] = {}

    redirect item_custom_prices_url
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
