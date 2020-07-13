require 'spec_helper'
require 'ipaddr'

RSpec.describe Overphishing::MailParser do
  let(:complete_mail_contents) { IO.read(File.join(FIXTURE_PATH, 'mail_1.txt')) }
  let(:simple_mail_contents) { IO.read(File.join(FIXTURE_PATH, 'mail_2.txt')) }
  let(:enriched_ip_1) { instance_double(Overphishing::ExtendedIp) }
  let(:enriched_ip_2) { instance_double(Overphishing::ExtendedIp) }
  let(:enriched_ip_3) { instance_double(Overphishing::ExtendedIp) }
  let(:enriched_ip_4) { instance_double(Overphishing::ExtendedIp) }
  let(:enriched_ip_5) { instance_double(Overphishing::ExtendedIp) }
  let(:enriched_ip_factory) do
    instance_double(Overphishing::ExtendedIpFactory).tap do |factory|
      allow(factory).to receive(:build) do |arg|
        case arg
        when '2002:a4a:d031:0:0:0:0:0'
          enriched_ip_1
        when '2002:a17:902:a706::'
          enriched_ip_2
        when '10.0.0.3'
          enriched_ip_3
        when '10.0.0.4'
          enriched_ip_4
        when '10.0.0.5'
          enriched_ip_5
        end
      end
      allow(factory).to receive(:good_input?) do |arg|
        case arg
        when 'mx.google.com'
          false
        else
          true
        end
      end
    end
  end
  let(:original_mail_body) { "This is the body\n" }
  let(:original_mail_headers) do
    "Delivered-To: dummy@test.com\n" +
    "Received: by 2002:a4a:d031:0:0:0:0:0 with SMTP id w17csp2701290oor;\n" +
    "        Sat, 25 Apr 2020 22:14:05 -0700 (PDT)"
  end
  let(:parsed_complete_mail) do
    described_class.new(enriched_ip_factory, ENV.fetch('LINE_ENDING_TYPE')).parse(complete_mail_contents)
  end
  let(:parsed_simple_mail) do
    described_class.new(enriched_ip_factory, ENV.fetch('LINE_ENDING_TYPE')).parse(simple_mail_contents)
  end
  let(:received_header_value) do
    "by 2002:a4a:d031:0:0:0:0:0 with SMTP id w17csp2701290oor; Sat, 25 Apr 2020 22:14:05 -0700 (PDT)"
  end

  describe 'parsing an email' do
    describe 'the parsed mail' do
      it 'provides access to the original text of the parsed email' do
        expect(parsed_simple_mail.original_email).to eql simple_mail_contents
      end

      it 'separates the original headers and body' do
        expect(parsed_simple_mail.original_headers).to eql original_mail_headers
        expect(parsed_simple_mail.original_body).to eql original_mail_body
      end

      it 'extracts headers and includes the header sequence' do
        expect(parsed_simple_mail.headers.keys.sort).to eql [:delivered_to, :received]
        expect(parsed_simple_mail.headers[:delivered_to]).to eql({data: 'dummy@test.com', sequence: 1})
        expect(parsed_simple_mail.headers[:received]).to eql({data: received_header_value, sequence: 0})
      end

      it 'combines header values when there are multiple entries' do
        expect(parsed_complete_mail.headers[:reply_to]).to eql([
          {data: '<UYL4O05CKRMOCGB@8179.832>', sequence: 15},
          {data: '<093EQZIAIZEMNGT@3121.295>', sequence: 13},
          {data: '<0R6SXF0LLNIAF5Y@1739.842>, <3XUGT4L0VPPDYAB@2899.232>', sequence: 10},
          {data: 'a@dodgy.com, b@dodgy.com, c@dodgy.com', sequence: 7},
          {data: '<YL1J605V6XP25G7@0418.287>', sequence: 4},
          {data: '<N3M8G6FZ1PCWHSB@2624.698>', sequence: 2},
          {data: '<6LCNMRYZWC11Z8C@1699.813>', sequence: 0}
        ])
      end

      it 'parses and sets the tracing headers' do
        expect(parsed_complete_mail.tracing_headers[:received]).to eql([
          {
            advertised_sender: nil,
            id: 'w17csp2701290oor',
            partial: true,
            protocol: 'SMTP',
            recipient: enriched_ip_1,
            recipient_mailbox: 'anotherdummy@test.com',
            sender: nil,
            starttls: nil,
            time: Time.new(2020, 4, 25, 22, 14, 8, '-07:00')
          },
          {
            advertised_sender: nil,
            id: 'w6mr17215337plq.173.1587878045528',
            partial: true,
            protocol: 'SMTP',
            recipient: enriched_ip_2,
            recipient_mailbox: nil,
            sender: nil,
            starttls: nil,
            time: Time.new(2020, 4, 25, 22, 14, 7, '-07:00')
          },
          {
            advertised_sender: 'probably.not.real.com',
            id: 'u23si16237783eds.526.2020.06.26.06.27.53',
            partial: false,
            protocol: 'ESMTPS',
            recipient: 'mx.google.com',
            recipient_mailbox: 'mannequin@test.com',
            sender: {host: nil, ip: enriched_ip_3},
            starttls: {version: 'TLS1_2', cipher: 'ECDHE-ECDSA-AES128-GCM-SHA256', bits: '128/128'},
            time: Time.new(2020, 4, 25, 22, 14, 6, '-07:00')
          },
          {
            advertised_sender: 'not.real.com',
            id: 'b201si8173212pfb.88.2020.04.25.22.14.05',
            partial: false,
            protocol: 'ESMTP',
            recipient: 'mx.google.com',
            recipient_mailbox: 'dummy@test.com',
            sender: {host: 'my.dodgy.host.com', ip: enriched_ip_4},
            starttls: nil,
            time: Time.new(2020, 4, 25, 22, 14, 5, '-07:00')
          },
          {
            advertised_sender: 'still.not.real.com',
            id: nil,
            partial: true,
            protocol: nil,
            recipient: nil,
            recipient_mailbox: nil,
            sender: {host: 'another.dodgy.host.com', ip: enriched_ip_5},
            starttls: nil,
            time: nil
          }
        ])
      end
    end
  end
end
