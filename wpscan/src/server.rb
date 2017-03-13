#!/usr/bin/env ruby

require "webrick"
require "json"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

class WPScanResult

  def initialize rawResult
    @rawOutput = rawResult
    @vulnerabilities = rawResult.lines.grep(/\[\!\].*Title:/){ |line| 
      line.sub(/^.*Title:/, '') 
    }
  end

  def to_json
    { 
      vulnerabilities: @vulnerabilities, 
      rawOutput: @rawOutput
    }.to_json
  end

end

class WPScanRunner

  def run(wordpressUrl)
    WPScanResult.new `/wpscan/wpscan.rb -u #{wordpressUrl} --update`
  end

end

class MyServlet < WEBrick::HTTPServlet::AbstractServlet

  def initialize server
    super server
    @wpScanRunner = WPScanRunner.new
  end

  def do_GET request, response
    if request.query["url"]
      url = request.query["url"]
      result = @wpScanRunner.run url
      response.content_type = "application/json"
      response.status = 200
      response.body = result.to_json
    else
      response.status = 400
      response.body = "You did not provide a wordpress url."
    end
  end

end

server = WEBrick::HTTPServer.new(:Port => 8080)

server.mount "/scan", MyServlet

trap("INT") {
  server.shutdown
}

server.start
