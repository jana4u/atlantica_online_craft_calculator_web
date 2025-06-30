require "test_helper"

module AtlanticaOnlineCraftCalculatorEngine
  class ExperienceTableControllerTest < ActionDispatch::IntegrationTest
    test "show" do
      get experience_table_path

      assert_response :success
    end
  end
end
