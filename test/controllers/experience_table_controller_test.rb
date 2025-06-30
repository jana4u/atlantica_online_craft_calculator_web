require "test_helper"

class ExperienceTableControllerTest < ActionDispatch::IntegrationTest
  test "show" do
    get experience_table_path

    assert_response :success
  end
end
