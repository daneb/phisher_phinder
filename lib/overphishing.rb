require "overphishing/version"

require 'maxmind/geoip2'

require 'sequel'
Sequel::Model.plugin :timestamps, update_on_create: true

require_relative './overphishing/cached_geoip_client'
require_relative './overphishing/geoip_ip_data'
require_relative './overphishing/enriched_ip'
require_relative './overphishing/enriched_ip_factory'
require_relative './overphishing/mail_parser'
require_relative './overphishing/mail'

module Overphishing
  class Error < StandardError; end
  # Your code goes here...
end
