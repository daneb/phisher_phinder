# frozen_string_literal: true

module Overphishing
  class EnrichedIpFactory
    def initialize(geoip_client:)
      @geoip_client = geoip_client
    end

    def build(ip_string)
      EnrichedIp.new(ip_address: ip_string, geoip_ip_data: @geoip_client.lookup(ip_string))
    end

    def good_input?(data)
    end
  end
end