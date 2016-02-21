# encoding: UTF-8
# Author: Elin Lloyd

# helper methods for login screen
class LoginScreen
  def initialize(browser, app_type)
    @browser = browser
    @app_type = app_type
  end

  def displayed?
    begin
      @browser.find_element(:css, 'Autobars')
      return true
    rescue
      return false
    end
  end

  def login_title
    return @browser.find_element(:class, 'heading-large')
  end

  # Login using the provided username/password and click signin
  def login(entered_username, entered_password)
    username.click
    username.send_keys(entered_username)
    password.click
    password.send_keys(entered_password)
    signin_button.click
  end

  def signin_button
    @browser.find_element(:class, 'button')
  end

  # Click the signin button
  def click_signin
    signin_button.click
  end

  # Returns the username field element
  def username
    return @browser.find_element(:name, 'username')
  end

  # Returns the password field element
  def password
    return @browser.find_element(:name, 'password')
  end

  def rememberme
    return @browser.find_element(:name, 'rememberme')
  end

  def login_failed
    return @browser.find_element(:class, 'error-summary-heading')
  end

  def error_msg
    return @browser.find_element(:xpath, '//*[@id="content"]/div[2]/div/div/p').text
  end

end
