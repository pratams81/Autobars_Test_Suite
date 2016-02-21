# encoding: UTF-8
# Author: Elin Lloyd
# General methods that could be used for any screen
require 'uri'

# Validates that loading has complete by checking the loadingAnimation appears and then disappears
def loading_complete(webdriver = nil)
  if not webdriver
    webdriver = @driver
  end

  begin
    # Validate the loading icon has been displayed
    Selenium::WebDriver::Wait.new(timeout: 10).until { webdriver.find_element(:id, 'loadingAnimation').displayed? }
    # Validate the loading icon is no longer being displayed
    Selenium::WebDriver::Wait.new(timeout: 30).until { !webdriver.find_element(:id, 'loadingAnimation').displayed? }
  rescue Selenium::WebDriver::Error::TimeOutError
    # TODO: Add logging
  end

  # Extra validation to ensure that loading icon is not being displayed and can therefore continue
  raise 'Timeout - loading animation is displayed when not expected' if webdriver.find_element(:id, 'loadingAnimation').displayed?
end

# Validates that a dialog is not being displaed
def raise_if_dialog_displayed
  # Validate a dialog is not open
  if @dialog && @dialog.is_displayed
    begin
      fail 'Dialog is displayed on the screen when not expected' if @dialog.dialog_modal.displayed?
    rescue Selenium::WebDriver::Error::NoSuchElementError
      begin
        fail 'Parental Controls dialog is displayed on the screen when not expected' if @dialog.parental_dialog.displayed?
      rescue Selenium::WebDriver::Error::NoSuchElementError
        puts 'Dialog was not displayed - so continue'
      end
    end
  end
end

# Initialises the provided screen page object
def validate_expected_screen(screen)
  if screen == 'fullscreen-dialog'
    @dialog = Dialog.new(driver,  APP_TYPE)
  elsif screen == 'popup-dialog'
    @dialog = Dialog.new(driver,  APP_TYPE)
  elsif screen == 'login'
    @login_screen = LoginScreen.new(driver,  APP_TYPE)
  else
    fail "Expected Screen is not an expected value. #{screen}"
  end
end

# Launches the device (in provided language), and opens the app url
# Note: The application should be started with the DELAY_INITIALISATION configuration value
def create_driver()
  startdrivernow(true)
  driver = @driver
  @asset_maps = YAML.load_file("features/test_data_mapping/environment.yml")

  if DEVICE_TYPE != 'Android'
    if APP_TYPE == 'Phone'
      sleep 1
      driver.manage.window.resize_to(480, 800)
      sleep 1
    else
      driver.manage.window.maximize
    end
    asset_mapping = @asset_maps.find { |item| item[:Environment] == "system" }
    fail "Could not find asset mapping for system" if not asset_mapping

    asset_url = asset_mapping[:url]

    driver.navigate.to asset_url

    # This is required otherwise ie does no pick up the events
    driver.switch_to.active_element if DEVICE_TYPE == 'IE'
  end
end

# Starting the application continues initialisation by setting DELAY_INITIALISATION to false
# and running Launch.initialise()
def start_app
end

def clear_preferences(driver)

end

def get_absolute_path(url)
  uri = URI.parse(driver.current_url)
  split_uri = uri.path.split('/')
  split_uri.pop
  split_uri[0] = "#{uri.scheme}://#{uri.host}"
  split_url = url.split('/')
  joined_url_array = split_uri + split_url
  joined_url = joined_url_array.join('/')
  joined_url
end

# Check if an element is highlighted
def highlighted?(element)
  element.attribute('class').include? 'required'
end

def highlighting_error_msg(input_name, element, condition)
  if condition == 'is'
    fail "#{input_name} is not highlighted!!" unless highlighted?(element)
  elsif condition == "is not"
    fail "#{input_name} highlighted!!" if highlighted?(element)
  end
end

# Wrapper to get fresh new dialog, when the old one has been rewrited.
# It fixes the StaleElementReferenceError raised when checking the purchase confirmation dialog out.
# Waits until the text element defined by a locator containes the value passed as a parameter.
# Receives:
# - locator: A string that the defines de path to the text element.
# - value: The value that the text element must include.
# Return:
# - New Dialog page object.
def wait_for_dialog(locator, value)
  begin
    wait.until { @driver.find_element(:class, locator).text.include? value }
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    wait.until { @driver.find_element(:class, locator).text.include? value }
  end
  return Dialog.new(driver, APP_TYPE, TEST_ENV)
end
