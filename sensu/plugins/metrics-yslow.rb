#!/usr/bin/env ruby
#
#   metrics-yslow
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

require 'sensu-plugin/metric/cli'
require 'sensu-plugin/utils'
require 'net/http'
require 'json'

#
# YSlow Graphite
#
class YslowMetrics < Sensu::Plugin::Metric::CLI::Graphite

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
         default: 60

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.yslow"

  def run
    if config[:url] && settings["yslow"]
      begin
        Timeout.timeout(config[:timeout]) do
          run_yslow(settings["yslow"], config[:url], config[:timeout])
        end
      rescue Timeout::Error
        critical 'Request timed out'
      rescue => e
        critical "Request error: #{e.message}"
      end
    else
      unknown 'No URL specified' unless config[:url]
      unknown 'No settings for yslow server' unless settings["yslow"]
    end
  end

  def run_yslow yslowSettings, targetUri, timeout
    http = nil

    http = Net::HTTP.new yslowSettings["host"], yslowSettings["port"]

    http.read_timeout = timeout
    http.open_timeout = timeout
    http.ssl_timeout = timeout
    http.continue_timeout = timeout
    http.keep_alive_timeout = timeout

    req = Net::HTTP::Get.new "/?url=#{targetUri}"
    res = http.request req

    handle_response res
  end

  def handle_response res
    case res.code
    when /^2/
      report = JSON.parse(res.body)
      process_report report
    else
      critical "Status #{res.code}: #{res.body}"
    end
  end

  def process_report report
    output "#{config[:scheme]}.overall", report["o"]
    report["g"].each do |key, value|
      output "#{config[:scheme]}.#{key}", value["score"]
    end
    ok
  end

end
