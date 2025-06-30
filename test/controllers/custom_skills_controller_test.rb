require "test_helper"

class CustomSkillsControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get custom_skills_path

    assert_response :success
  end

  test "update" do
    put custom_skills_path(auto_craft: "120")

    assert_redirected_to custom_skills_path

    follow_redirect!

    assert_response :success
  end
end
