#!/usr/bin/env ruby
#
#   check-arachni
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
class CheckArachni < Sensu::Plugin::Check::CLI

  include Sensu::Plugin::Utils

  option :url,
         short: '-u URL',
         long: '--url URL',
         description: 'A website URL to scan'

  def run
    if config[:url] && settings["arachni"]
      begin
        Timeout.timeout(nil) do
          run_arachni(settings["arachni"], config[:url])
        end
      rescue Timeout::Error
        critical 'Request timed out'
      rescue => e
        critical "Request error: #{e.message}"
      end
    else
      unknown 'No URL specified' unless config[:url]
      unknown 'No settings for arachni server' unless settings["arachni"]
    end
  end

  def run_arachni arachniSettings, websiteUri
    http = nil

    http = Net::HTTP.new(arachniSettings["host"], arachniSettings["port"])

    http.read_timeout = nil
    http.open_timeout = nil
    http.ssl_timeout = nil
    http.continue_timeout = nil
    http.keep_alive_timeout = nil

    req = Net::HTTP::Post.new("/", 'Content-Type' => 'application/json')
    req.body = {url: websiteUri}.to_json
    res = http.request(req)

    handle_response(res)
  end

  def handle_response(res)
    result = JSON.parse(res.body)
    case res.code
    when /^2/
      result = JSON.parse(res.body)

      if result["issues"].kind_of?(Array)
        criticals = result["issues"].select{ |issue| issue["severity"].eql? "high" }

        unless criticals.empty?
          warning("Vulnerabilities detected: #{criticals}")
        else
          ok("No vulnerabilitie detected")
        end
      else
        ok("No vulnerabilitie detected")
      end
    else
      critical("Status #{res.code}: #{res.body}")
    end
  end
end
