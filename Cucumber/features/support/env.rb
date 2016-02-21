# encoding: UTF-8

require 'rubygems'
require 'selenium-webdriver'
require_relative 'StartDriver'

# The location of the deployed app
APP_URL = ENV['APP_URL']

# The location of the appium webdriver hub
APPIUM_URL = ENV['APPIUM_URL']

# The location of the NMP andorid apk file (defaults to /Users/elinlloyd/Downloads/nmp.apk if not provided )
ANDROID_PATH_URL = ENV['ANDROID_APP_PATH'] || '/Users/elinlloyd/Downloads/nmp.apk'

# The location of the NMP IOS app file (defaults to TODO.app if not provided )
IOS_PATH_URL = ENV['IOS_APP_PATH'] || '/Users/elinlloyd/Desktop/appFiles/iNMP.ipa'

# The location of the Remote webdriver hub
REMOTE_WEB_DRIVER = ENV['REMOTE_WEB_DRIVER']

# The device the tests should run (e.g. Chrome, RemoteChrome, Android)
DEVICE_TYPE = ENV['DEVICE_TYPE'] || 'Chrome'

# The type of device tests that should be run (e.g. Desktop, Phone, Tablet)
APP_TYPE = ENV['APP_TYPE'] || 'Tablet'

# TODO: get this working with a remote desktop (they currently just take blank screnshots)
# Whether screenshots should be taken when running the tests (Defults to False)
TAKE_SCREENSHOTS = ENV['TAKE_SCREENSHOTS'] || 'True'

# If screnshots are taken should they be compared against a baseline (defaults to False)
COMPARE_SCREENSHOTS = ENV['COMPARE_SCREENSHOTS'] || 'False'

# It is the calling process's responsibility to remove the screenshots directory as necessary
# Should work fine with parallel runners, provided they don't duplicate tests
if TAKE_SCREENSHOTS == 'True'
  begin
    FileUtils.mkdir('screenshots') if not FileTest.directory?('screenshots')
    FileUtils.mkdir('screenshots/actual') if not FileTest.directory?('screenshots/actual')
  rescue Errno::EEXIST
    puts "Info: Failed to create a screenshots/actual"
  end
end

if COMPARE_SCREENSHOTS == 'True'
  FileUtils.rm_rf('screenshots/diff') if FileTest.directory?('screenshots/diff')
  FileUtils.mkdir('screenshots/diff')
end

TEST_ENV = ENV['TEST_ENV'] || 'ott.nagra.com'

World(StartDriver)
