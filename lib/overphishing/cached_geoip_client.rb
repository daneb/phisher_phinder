# frozen_string_literal: true

module Overphishing
  class CachedGeoipClient
    def initialize(client)
      @client = client
      @lang = 'en'
    end

    def lookup(ip_address)
      lookup_result = @client.insights(ip_address)

      Overphishing::GeoipIpData.create(
        ip_address: ip_address,
        location_accuracy_radius: lookup_result.location.accuracy_radius,
        latitude: lookup_result.location.latitude,
        longitude: lookup_result.location.longitude,
        time_zone: lookup_result.location.time_zone,
        city_name: lookup_result.city.names[@lang],
        city_geoname_id: lookup_result.city.geoname_id,
        city_confidence: lookup_result.city.confidence,
        country_name: lookup_result.country.names[@lang],
        country_geoname_id: lookup_result.country.geoname_id,
        country_iso_code: lookup_result.country.iso_code,
        country_confidence: lookup_result.country.confidence,
        continent_name: lookup_result.continent.names[@lang],
        continent_geoname_id: lookup_result.continent.geoname_id,
        postal_code: lookup_result.postal.code,
        postal_code_confidence: lookup_result.postal.confidence,
        registered_country_name: lookup_result.registered_country.names[@lang],
        registered_country_geoname_id: lookup_result.registered_country.geoname_id,
        registered_country_iso_code: lookup_result.registered_country.iso_code,
        autonomous_system_organisation: lookup_result.traits.autonomous_system_organization,
        autonomous_system_number: lookup_result.traits.autonomous_system_number,
        isp: lookup_result.traits.isp,
        network: lookup_result.traits.network,
        organisation: lookup_result.traits.organization,
        static_ip_score: lookup_result.traits.static_ip_score,
        user_type: lookup_result.traits.user_type
      )
    end
  end
end
