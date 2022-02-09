require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @base_title = "For the Love of Quote"
  end

  test "should get root" do
    get root_url
    assert_response :success
    assert_select "title", "#{@base_title}"
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end

  test "should get imprint" do
    get imprint_path
    assert_response :success
    assert_select "title", "Imprint | #{@base_title}"
  end

  test "should get privacy_notice" do
    get privacy_notice_path
    assert_response :success
    assert_select "title", "Privacy Notice | #{@base_title}"
  end

  test "should get contact" do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | #{@base_title}"
  end

end
