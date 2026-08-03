require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get root_path

    assert_response :success
    assert_no_item_craft
  end

  test "index with skill" do
    get root_path(skill: "Action")

    assert_response :success
    assert_no_item_craft

    get root_path(skill: "Action", format: :turbo_stream)

    assert_response :success
    assert_no_item_craft
  end

  test "index with search" do
    get root_path(query: "craft")

    assert_response :success
    assert_no_item_craft

    get root_path(query: "craft", format: :turbo_stream)

    assert_response :success
    assert_no_item_craft
  end

  test "index with item and no count" do
    get root_path(item_name: craftable_item_name)

    assert_response :success
    assert_item_craft

    get root_path(item_name: craftable_item_name, format: :turbo_stream)

    assert_response :success
    assert_item_craft
  end

  test "index with item and count" do
    get root_path(item_name: craftable_item_name, count: "10")

    assert_response :success
    assert_item_craft

    get root_path(item_name: craftable_item_name, count: "10", format: :turbo_stream)

    assert_response :success
    assert_item_craft
  end

  test "index with item that has fixed price" do
    get root_path(item_name: craftable_item_name_with_fixed_price)

    assert_response :success
    assert_item_craft(craftable_item_name_with_fixed_price)

    get root_path(item_name: craftable_item_name_with_fixed_price, format: :turbo_stream)

    assert_response :success
    assert_item_craft(craftable_item_name_with_fixed_price)
  end

  test "index with item and custom prices and auto craft set" do
    put custom_prices_path(
      custom_prices: {CGI.escape(ingredient_item_name) => "1000"}
    )

    assert_redirected_to custom_prices_path

    put custom_skills_path(auto_craft: "120")

    assert_redirected_to custom_skills_path

    get root_path(item_name: craftable_item_name)

    assert_response :success
    assert_item_craft

    get root_path(item_name: craftable_item_name, format: :turbo_stream)

    assert_response :success
    assert_item_craft
  end

  test "index with invalid item" do
    get root_path(item_name: "No longer existing")

    assert_response :success
    assert_no_item_craft

    get root_path(item_name: "No longer existing", format: :turbo_stream)

    assert_response :success
    assert_no_item_craft
  end

  private

  def assert_item_craft(item_name = craftable_item_name)
    assert_dom "h1", count: 1, text: item_name
  end

  def assert_no_item_craft
    assert_dom "h1", count: 0
  end
end
