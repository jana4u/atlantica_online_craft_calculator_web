require "test_helper"

module AtlanticaOnlineCraftCalculatorEngine
  class CustomPricesSessionStoreTest < ActiveSupport::TestCase
    test "store with items and deleting store contents" do
      hash = { :custom_prices => { "item" => 1 } }
      custom_prices_store = CustomPricesSessionStore.new(hash)

      result1 = { "item" => 1 }
      assert_equal result1, custom_prices_store.all
      assert_equal result1, hash[:custom_prices]

      custom_prices_store.delete_all

      result2 = {}
      assert_equal result2, custom_prices_store.all
      assert_equal result2, hash[:custom_prices]
    end

    test "empty store and updating contents" do
      hash = {}
      custom_prices_store = CustomPricesSessionStore.new(hash)

      assert_equal Hash.new, custom_prices_store.all

      custom_prices_store.update_all({ "item" => "1" })

      result1 = { "item" => 1 }
      assert_equal result1, custom_prices_store.all
      assert_equal result1, hash[:custom_prices]

      custom_prices_store.update_all({ "thing" => "2" })

      result2 = { "thing" => 2 }
      assert_equal result2, custom_prices_store.all
      assert_equal result2, hash[:custom_prices]
    end
  end
end
