require "test_helper"

module AtlanticaOnlineCraftCalculatorEngine
  class CraftingDisabledSessionStoreTest < ActiveSupport::TestCase
    test "store with items and deleting store contents" do
      hash = { :crafting_disabled => ["item"] }
      crafting_disabled_store = CraftingDisabledSessionStore.new(hash)

      result1 = ["item"]
      assert_equal result1, crafting_disabled_store.all
      assert_equal result1, hash[:crafting_disabled]

      crafting_disabled_store.delete_all

      result2 = []
      assert_equal result2, crafting_disabled_store.all
      assert_equal result2, hash[:crafting_disabled]
    end

    test "empty store and updating contents" do
      hash = {}
      crafting_disabled_store = CraftingDisabledSessionStore.new(hash)

      assert_equal [], crafting_disabled_store.all

      crafting_disabled_store.update_all(["item"])

      result1 = ["item"]
      assert_equal result1, crafting_disabled_store.all
      assert_equal result1, hash[:crafting_disabled]

      crafting_disabled_store.update_all(["thing"])

      result2 = ["thing"]
      assert_equal result2, crafting_disabled_store.all
      assert_equal result2, hash[:crafting_disabled]
    end
  end
end
