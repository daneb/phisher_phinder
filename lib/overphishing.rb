require "overphishing/version"

require 'maxmind/geoip2'

require 'sequel'
Sequel::Model.plugin :timestamps, update_on_create: true

require_relative './overphishing/body_hyperlink'
require_relative './overphishing/cached_geoip_client'
require_relative './overphishing/geoip_ip_data'
require_relative './overphishing/expanded_data_processor'
require_relative './overphishing/extended_ip'
require_relative './overphishing/extended_ip_factory'
require_relative './overphishing/mail_parser'
require_relative './overphishing/mail'
require_relative './overphishing/simple_ip'
require_relative './overphishing/mail_parser/received_headers/parser'
require_relative './overphishing/mail_parser/received_headers/by_parser'
require_relative './overphishing/mail_parser/received_headers/classifier'
require_relative './overphishing/mail_parser/received_headers/for_parser'
require_relative './overphishing/mail_parser/received_headers/from_parser'
require_relative './overphishing/mail_parser/received_headers/starttls_parser'
require_relative './overphishing/mail_parser/received_headers/timestamp_parser'

module Overphishing
  class Error < StandardError; end
  # Your code goes here...
end
