require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get root_path

    assert_response :success
  end

  test "index with skill" do
    get root_path(skill: "Action"), xhr: true

    assert_response :success
  end

  test "index with search" do
    get root_path(query: "craft"), xhr: true

    assert_response :success
  end

  test "index with item and no count" do
    get root_path(item_name: craftable_item_name), xhr: true

    assert_response :success
  end

  test "index with item and count" do
    get root_path(item_name: craftable_item_name, count: "10"), xhr: true

    assert_response :success
  end

  test "index with item and custom prices" do
    put custom_prices_path(
      custom_prices: {CGI.escape(ingredient_item_name) => "1000"}
    )

    assert_redirected_to custom_prices_path

    get root_path(item_name: craftable_item_name), xhr: true

    assert_response :success
  end
end
