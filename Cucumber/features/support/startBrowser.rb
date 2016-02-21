# Module for starting different browsers
module StartBrowser
  # No distinguish between android/iOs here as this is just a intermediate step before running the tests on emulators/real devices
  @user_agent = { chrome:
                  {
                    'Phone' => 'Mozilla/5.0(iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3',
                    'Tablet' => 'Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10'
                  }
                }

  # A basic highlighting class for debugging purposes
  class HighlightAbstractTest
    def highlight(element, driver, color)
      orig_style = element.attribute("style")
      driver.execute_script("arguments[0].setAttribute(arguments[1], arguments[2])", element, "style", "border: 2px solid #{color}; color: #{color};")
      sleep 1
      driver.execute_script("arguments[0].setAttribute(arguments[1], arguments[2])", element, "style", orig_style)
    end

    def call(*args)
      case args.first
      when :before_click
        #puts "Clicking #{args[1]}"
        highlight args[1], args[2], "red"
      when :before_find
      end
    end
  end

  # Start local chrome with the provided user-agent
  def self.start_chrome(app_type)
    args = ['--always-authorize-plugins', '--disable-popup-blocking']

    if ENV['PPAPI'] == "True"
      args.push('--load-extension=ppapi')
      args.push('--unlimited-storage')
    else
      args.push("--enable-npapi")
    end

    if @user_agent[:chrome].key?(app_type)
      args.push("--user-agent=#{@user_agent[:chrome][app_type]}")
    end

    if ENV['DEBUG']
      return Selenium::WebDriver.for :chrome, switches: args, listener: HighlightAbstractTest.new
    else
      return Selenium::WebDriver.for :chrome, switches: args
    end
  end

  # Start remote chrome driver with the provided user-agent
  def self.start_remote_chrome(app_type)
    args = ['--always-authorize-plugins', '--disable-popup-blocking']

    if ENV['PPAPI'] == "True"
      args.push('--load-extension=ppapi')
      args.push('--unlimited-storage')
    else
      args.push("--enable-npapi")
    end

    if @user_agent[:chrome].key?(app_type)
      args.push("--user-agent=#{@user_agent[:chrome][app_type]}")
    end

    remote_caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => { 'args' => args })
    return Selenium::WebDriver.for :remote, url: REMOTE_WEB_DRIVER, desired_capabilities: remote_caps
  end

  # Start local ie with the provided user-agent and language
  def self.start_ie(_app_type, native)
    # native_events=false is required for some scenarios in IE otherwise clicks do not register
    caps = Selenium::WebDriver::Remote::Capabilities.ie('ie.ensureCleanSession' => true, 'ie.browserCommandLineSwitches' => 'private')

    if native
      return Selenium::WebDriver.for :ie, desired_capabilities: caps
    else
      return Selenium::WebDriver.for :ie, native_events: false, desired_capabilities: caps
    end
  end


  # Start remote ie driver
  def self.start_remote_ie
    caps = Selenium::WebDriver::Remote::Capabilities.ie('ie.ensureCleanSession' => true, 'ie.browserCommandLineSwitches' => 'private')

    Selenium::WebDriver.for :remote, url: REMOTE_WEB_DRIVER, desired_capabilities: caps
  end

  def self.firefox_profile
    default_profile = Selenium::WebDriver::Firefox::Profile.new
    default_profile.native_events = true
    default_profile["plugin.default.state"] = 2

    return default_profile
  end

  # Start remote firefox driver with the provided user-agent
  # Note: Firefox should be ready to roll with Selenium 2.46 https://code.google.com/p/selenium/issues/detail?id=7506
  def self.start_remote_ff
    # WARNING: Trying to run too many remote FF instances may cause issues with ephemeral ports:
    # https://code.google.com/p/selenium/wiki/ScalingWebDriver
    caps = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => self.firefox_profile)
    Selenium::WebDriver.for :remote, url: REMOTE_WEB_DRIVER, desired_capabilities: caps
  end

  # Start local firefox with provided user-agent
  def self.start_firefox
    # See https://code.google.com/p/selenium/issues/detail?id=5554
    # version 21 of firefox must be used
    Selenium::WebDriver.for :firefox, profile: self.firefox_profile
  end
end
