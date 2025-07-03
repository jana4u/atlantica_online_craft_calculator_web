require "test_helper"

class CustomPricesControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get custom_prices_path

    assert_response :success
  end

  test "index for item" do
    get custom_prices_path(item_name: craftable_item_name)

    assert_response :success
  end

  test "update" do
    put custom_prices_path(
      custom_prices: {
        CGI.escape("No longer existing 1") => "0",
        CGI.escape(ingredient_item_name) => "10",
        CGI.escape(craftable_item_name) => "1000"
      },
      crafting_disabled: [
        "No longer existing 2",
        craftable_item_name
      ]
    )

    assert_redirected_to custom_prices_path

    follow_redirect!

    assert_response :success
  end

  test "destroy" do
    delete custom_prices_path

    assert_redirected_to custom_prices_path

    follow_redirect!

    assert_response :success
  end
end
