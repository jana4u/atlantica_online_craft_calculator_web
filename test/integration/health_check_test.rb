require "test_helper"

class HealthCheckTest < ActionDispatch::IntegrationTest
  test "health_check" do
    get rails_health_check_url
    assert_response :success
  end
end
