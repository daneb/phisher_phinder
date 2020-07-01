# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Overphishing::EnrichedIpFactory do
  let(:geoip_client) { instance_double(Overphishing::CachedGeoipClient, lookup: geoip_ip_data) }
  let(:geoip_ip_data) { instance_double(Overphishing::GeoipIpData) }
  let(:ip_address_string) { '255.255.255.255' }

  subject { described_class.new(geoip_client: geoip_client) }

  it 'fetches ip information from the geoip client' do
    expect(geoip_client).to receive(:lookup).with(ip_address_string)

    subject.build(ip_address_string)
  end

  it 'instantiates an enriched ip instance' do
    ip = subject.build(ip_address_string)

    expect(ip).to eq(Overphishing::EnrichedIp.new(ip_address: ip_address_string, geoip_ip_data: geoip_ip_data))
  end
end
