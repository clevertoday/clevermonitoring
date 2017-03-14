#!/usr/bin/env ruby
#
#   check-yslow
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
class CheckYslow < Sensu::Plugin::Check::CLI

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

  option :overall,
         short: '-o SCORE',
         long: '--overall SCORE'

  option :no404,
         long: '--no404 SCORE'

  option :emptysrc,
         long: '--emptysrc SCORE'

  option :compress,
         long: '--compress SCORE'

  option :minify,
         long: '--minify SCORE'

  option :imgnoscale,
         long: '--imgnoscale SCORE'

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
      results = process_report report
      if results.empty?
        ok
      else
        warning "YSlow thresholds reached: #{results}"
      end
    else
      critical "Status #{res.code}: #{res.body}"
    end
  end

  def process_report report
    results = Array.new
    if config[:overall]
      results.push("Overall score is lower than #{config[:overall]}") if report["o"] < config[:overall].to_i
    end
    if config[:no404]
      results.push("No 404 score is lower than #{config[:no404]}") if report["g"]["yno404"]["score"] < config[:no404].to_i
    end
    if config[:emptysrc]
      results.push("Empty src score is lower than #{config[:emptysrc]}") if report["g"]["yemptysrc"]["score"] < config[:emptysrc].to_i
    end
    if config[:compress]
      results.push("Compress score is lower than #{config[:compress]}") if report["g"]["ycompress"]["score"] < config[:compress].to_i
    end
    if config[:minify]
      results.push("Minifiy score is lower than #{config[:minify]}") if report["g"]["yminify"]["score"] < config[:minify].to_i
    end
    if config[:imgnoscale]
      results.push("No scale score is lower than #{config[:imgnoscale]}") if report["g"]["yimgnoscale"]["score"] < config[:imgnoscale].to_i
    end
    results
  end

end
