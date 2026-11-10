require "test_helper"

class LocalesControllerTest < ActionDispatch::IntegrationTest
  test "should switch locale to en and save in session" do
    post set_locale_url(:en)
    assert_redirected_to root_url
    assert_equal :en, session[:locale]
    assert_equal "en", cookies[:locale]

    get root_url
    assert_response :success
    assert_select "html[lang=?]", "en"
    assert_select "meta[name='locale'][content='en']"
  end

  test "should restore locale from persistent cookie when browser session is closed" do
    post set_locale_url(:en)
    assert_equal :en, session[:locale]

    # Simulate closing browser (session cleared, persistent cookie retained)
    session.clear

    get root_url
    assert_response :success
    assert_select "html[lang=?]", "en"
    assert_equal :en, session[:locale]
  end

  test "should switch locale to vi and save in session" do
    post set_locale_url(:vi)
    assert_redirected_to root_url
    assert_equal :vi, session[:locale]

    get root_url
    assert_response :success
    assert_select "html[lang=?]", "vi"
    assert_select "meta[name='locale'][content='vi']"
  end

  test "should not switch to unsupported locale" do
    old_locale = I18n.default_locale
    post set_locale_url(:fr)
    assert_redirected_to root_url
    assert_equal old_locale, session[:locale]
  end
end
