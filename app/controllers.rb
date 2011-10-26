CraftCalculator.controllers  do
  get :index do
    AtlanticaOnline::CraftCalculator::Item.load_data_from_yaml
    @items = AtlanticaOnline::CraftCalculator::Item.items.select{ |i| i.craftable? }.sort_by { |i| i.name }
    render 'index'
  end

  post :index, :provides => [:html, :js] do
    AtlanticaOnline::CraftCalculator::Item.load_data_from_yaml
    @items = AtlanticaOnline::CraftCalculator::Item.items.select{ |i| i.craftable? }.sort_by { |i| i.name }
    @item = AtlanticaOnline::CraftCalculator::Item.find(params[:item_name])
    @crafter_ac_1 = AtlanticaOnline::CraftCalculator::Crafter.new(1)
    @crafter_ac_120 = AtlanticaOnline::CraftCalculator::Crafter.new(120)
    unless params[:count].blank?
      @count = params[:count].to_i
      @craft_list, @shopping_list, @leftovers = @item.craft(@count)
    end
    render 'index'
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
