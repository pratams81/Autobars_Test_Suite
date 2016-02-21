#require 'appium_lib'

# Module for starting different devices
module StartDevice
  def self.start_device()
    caps = Appium.load_appium_txt file: "appium.txt", verbose: true

    driver = Appium::Driver.new(caps)
    driver.start_driver

    return driver
  end

  # Start ios device (with appium remote driver)
  def self.start_ios(app_type)
    driver = start_device

    # TODO: Implement any iOS specific steps

    return driver
  end

  # Start android device (with appium remote driver), and wait until the
  # WLA has been launched
  def self.start_android(app_type)
    driver = start_device

    # Wait until the webview is created
    Selenium::WebDriver::Wait.new(timeout: 10).until { driver.available_contexts.include? "WEBVIEW_nagra.nmp"}

    # Set the context to the webview (should be the last context)
    driver.set_context(driver.available_contexts.last)

    # Wait for the bootstrap to redirect us to the WLA
    Selenium::WebDriver::Wait.new(timeout: 10).until { driver.find_element(:id, 'loadingAnimation')}

    return driver
  end
end

