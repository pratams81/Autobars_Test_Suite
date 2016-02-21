#############################
# Application Configuration #
#############################

# Configure the application for direct mode signon using the OTT /integration/ lab
# Only valid for use with /integration/ configuration
Given /^app is configured for Direct Mode signon$/ do
  # TODO: Update direct mode URL when non-centralised PRM available
  set_config_string("DIRECT_MODE_URL", "http://prm-central.mspu.hq.k.grp:8080")
  set_config("DIRECT_MODE_SIGNON", "true")

  set_config("UPGRADE_MANAGER_CONFIG", "{}")
  set_config("UPGRADE_MANAGER_CONFIG.APP_DATA", "null")
  set_config_string("UPGRADE_MANAGER_CONFIG.URL", "cwmciwla-srv02.cwm.mspu.hq.k.grp/Upgrade")
end

# Configure the application to enable static recommendations
Given /^app is configured for static recommendations$/ do
  set_config("RECOMMENDATIONS", "$U.core.Configuration.RECOMMENDATIONS || {}")
  set_config("RECOMMENDATIONS.STATIC", "true")
end

# Configure the application to enable dynamic recommendations
Given /^app is configured for dynamic recommendations$/ do
  set_config("RECOMMENDATIONS", "$U.core.Configuration.RECOMMENDATIONS || {}")
  set_config("RECOMMENDATIONS.DYNAMIC", "true")
  set_config("RECOMMENDATIONS.FOR_ME", "true")
end

# Configure the application to enable multi-audio language
Given /^app is configured for multi audio language$/ do
  set_config("SUPPORT_MULTI_LANGUAGE", "$U.core.Configuration.SUPPORT_MULTI_LANGUAGE || {}")
  set_config("SUPPORT_MULTI_LANGUAGE.SUPPORT", "function() { return true; }")
  set_config("SUPPORT_MULTI_LANGUAGE.LANGUAGES", "[{name : 'Default', code : ''},{name : 'English', code : 'en'},{name : 'German', code : 'de'}]")
end

# Configure the application to not require the player/plugin
Given /^app is configured for noplayer mode$/ do
  set_config("FORCE_HTML", "true")
end

Given /^app is configured without noplayer mode$/ do
  set_config("FORCE_HTML", "false")
end

# Configure the application for paging
Given /^app is configured with paging size equal to (\d+)$/ do |paging_size|
  set_config("ASSET_PAGE_SIZE", paging_size)
end

# Configure the application with a max asset tiles value
Given /^app is configured to display at most (\d+) tiles$/ do |max_asset_tiles|
  set_config("MAX_ASSET_TILES", max_asset_tiles)
end

# Configure the application with a different FEATURED catalog.
# Hardcoded 100 ASSETS.
# To be modified in the future.
Given /^app is configured with featured catalog "100 ASSETS"$/ do
  CONFIG = "getFeatured"
  VALUE = "function() {return {id:'$FEATURED', name: $U.core.util.StringHelper.getString('txtFeatured'), aliasedId: 'B1_100ASSETS'}}"
  set_config(CONFIG, VALUE)
end

# Configure the application to enable PPAPI
Given /^app is configured for PPAPI$/ do
  set_config("PPAPI_CONFIG", "$U.core.Configuration.PPAPI || {}")
  set_config("PPAPI_CONFIG.ENABLED", "true")
  set_config("PPAPI_CONFIG.CHROME_VERSION", 39);
  set_config("PPAPI_CONFIG.INLINE_INSTALL", "false");
  # TODO: Make this configurable (probably in the rakefile)
  set_config_string("PPAPI_CONFIG.EXTENSION_ID", "coihfoohbjbmcloaabhokjmbcdnfbloo")

  set_config("JSFW", "$U.core.Configuration.JSFW || {}")
  set_config("JSFW.PPAPI", "$U.core.Configuration.PPAPI")
end

# Configure the application for PPAPI inline install
Given /^app is configured for PPAPI inline install$/ do
  set_config("PPAPI_CONFIG", "$U.core.Configuration.PPAPI || {}")
  set_config("PPAPI_CONFIG.ENABLED", "true")
  set_config("PPAPI_CONFIG.INLINE_INSTALL", "true")
end

# Enable standard DL2GO features
Given /^app is configured for DL2GO$/ do
  set_config("DL2GO", "{}")
  set_config("DL2GO.enabled", "true")
  set_config("DL2GO.useDownloadAgentStub", "false")
  set_config("DL2GO.licenseRefreshWindow", "144")
  set_config("DL2GO.appCache", "false")
  set_config("DL2GO.allowMobileDownload", "true")
end

#DL2GO desktop true/false
Given /^dl2go is set to (enabled|disabled)$/ do |dl2go_flag|
  case dl2go_flag
    when "enabled"
      dl2go_flag = true
    when "disabled"
      dl2go_flag = false
  end
  set_config("DL2GO", "{}")
  set_config("DL2GO.enabled", dl2go_flag)
end

#DL2GO desktop features
Given /^the app is configured for DL2GO desktop$/ do
  step "app is configured for DL2GO"
  step "Operator Allow Mobile Download is set to false"
  step "dl2go desktop is set to enabled"
  step "the DL2GO desktop crossTab is set to enabled"
  step "the DL2GO desktop secondaryTab is set to disabled"
  step "the nmpcDownloadUrl for DL2GO desktop is set to \"http://www.google.com/\""
  step "DL2GO is configured with a stub downloadAgent"
end

#DL2GO desktop true/false
Given /^dl2go desktop is set to (enabled|disabled)$/ do |desktop_flag|
  case desktop_flag
    when "enabled"
      desktop_flag = true
    when "disabled"
      desktop_flag = false
  end
  set_config("DL2GO.DESKTOP", "{}")
  set_config("DL2GO.DESKTOP.enabled", desktop_flag)
end

#DL2GO desktop download crosstab is true/false
Given /^the DL2GO desktop crossTab is set to (enabled|disabled)$/ do |desktop_crosstab_flag|
  case desktop_crosstab_flag
    when "enabled"
      desktop_crosstab_flag = true
    when "disabled"
      desktop_crosstab_flag = false
  end
  set_config("DL2GO.DESKTOP.crossTab", desktop_crosstab_flag)
end

#DL2GO desktop Download To Go App url path
Given /^the nmpcDownloadUrl for DL2GO desktop is set to "(.*?)"$/ do |url|
  set_config_string("DL2GO.DESKTOP.nmpcDownloadUrl", url)
end

#DL2GO desktop Download To Go App url path
Given /^the DL2GO desktop secondaryTab is set to (enabled|disabled)$/ do |secondarytab_flag|
case secondarytab_flag
    when "enabled"
      secondarytab_flag = true
    when "disabled"
      secondarytab_flag = false
  end
  set_config("DL2GO.DESKTOP.secondaryTab", secondarytab_flag)
end

#DL2GO desktop Download standalone
Given /^dl2go desktop standalone is set to (true|false)$/ do |desktop_standalone_flag|
  set_config("DL2GO.DESKTOP.standAlone", desktop_standalone_flag)
end

#DL2GO desktop Allow Mobile Download
And /^Operator Allow Mobile Download is set to (true|false)$/ do |allow_mobile|
  set_config("DL2GO.allowMobileDownload", allow_mobile)
end

#DL2GO desktop authorised parental ratings
Given(/^the DL2GO parental rating is set to "([^"]*)"$/) do |authorised_rating|
  if authorised_rating == "U"
    set_config("D2G_APP_AUTHORISED_RATING", 0)
  elsif authorised_rating == "PG"
    set_config("D2G_APP_AUTHORISED_RATING", 6)
  elsif authorised_rating == "12"
    set_config("D2G_APP_AUTHORISED_RATING", 13)
  elsif authorised_rating == "15"
    set_config("D2G_APP_AUTHORISED_RATING", 16)
  elsif authorised_rating == ""
    set_config("D2G_APP_AUTHORISED_RATING", 76)
  end
end

# Enable standard EULA features
Given /^app is configured to display eula$/ do
  set_config("EULA", "{}")
  set_config("EULA.enabled", "true")
  set_config_string("EULA.versionFileUrl", "appInstalled")
  set_config_string("EULA.eulaFileUrl", "appInstalled")
  set_config_string("EULA.declineUrl", "http://www.nagra.com/")
end

# Configure to load a different EULA version
And /^a different eula version has been set$/ do
  set_config_string("EULA.versionFileUrl", "nmp.html")
end

# Set a config value in the WLA configuration ($U.core.Configuration)
# @param [String, #read] config The config parameter to set, e.g. "ASSET_PAGE_SIZE"
# @param [String, #read] value The value of the parameter to set, e.g. "50"
def set_config(config, value)
  @driver.execute_script("$U.core.Configuration.#{config} = #{value};")
end

# Set a config value in the WLA configuration ($U.core.Configuration)
# Additionally enclosing the supplied value in double quotes
# @param [String, #read] config The config parameter to set, e.g. "VIDEO_PATH"
# @param [String, #read] value The value of the parameter to set, e.g. "http://ott.nagra.com/stable/videopath/"
def set_config_string(config, value)
  @driver.execute_script("$U.core.Configuration.#{config} = \"#{value}\";")
end

# Configure the application to configure VOD view option/ Content filter option
Given /^app is configured with (ALL|VIEWABLE) content filter option$/ do |vod_view_option|
   set_config_string("DEFAULT_VOD_VIEW", vod_view_option)
end

##########################
# Headend configurations #
##########################

# Configure the application to work with the cwmciwla lab
Given /^app is configured for cwmciwla lab$/ do
  set_config_string("SDP_CONFIG.URL", "cwmciwla-srv02.cwm.mspu.hq.k.grp")
  set_config_string("SDP_CONFIG.PATH", "/qsp/gateway/http/js")

  set_config_string("MDS_CONFIG.MDS_URL", "cwmciwla-srv02.cwm.mspu.hq.k.grp")
  set_config_string("MDS_CONFIG.MDS_PATH", "/metadata/delivery")
  set_config_string("MDS_CONFIG.SERVICE_PROVIDER", "GLOBAL")

  set_config_string("LOCKER_CONFIG.URL", "cwmciwla-srv02.cwm.mspu.hq.k.grp")
  set_config_string("LOCKER_CONFIG.PORT", "")
  set_config_string("LOCKER_CONFIG.SERVICE_PATH", "api/npvrlocker/v1")
  set_config("LOCKER_CONFIG.SECURITY", false)
  set_config_string("LOCKER_CONFIG.PROVIDER", "GLOBAL")

  set_config_string("VIDEO_PATH", "http://cwm-cis-cdn.cwm.mspu.hq.k.grp/cdn/")
  set_config_string("TRAILER_VIDEO_PATH", "http://cwm-cis-cdn.cwm.mspu.hq.k.grp/cdn/")
  set_config("VIDEO_ENCODER", "$N.Config.VIDEO_ENCODERS.ENVIVIO")

  set_config("JSFW.USE_CONTEXT_DEVICE_TYPE", false)
  set_config("DEVICE_NAME_LIST", "{}")
  set_config("DEVICE_NAME_LIST.tablet", "null")
  set_config("DEVICE_NAME_LIST.phone", "null")
  set_config("DEVICE_NAME_LIST.pc", "null")

  set_config("getFeatured", 'function () {
    return {
      id: "$FEATURED",
      name: $U.core.util.StringHelper.getString("txtFeatured"),
      aliasedId: "HOTPICKS"
    };
  }')

  # TODO: Move to app is started once test_e2e is default config
  step "player has been configured with version \"NagraQA.3.9.0\""
end


# Configure the application to work with the OTT /integration/ lab
Given /^app is configured for integration lab$/ do
  set_config_string("SDP_CONFIG.URL", "ott.nagra.com/integration/ml27")
  set_config_string("SDP_CONFIG.PATH", "/qsp/gateway/http/js")
  set_config_string("MDS_CONFIG.MDS_URL", "ott.nagra.com/integration/ml27")
  set_config_string("MDS_CONFIG.MDS_PATH", "/metadata/delivery")
  set_config_string("MDS_CONFIG.SERVICE_PROVIDER", "CMS4X")

  set_config("DEVICE_NAME_LIST", "{}")
end

# Configure the application to work with the OTT /latest/ lab
Given /^app is configured for latest lab$/ do
  set_config_string("SDP_CONFIG.URL", "ott.nagra.com/latest")
  set_config_string("SDP_CONFIG.PATH", "/qsp/gateway/http/js")
  set_config_string("MDS_CONFIG.MDS_URL", "ott.nagra.com/latest")
  set_config_string("MDS_CONFIG.MDS_PATH", "/metadata/delivery")
  set_config_string("MDS_CONFIG.SERVICE_PROVIDER", "CMS4X")

  set_config("DEVICE_NAME_LIST", "{}")
  set_config("DEVICE_NAME_LIST.tablet", "null")
  set_config("DEVICE_NAME_LIST.phone", "null")
  set_config("DEVICE_NAME_LIST.pc", "null")
end

# Configure the application to work with the OTT /stable/ lab
Given /^app is configured for stable lab$/ do
  set_config_string("SDP_CONFIG.URL", "ott.nagra.com/stable")
  set_config_string("SDP_CONFIG.PATH", "/qsp/gateway/http/js")
  set_config_string("MDS_CONFIG.MDS_URL", "ott.nagra.com/stable")
  set_config_string("MDS_CONFIG.MDS_PATH", "/metadata/delivery")
  set_config_string("MDS_CONFIG.SERVICE_PROVIDER", "B1")
end

# Configure the npvr rolling buffer to X hours
Given /^npvr buffer duration is configured to (\d+) hours$/ do |duration|
  set_config("RECORDING_BUFFER_DURATION", duration.to_i)
end

# Configure the application to work with the LOCAL npvrLocker lab
Given /^app is configured for local npvr lab$/ do
  port = ENV['AUGMENTATOR_PORT']

  set_config_string("SDP_CONFIG.URL", "localhost:#{port}")
  set_config_string("SDP_CONFIG.PATH", "/dummy")
  set_config_string("MDS_CONFIG.MDS_URL", "localhost/")
  set_config_string("MDS_CONFIG.MDS_PATH", "dummy")
  set_config_string("MDS_CONFIG.MDS_PORT", port)
  set_config_string("MDS_CONFIG.SERVICE_PROVIDER", "DUMMY")

  set_config_string("NPVR_ENABLED", "true")
  set_config_string("NPVR_SERIES_ENABLED", "true")

  set_config_string("LOCKER_CONFIG.URL", "localhost")
  set_config_string("LOCKER_CONFIG.PORT", port)
  set_config_string("LOCKER_CONFIG.PROVIDER", "LAB")
end

# Configure MDS filters for PUBLISH_TO_USER_DEVICES_STATUS
 Given /^app is configured for (DISABLED||SHOW_PUBLISHED||HIDE_PUBLISHED) MDS filter/ do |device_status|
  @driver.execute_script ("$U.core.Configuration.MDS_CONFIG.FILTER.PUBLISH_TO_USER_DEVICES_STATUS = function(){return $N.services.sdp.MetadataService.PUBLISH_TO_USER_DEVICES_STATUS." + device_status + "; };")
 end

#########################
# Change Network config #
#########################

Given /^network is set to (3G|wifi|offline)$/ do |network_config|
  @driver.execute_script("window.onoffline();")

  if network_config == "3G"
    @driver.execute_script("window.navigator.connection = {type: '3g'};")
  elsif network_config == "wifi"
    @driver.execute_script("window.navigator.connection = undefined;")
  else
    @driver.execute_script("window.navigator.connection = undefined;")
  end

  @driver.execute_script("window.ononline();")
end

# Configure the application to enable SDP Device Type configuration
Given /^app is configured for SDP context device types$/ do
  set_config("JSFW", "$U.core.Configuration.JSFW || {}")
  set_config("JSFW.USE_CONTEXT_DEVICE_TYPE", "$U.core.Configuration.JSFW.USE_CONTEXT_DEVICE_TYPE || {}")
  set_config("JSFW.USE_CONTEXT_DEVICE_TYPE", "true")
end

Given /^app is configured for Configuration context device types$/ do
  set_config("JSFW", "$U.core.Configuration.JSFW || {}")
  set_config("JSFW.USE_CONTEXT_DEVICE_TYPE", "$U.core.Configuration.JSFW.USE_CONTEXT_DEVICE_TYPE || {}")
  set_config("JSFW.USE_CONTEXT_DEVICE_TYPE", "false")
end

# Test the SDP Device Type configuration is on
Then /^SDP context device type exists$/ do
  result = @driver.execute_script("return $U.core.Configuration.JSFW.USE_CONTEXT_DEVICE_TYPE")
  fail "SDP context device type returned a falsey value when not expected" if not result
end

# Test the SDP Device Type configuration is off
Then /^SDP context device type does not exist$/ do
  result = @driver.execute_script("return $U.core.Configuration.JSFW.USE_CONTEXT_DEVICE_TYPE")
  fail "SDP context device type returned a truthy value when not expected" if result
end

# Configure the application to work with the LOCAL npvrLocker lab
Given /^app is configured for local MDS override$/ do
  port = ENV['AUGMENTATOR_PORT']
  set_config_string("MDS_CONFIG.MDS_PATH", "dummy")
  set_config_string("MDS_CONFIG.MDS_PORT", port)
  set_config_string("MDS_CONFIG.SERVICE_PROVIDER", "DUMMY")
end

Given /^player has been configured with version "(.*)"$/ do |ver|
  # If the property doesn't exist already, we'll set it
  @driver.execute_script(
    "if (!$N.env.playerVersion) {
       Object.defineProperty($N.env, 'playerVersion', {
         get: function() {
           return \"#{ver}\";
         },
         set: function(x) {
           // Do nothing!!!
         },
         configurable: true
       });
     }")
end

######################
# Session management #
######################

Given /^app is configured to use (SRM|OTT) session management$/ do |type|
  set_config("SDP_CONFIG.SESSION_MANAGER", "$N.services.sessionmanagement.#{type}Session")
end


#########################
# Device Type Profiling #
#########################

Given /^app is configured for device type profiling$/ do
  set_config("UAV", "{}")
  set_config("UAV.SEND_DEVICE_INFO", "true")
  set_config_string("UAV.APP_NAME", "WLA_TEST")
  set_config_string("UAV.URL", "nagra.uav.stub")
  set_config("UAV.PORT", "3000")
  set_config_string("UAV.SERVICE_PATH", "useractivity")
  set_config("UAV.HTTPS", "false")
end

##############
# Promotions #
##############
Given /^app is configured to enable promotions$/ do
  set_config("PROMOTIONS.ENABLED", true)
  set_config("JSFW.PROMOTIONS", true)
  set_config("ASSET_TILE_TEXT_STRAP.PROMOTION", true)
end

Given /^app is configured to show free promotions$/ do
  set_config("ASSET_TILE_TEXT_STRAP.FREE", true)
end

###############
# Portal page #
###############

Given /^the app is configured to enable the portal screen$/ do
  set_config("PORTAL_SCREEN.ENABLED", true)
  set_config("PORTAL_SCREEN.CAROUSEL_OPTIONS.autoplay", false)
end

Given /^the portal page is configured to display arrows$/ do
  set_config("PORTAL_SCREEN.CAROUSEL_OPTIONS.arrows", true)
end

Given /^the portal page is configured to autoplay$/ do
  set_config("PORTAL_SCREEN.CAROUSEL_OPTIONS.autoplay", true)
  set_config("PORTAL_SCREEN.CAROUSEL_OPTIONS.autoplaySpeed", 20_000)
end

#####################
# NPVR Multi Locale #
#####################

Given /^app is configured npvr$/ do
  set_config("NPVR_ENABLED", true)
  set_config("NPVR_SERIES_ENABLED", true)
end

#################
# Multi-pricing #
#################

Given /^app is configured for multipricing$/ do
  set_config("MULTI_PRICING_ENABLED", true)
end

#####################
# Anonymous browing #
#####################

Given /^anonymous browsing is enabled$/ do
  set_config("ANONYMOUS_BROWSE", {})
  set_config("ANONYMOUS_BROWSE.ENABLED", true)
end

Given /^anonymous browsing is disabled$/ do
  set_config("ANONYMOUS_BROWSE", {})
  set_config("ANONYMOUS_BROWSE.ENABLED", false)
end

Then (/^anonymous browsing default parental rating is "([^"]*)"$/) do |defaultparentalrating|
    set_config("ANONYMOUS_BROWSE.DEFAULT_PARENTAL_RATING", defaultparentalrating.to_i)
end

When(/^app is reconfigured to the anonymous background$/) do
  step "the initial loading animation is shown"
  step "the interceptor is loaded"
  step "anonymous browsing is enabled"
  step "anonymous browsing default parental rating is \"72\""
  step "app is started"
  step "browse screen is displayed"
end

When(/^app is reconfigured to anonymous mode with DL2GO, Playlist, Catchup and NPVR/) do
  step "the initial loading animation is shown"
  step "the interceptor is loaded"
  step "anonymous browsing is enabled"
  step "anonymous browsing default parental rating is \"72\""
  step "app is configured npvr"
  step "interceptor is configured to intercept NPVR requests"
  step "catchup page is enabled"
  step "all events are marked as catchup and startover"
  step "app is configured for DL2GO"
  step "DL2GO is configured to always allow downloads"
  step "DL2GO is configured with a stub downloadAgent"
  step "playlists are enabled"
  step "app is started"
  step "browse screen is displayed"

end

When(/^app is reconfigured to the anonymous background with all assets configured as purchased$/) do
  step "the initial loading animation is shown"
  step "the interceptor is loaded"
  step "app is configured for cwmciwla lab"
  step "anonymous browsing is enabled"
  step "app is configured to return assets as purchased"
  step "app is started"
  step "browse screen is displayed"
end

When(/^app is started and configured for anonymous browsing$/) do
  step "anonymous browsing is enabled"
  step "app is started"
  step "browse screen is displayed"
end

When(/^default user is logged in non anonymous mode with zero price$/) do
  step "anonymous browsing is disabled"
  step "all assets have a zero price"
  step "app is started"
  step "login screen is displayed"
  step "\"nmp@nagra.com\" has logged into JoinIn with \"nmp\""
  step "browse screen is displayed"
end

When(/^default user is logged in non anonymous mode$/) do
  step "anonymous browsing is disabled"
  step "app is started"
  step "login screen is displayed"
  step "\"nmp@nagra.com\" has logged into JoinIn with \"nmp\""
  step "browse screen is displayed"
end

############
# Playlist #
############

Given /^playlists are enabled$/ do
  set_config("PLAYLIST_SCREEN.ENABLED", true)
  set_config("PLAYLIST_SCREEN.PLAYLIST_UPDATE_SECONDS", 5)
end


##################
# Catchup Screen #
##################

Given /^catchup page is enabled$/ do
  set_config("CATCHUP_SCREEN.ENABLED", true)
  set_config("CATCHUP_SCREEN.FAKE_DATA", true)
end

Given /^catchup page is disabled$/ do
  set_config("CATCHUP_SCREEN.ENABLED", false)
end

Given /^catchup span is configured to ([0-9]+) days$/ do |index|
  set_config("CATCHUP_SCREEN.SPAN",index)
end


###################################
# Device sensitive license checks #
###################################

Given /^BTV device sensitive license checks are enabled$/ do
  set_config("JSFW.BTV_DEVICE_SENS_CHECKS", true)
end