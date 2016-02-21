######################
# Session management #
######################

# Defines a fake session manager which behaves in the following way:
#  Sets up and tears down arbitrary content
#  Errors during setup for PotC 1 (PRELOADED_10_MAIN)
#  Errors during teardown for PotC 2 (PRELOADED_11_MAIN)
Given /^a fake (SRM|OTT) session manager is installed$/ do |type|
  fail "Session management constructor is not present in JSFW" if not @driver.execute_script("return $N.services.sessionmanagement.#{type}Session")
  @driver.execute_script("var sessionManager = function(url) {
    if(url !== \"ott.nagra.com/stable/\") {
        $N.test.sessionConstructionFailed = true;
    }
  };

  sessionManager.prototype.createSession = function(content, callback) {
    if(content.getContentId() === \"PRELOADED_10_MAIN\") {
      $N.test.lastSetup = \"FAILED\";
      setTimeout(function(){callback(83914)}, 10);
    } else {
      $N.test.lastSetup = content.getContentId();
      this.activeSession = content.getContentId();
      setTimeout(function(){callback(true)}, 10);
    }
  };

  sessionManager.prototype.tearDownSession = function(callback) {
    $N.test.teardownAttempts = $N.test.teardownAttempts || 0;
    $N.test.teardownAttempts++;
    if(this.activeSession === \"PRELOADED_11_MAIN\") {
      $N.test.lastTeardown = false;
      if (callback) {setTimeout(function(){callback(1000)}, 10);}
    } else {
      $N.test.lastTeardown = this.activeSession;
      this.activeSession = undefined;
      if (callback) {setTimeout(function(){callback(true)}, 10);}
    }

  };

  $U.core.Configuration.SDP_CONFIG.SESSION_MANAGER = sessionManager;")
end

Then /^(?:SRM|OTT) session manager was constructed successfully$/ do
  fail "Session manager did not construct correctly" if @driver.execute_script("return $N.test.sessionConstructionFailed;")
end

Then /^(?:SRM|OTT) setup has been called with id "(.*?)"$/ do |id|
  last_setup = @driver.execute_script("return $N.test.lastSetup;")
  fail "Expected last setup content ID to be #{id} but got #{last_setup}" if last_setup != id
end


Then /^(?:SRM|OTT) teardown was successful$/ do
  last_teardown = @driver.execute_script("return $N.test.lastTeardown;")
  fail "Expected last teardown to be successful" if not last_teardown
end

Then /^(?:SRM|OTT) teardown has been attempted ([0-9]+) times$/ do |expected_attempts|
  attempts = @driver.execute_script("return $N.test.teardownAttempts;")
  fail "Number of attempts was #{attempts} but expected #{expected_attempts}" if attempts != expected_attempts.to_i
end

#########################
# Device Type Profiling #
#########################
Given /^app is configured to intercept device type profiling requests$/ do
  @driver.execute_script("
    function XssRequestInterceptor(original) {
        var ctor = function(verb, url, success, failure) {
            if(verb !== \"POST\" || url.indexOf(\"/deviceregistrations/device/\") === -1) {
                original.call(this, verb, url, success, failure);
                this.__proto__ = original.prototype;
            }
        }

        ctor.prototype.send = function(data) {
            $N.test.deviceProfileSuccess = true;
            $N.test.deviceProfileData = data;
        }
        ctor.prototype.setRequestHeader = function(){};
        ctor.prototype.setTimeout = function(){};
        ctor.prototype.abort = function(){};
        ctor.prototype.setContentType = function(){};

        return ctor;
    }
    $N.apps.core.XssRequest = XssRequestInterceptor($N.apps.core.XssRequest);
  ")
end

Given /^app is configured to send a fake device profile$/ do
  @driver.execute_script("
    $N.env.deviceInformation = {
    device: {
      CPU: {
        cores: 7500,
        frequency: 124
      },
      GPU: {
        cores: null,
        frequency: null,
        model: \"Test model\"
      },
      OS: {
        type: \"Test OS\",
        version: \"Test OS Version\"
      },
      hardware: {
        manufacturer: \"Test Manufacturer\",
        model: \"Test Model\",
        type: \"Test Type\"
      },
      screen: {
        density: null,
        height: 132,
        width: 114
      }
    },
    securePlayer: {
      DRMs: [\"PRMTEST\"],
      codecs: [\"H264TEST\"],
      streamings: [\"HLSTEST\"]
    }
  };")
end

Then /^device information is sent to UAV$/ do
  fail "Device information was not sent to the UAV" if not @driver.execute_script("return $N.test.deviceProfileSuccess;")
end

Then /^device information is not sent to UAV$/ do
  fail "Device information was sent to the UAV" if @driver.execute_script("return $N.test.deviceProfileSuccess;")
end

Given /^device information sent to the UAV matches the device profile$/ do
  device_info = @driver.execute_script("return JSON.parse($N.test.deviceProfileData)")
  app_version = @driver.execute_script("return $U.core.version.Version.UI_VERSION")

  fail "OS.type does not match expected" if not device_info["deviceinformation"]["os"]["type"] == "Test OS"
  fail "OS.version does not match expected" if not device_info["deviceinformation"]["os"]["version"] == "Test OS Version"

  fail "CPU.cores does not match expected" if not device_info["deviceinformation"]["cpu"]["cores"] == 7500
  fail "CPU.freqency does not match expected" if not device_info["deviceinformation"]["cpu"]["frequency"] == 124

  fail "GPU.cores does not match expected" if not device_info["deviceinformation"]["gpu"]["cores"].nil?
  fail "GPU.frequency does not match expected" if not device_info["deviceinformation"]["gpu"]["frequency"].nil?
  fail "GPU.model does not match expected" if not device_info["deviceinformation"]["gpu"]["model"] == "Test model"

  fail "Device.manufacturer not as expected" if not device_info["deviceinformation"]["device"]["manufacturer"] == "Test Manufacturer"
  fail "Device.model not as expected" if not device_info["deviceinformation"]["device"]["model"] == "Test Model"
  fail "Device.type not as expected" if not device_info["deviceinformation"]["device"]["type"] == "Test Type"

  fail "Screen.density not as expected" if not device_info["deviceinformation"]["screen"]["density"].nil?
  fail "Screen.height not as expected" if not device_info["deviceinformation"]["screen"]["height"] == 132
  fail "Screen.width not as expected" if not device_info["deviceinformation"]["screen"]["width"] == 114

  fail "Application.name not as expected" if not device_info["deviceinformation"]["applicationinformation"]["name"] == "WLA_TEST"
  fail "Application.version not as expected" if not device_info["deviceinformation"]["applicationinformation"]["version"] == app_version

  fail "CodecType not as expected" if not device_info["deviceinformation"]["codectype"] == ["H264TEST", "AAC"]
  fail "StreamingType not as expected" if not device_info["deviceinformation"]["streamingtype"] == ["HLSTEST"]

  fail "DRM.provider does not match expected" if not device_info["deviceinformation"]["drm"][0]["provider"] == "PRMTEST"
  fail "DRM.version does not match expected" if not device_info["deviceinformation"]["drm"][0]["version"] == ""
end

##########################
# Delete Recommendations #
##########################

Given /^app is configured to fake a successful delete recommendations request$/ do
  @driver.execute_script("
    function XssRequestInterceptor(original) {
        var ctor = function(verb, url, success, failure) {
            if(verb !== \"DELETE\" || url.indexOf(\"/contentdiscovery/\") === -1) {
                original.call(this, verb, url, success, failure);
                this.__proto__ = original.prototype;
            } else {
              this.success = success;
            }
        }
        ctor.prototype.send = function(data) {
        var me = this;
        setTimeout(function() { me.success('')}, 5000);
      }
      ctor.prototype.setRequestHeader = function(){};
      ctor.prototype.setTimeout = function(){};
      ctor.prototype.abort = function(){};
      ctor.prototype.setContentType = function(){};
      return ctor;
    }
    $N.apps.core.XssRequest = XssRequestInterceptor($N.apps.core.XssRequest);
  ")
end

Given /^app is configured to fake an unsuccessful delete recommendations request$/ do
  @driver.execute_script("
    function XssRequestInterceptor(original) {
      var ctor = function(verb, url, success, failure) {
        if(verb !== \"DELETE\" || url.indexOf(\"/contentdiscovery/\") === -1) {
          original.call(this, verb, url, success, failure);
          this.__proto__ = original.prototype;
        } else {
          this.failure = failure;
        }
      }
      ctor.prototype.send = function(data) {
        var me = this;
        setTimeout(function() {me.failure({message: '', error: null, httpStatus: 500, responseText: 'Invalid response'})}, 5000);
      }
      ctor.prototype.setRequestHeader = function(){};
      ctor.prototype.setTimeout = function(){};
      ctor.prototype.abort = function(){};
      ctor.prototype.setContentType = function(){};
      return ctor;
    }
    $N.apps.core.XssRequest = XssRequestInterceptor($N.apps.core.XssRequest);
  ")
end

###################
# Promotion fakes #
###################

Given /^interceptor is configured to intercept Promotions Percentage requests$/ do
  load_script(@driver, "js/PromotionsPercentage.js")
end

Given /^interceptor is configured to intercept Promotions Final Price requests$/ do
  load_script(@driver, "js/PromotionsFinalPrice.js")
end

Given /^interceptor is configured to intercept ACL no VOD Purchased requests$/ do
  load_script(@driver, "js/ACLNoVodPurchased.js")
end

Given /^interceptor is configured to intercept ACL Charlie And The Chocolate Factory Always Purchased requests$/ do
  load_script(@driver, "js/ACLCharlieAlwaysPurchased.js")
end

Given /^interceptor is configured to intercept promotion purchase requests$/ do
  load_script(@driver, "js/PromotionPurchaseRequest.js")
end

Then /^promotion information is sent with the purchase request$/ do
  wait.until { @driver.execute_script("return $N.test.promoPurchaseSuccess;") }
end
#########################
#   NPVR Multi Locale   #
#########################

Given /^interceptor is configured to intercept NPVR requests$/ do
  load_script(@driver, "js/NpvrMultiLocale.js")
end

#######################
# Multi-pricing fakes #
#######################

Given /^fake multipricing data is setup$/ do
  load_script(@driver, "js/MultiPricing.js")
end

##########################
# Static recommendations #
##########################

Given /^fake static recommendations data is setup$/ do
  load_script(@driver, "js/StaticRecommendations.js")
end

##############
# SOCU fakes #
##############

# This sets up the interceptor to return a fake SOCU asset
# The asset has a programme
Given /^a fake SOCU asset is setup with contentRef$/ do
  load_script(@driver, "js/SOCU_contentRef.js")
end

# This sets up the interceptor to return a fake SOCU asset
# The asset has a programmeId, but not contentRef
Given /^a fake SOCU asset is setup with programId$/ do
  load_script(@driver, "js/SOCU_programId.js")
end

# This sets up the interceptor to return a fake SOCU asset
# The asset has no contentRef or programmeId
Given /^a fake SOCU asset is setup$/ do
  load_script(@driver, "js/SOCU.js")
end

def wait_for_src
  src = ""
  wait.until {
    src = @driver.execute_script('return $U.core.Player.player.src;')
    # src may be " " initially
    src.length > 1
  }
  return src
end

Then /^the SOCU asset is played by ContentRef$/ do
  src = wait_for_src()

  # Check the player's src is
  if src != "http://nagra.com/contentRef.m3u8"
    fail "Src URL did not match supplied regular expression: #{src}"
  end
end

Then /^the SOCU asset is played by ProgramId$/ do
  src = wait_for_src()

  # Check that the URL has been constructed in the form
  # http://host/path/index.m3u8?start=<start>&end=<end>
  if src != "http://nagra.com/programId.m3u8"
    fail "Src URL did not match supplied regular expression: #{src}"
  end
end

Then /^the SOCU asset is played by generated URL$/ do
  src = wait_for_src()

  # Check that the URL has been constructed correctly
  if not /^http:\/\/nmp.nagra.com\/live\-channels\/03\/index\-timeshifting\.m3u8\?startTime\=[0-9]+\&stopTime\=[0-9]+$/.match(src)
    fail "Src URL did not match supplied regular expression: #{src}"
  end
end

#########################
# Time management fakes #
#########################

Given /^time is stopped at ([0-9]+) hours$/ do |hours|
  load_script(@driver, "js/MockDate.js");
  @driver.execute_script(
    "var time = new Date();
     // Set time to 12pm
     time.setHours(#{hours.to_i}, 0, 0, 0);
     window.timeManager = new window.TimeManager(time.getTime());
     window.Date = window.MockDate(window.Date, window.timeManager);"
  )
end

When /^time advances ([0-9.]+) minute(?:s)?$/ do |time|
  @driver.execute_script("window.timeManager.advanceTime( #{time.to_f * 60*1000} );")
end

#############
# EPG fakes #
#############

Given /^fake EPG data for playlists is loaded$/ do
  load_script(@driver, "js/PlaylistEPG.js")
end

Given /^fake EPG data for playlists is loaded \(cwmciwla\)$/ do
  load_script(@driver, "js/PlaylistEPGCwmciwla.js")
end

Given /^all events are marked as catchup and startover$/ do
  load_script(@driver, "js/SOCU_events.js")
end

########################
# Fake purchase states #
########################

Given /^all assets have a zero price$/ do
  load_script(@driver, "js/FreeAssets.js")
end

# Configures the ACL to globally set asset purchase status
Given /^app is configured to return assets as (.*?)$/ do |purchase_status|
  case purchase_status
  when "none"
    set_always_purchased("false")
    set_always_subscribed("false")
  when "purchased"
    # Order is important here
    set_always_subscribed("false")
    set_always_purchased("true")
  when "subscribed"
    # Order is important here
    set_always_purchased("false")
    set_always_subscribed("true")
  when "purchased_and_subscribed"
    set_always_purchased("true")
    set_always_subscribed("true")
  else
    raise 'Illegal purchase status'
  end
end

def set_always_purchased(is_purchased)
  @driver.execute_script("
    $N.services.sdp.ACLHelper.prototype.isEditorialPurchased = function() {
      return " + is_purchased + ";
    };
    $N.services.sdp.ACLHelper.prototype.isTechnicalPurchased = function() {
      return " + is_purchased + ";
    };
    $N.services.sdp.ACLHelper.prototype.isProductPurchased = function() {
      return " + is_purchased + ";
    };
    $N.services.sdp.ACLHelper.prototype.isEditorialAcquired = function() {
      return " + is_purchased + ";
    };
    $N.services.sdp.ACLHelper.prototype.isTechnicalAcquired = function() {
      return " + is_purchased + ";
    };
    $N.services.sdp.ACLHelper.prototype.isProductAcquired = function() {
      return " + is_purchased + ";
    };
  ")
end

def set_always_subscribed(is_subscribed)
  @driver.execute_script("
    $N.services.sdp.ACLHelper.prototype.isEditorialSubscribed = function() {
      return " + is_subscribed + ";
    },
    $N.services.sdp.ACLHelper.prototype.isTechnicalSubscribed = function() {
      return " + is_subscribed + ";
    }
    $N.services.sdp.ACLHelper.prototype.isProductSubscribed = function() {
      return " + is_subscribed + ";
    },
    $N.services.sdp.ACLHelper.prototype.isEditorialAcquired = function() {
      return " + is_subscribed + ";
    };
    $N.services.sdp.ACLHelper.prototype.isTechnicalAcquired = function() {
      return " + is_subscribed + ";
    };
    $N.services.sdp.ACLHelper.prototype.isProductAcquired = function() {
      return " + is_subscribed + ";
    };
  ")
end


#######################################
# BTV device sensitive license checks #
#######################################

Given /^BTV services are returned with products$/ do
  load_script(@driver, "js/FakeDSLCServices.js")
end

#########################
# License Manager fakes #
#########################

# Overrides the licenseManager refreshLicenses method to set properties in the $N.test namespace
Given /^app is configured with a fake licenseManager refreshLicenses method$/ do
  @driver.execute_script("
    $N.platform.output.LicenseManager.prototype.refreshLicenses = function(downloads, continueLoad) {
      $N.test.refreshLicenses = {};
        if (downloads) {
          $N.test.refreshLicenses.downloadsLength = downloads.length
        }
        continueLoad();
      };
    ")
end

# Overrides the licenseManager eraseLicensesForDownloads method to set properties in the $N.test namespace
Given /^app is configured with a fake licenseManager eraseLicensesForDownloads method$/ do
  @driver.execute_script("
    $N.platform.output.LicenseManager.prototype.eraseLicensesForDownloads = function(downloads, continueLoad) {
      $N.test.eraseLicensesForDownloads = {
        downloadsLength: downloads.length
      };
      continueLoad();
    };
  ")
end

Then /^licenses are refreshed for ([0-9]+) downloads$/ do |num|
  fail "Licenses not refreshed on app launch" if not @driver.execute_script("return $N.test.refreshLicenses && $N.test.refreshLicenses.downloadsLength === " + num + ";")
end

Then /^licenses are erased for ([0-9]+) downloads$/ do |expected_num_downloads|
  if expected_num_downloads == "0"
    fail "eraseLicensesForDownloads was called unexpectedly" if @driver.execute_script("return $N.test.eraseLicensesForDownloads;")
  else
    fail "Number of erased licenses not as expected" if not @driver.execute_script("return $N.test.eraseLicensesForDownloads.downloadsLength === " + expected_num_downloads + ";")
  end
end

##########################
# Online / Offline fakes #
##########################

# Configures the network connection check to return false
Given /^app is configured to check for offline$/ do
  set_offline_mode()
end

# Overrides the checkNetworkConnection function to execute callback with false
def set_offline_mode()
  @driver.execute_script("
    $U.core.ConnectionChecker.checkNetworkConnection = function(callback) {
      callback(false);
    };
  ")
end

###############
# DL2GO fakes #
###############

Given /^app is configured to reach ([60-1000]+) free space$/ do |free_space|
    @driver.execute_script("$N.test.fakes.DownloadAgent.availableFreeSpace = " + free_space + ";")
end

# Configures the application to automatically load the fake downloadAgent from $N.test.fakes
Given /^DL2GO is configured with a stub downloadAgent$/ do
  set_config("FAKES", "{}")
  set_config("FAKES.DOWNLOAD_AGENT", "true")
  set_config("DL2GO.useDownloadAgentStub", "true")
end

Given /^DL2GO is configured to always allow downloads$/ do
  set_config("DL2GO.alwaysAllowDownload", "true")
end

When /^download agent state is saved$/ do
  @driver.execute_script("$N.test.fakes.DownloadAgent._saveState();")
end

##############
# Misc fakes #
##############

# Sets up a fake quit method on window.userAgent
# On execution, sets $N.test.results.HAS_QUIT to true
Given /^app is configured with a fake quit method$/ do
  @driver.execute_script("window.userAgent = {
      quit: function() {$N.test.results = $N.test.results || {}; $N.test.results.HAS_QUIT = true;},
      addEventListener: function() {}
    };")
end

Then /^the application has been quit$/ do
  fail "Application did not call window.userAgent.quit method when expected" unless @driver.execute_script("return $N.test.results.HAS_QUIT;")
end
