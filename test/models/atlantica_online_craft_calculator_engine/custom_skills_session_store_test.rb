require "test_helper"

module AtlanticaOnlineCraftCalculatorEngine
  class CustomSkillsSessionStoreTest < ActiveSupport::TestCase
    test "store with auto craft and removing it" do
      hash = { :auto_craft => 60 }
      custom_skills_store = CustomSkillsSessionStore.new(hash)

      assert_equal 60, custom_skills_store.auto_craft
      assert_equal 60, hash[:auto_craft]

      custom_skills_store.auto_craft = ""

      assert_nil custom_skills_store.auto_craft
      assert_nil hash[:auto_craft]
    end

    test "empty store and updating auto craft" do
      hash = {}
      custom_skills_store = CustomSkillsSessionStore.new(hash)

      assert_nil custom_skills_store.auto_craft
      assert_nil hash[:auto_craft]

      custom_skills_store.auto_craft = "30"

      assert_equal 30, custom_skills_store.auto_craft
      assert_equal 30, hash[:auto_craft]

      custom_skills_store.auto_craft = "0"

      assert_equal 1, custom_skills_store.auto_craft
      assert_equal 1, hash[:auto_craft]

      custom_skills_store.auto_craft = "121"

      assert_equal 120, custom_skills_store.auto_craft
      assert_equal 120, hash[:auto_craft]
    end
  end
end
