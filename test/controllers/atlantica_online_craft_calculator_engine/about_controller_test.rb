require "test_helper"

module AtlanticaOnlineCraftCalculatorEngine
  class AboutControllerTest < ActionDispatch::IntegrationTest
    test "show" do
      get about_path

      assert_response :success
    end
  end
end
