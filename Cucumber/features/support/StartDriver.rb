require_relative 'startBrowser'
require_relative 'startDevice'

# Module to be run when starting tests
module StartDriver
  attr_accessor :small_wait
  attr_accessor :wait
  attr_accessor :driver
  attr_reader :driver
  attr_reader :small_wait
  attr_reader :wait

  # Validate that the provided device type in the environment variable is valid
  def validate_device_type
    @device_type = ENV['DEVICE_TYPE'] || 'Chrome'

    # Validate the DEVICE_TYPE supplied is valid
    unless %w(Chrome ChromeRemote Android iOS IE IERemote FFRemote Firefox).include? @device_type
      fail "DEVICE_TYPE must be either Chrome, ChromeRemote,IE, IERemote, Firefox, FFRemote, Android or iOS not #{device_type}"
    end
  end

  # Validate that the provided app type in the environment variable is valid
  def validate_app_type
    @app_type = ENV['APP_TYPE'] || 'Tablet'

    # Validate the APP_TYPE supplied is valid
    fail 'APP_TYPE must be either Tablet/Phone/Desktop' unless %w(Tablet Phone Desktop).include? @app_type
  end

  # Set the wait timeout with default values
  def set_timeouts(wait = 120, small_wait = 3)
    # Set timeouts
    @wait = Selenium::WebDriver::Wait.new(timeout: wait)
    @small_wait = Selenium::WebDriver::Wait.new(timeout: small_wait)
  end

  # Start the appropriate device/browser
  def startdrivernow(native = true)
    # Start the relevant Device/Browser
    if @device_type == 'Chrome'
      @driver = StartBrowser.start_chrome(@app_type)
    elsif @device_type == 'ChromeRemote'
      @driver = StartBrowser.start_remote_chrome(@app_type)
    elsif @device_type == 'IERemote'
      @driver = StartBrowser.start_remote_ie()
    elsif @device_type == 'FFRemote'
      @driver = StartBrowser.start_remote_ff()
    elsif @device_type == 'Android'
      @driver = StartDevice.start_android(@app_type)
    elsif @device_type == 'iOS'
      @driver = StartDevice.start_ios(@app_type)
    elsif @device_type == 'IE'
      @driver = StartBrowser.start_ie(@app_type, native)
    elsif @device_type == 'Firefox'
      @driver = StartBrowser.start_firefox()
    end
  end

  # Close the browser/device
  def quit_browser
    if @device_type == "iOS" or @device_type == "Android"
      @driver.driver_quit if @driver
    else
      @driver.quit if @driver
    end
  end
end
