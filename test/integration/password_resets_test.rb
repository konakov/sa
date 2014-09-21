require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password_reset" do
    get new_password_reset_path
    # Invalid submission
    post password_resets_path, password_reset: { email: "" }
    assert_template 'password_resets/new'
    # Valid submission
    post password_resets_path, password_reset: { email: @user.email }
    assert_redirected_to root_url
    # Get the user from the create action.
    user = assigns(:user)
    follow_redirect!
    assert_select 'div.alert'
    assert_equal ActionMailer::Base.deliveries.size, 1
    # Wrong email
    get edit_password_reset_path(user.reset_token, email: 'wrong')
    assert_redirected_to root_url
    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input#email[name=email][type=hidden][value=?]", user.email
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token),
          email: user.email,
          user:  { password:              "foobaz",
                   password_confirmation: "barquux" }
    assert_select 'div#error_explanation'
    # Valid password & confirmation
    patch_via_redirect password_reset_path(user.reset_token),
                       email: user.email,
                       user: { password:              "foobaz",
                               password_confirmation: "foobaz" }
    assert_template 'users/show'
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path, password_reset: { email: @user.email }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          email: @user.email,
          user: { password:              "foobar",
                  password_confirmation: "foobar" }
    assert_response :redirect
    follow_redirect!
    assert_match "Password reset has expired", response.body
  end
end
