# frozen_string_literal: true
require 'ipaddr'

module Overphishing
  class ExtendedIpFactory
    def initialize(geoip_client:)
      @geoip_client = geoip_client
    end

    def build(ip_string)
      ip = IPAddr.new(ip_string)

      if non_public_ip?(ip)
        SimpleIp.new(ip_address: ip)
      else
        ExtendedIp.new(ip_address: ip, geoip_ip_data: @geoip_client.lookup(ip_string))
      end
    rescue IPAddr::InvalidAddressError
    end

    private

    def non_public_ip?(ip)
      localhost_ip?(ip) ||
        ipv4_class_a_private?(ip) ||
        ipv4_class_b_private?(ip) ||
        ipv4_class_c_private?(ip)
    end

    def localhost_ip?(ip)
      ip.loopback?
    end

    def ipv4_class_a_private?(ip)
      IPAddr.new('10.0.0.1/8').include?(ip)
    end

    def ipv4_class_b_private?(ip)
      IPAddr.new('172.16.0.0/12').include?(ip)
    end

    def ipv4_class_c_private?(ip)
      IPAddr.new('192.168.0.0/16').include?(ip)
    end
  end
end
