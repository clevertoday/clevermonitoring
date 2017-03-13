#!/usr/bin/env ruby
#
#   check-wpscan
#
# DESCRIPTION:
#
# OUTPUT:
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   
# NOTES:
#
# LICENSE:
#   Copyright 2017 Clever Today, Inc <brice@clevertoday.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'sensu-plugin/utils'
require 'net/http'
require 'json'

#
# Check HTTP
#
class CheckWPScan < Sensu::Plugin::Check::CLI

  include Sensu::Plugin::Utils

  option :url,
         short: '-u URL',
         long: '--url URL',
         description: 'A WordPress URL to scan'

  option :timeout,
         short: '-t SECS',
         long: '--timeout SECS',
         proc: proc(&:to_i),
         description: 'Set the timeout',
         default: 15

  def run
    if config[:url] && settings["wpscan"]
      begin
        Timeout.timeout(config[:timeout]) do
          run_wpscan(settings["wpscan"], config[:url], config[:timeout])
        end
      rescue Timeout::Error
        critical 'Request timed out'
      rescue => e
        critical "Request error: #{e.message}"
      end
    else
      unknown 'No URL specified' unless config[:url]
      unknown 'No settings for wpscan server' unless settings["wpscan"]
    end
  end

  def run_wpscan wpScanSettings, wordpressUri, timeout
    http = nil

    http = Net::HTTP.new(wpScanSettings["host"], wpScanSettings["port"])

    http.read_timeout = timeout
    http.open_timeout = timeout
    http.ssl_timeout = timeout
    http.continue_timeout = timeout
    http.keep_alive_timeout = timeout

    req = Net::HTTP::Get.new("/scan?url=#{wordpressUri}")
    res = http.request(req)

    handle_response(res)
  end

  def handle_response(res)
    case res.code
    when /^2/
      result = JSON.parse(res.body)
      if result["vulnerabilities"] && !result["vulnerabilities"].empty?
        warning("Vulnerabilities detected: #{result["vulnerabilities"]}")
      else
        ok("No vulnerabilities detected")
      end
    else
      critical("Status #{res.code}: #{res.body}")
    end
  end
end
