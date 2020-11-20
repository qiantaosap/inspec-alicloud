# frozen_string_literal: true

require "alicloud_backend"

class AliCloudVpnGateways < AliCloudResourceBase
  name "alicloud_vpn_gateways"
  desc "Verifies settings for AliCloud VPN gateway in bulk"
  example "
    # Verify that you have VPN gateways defined
    describe alicloud_vpn_gateways do
      it { should exist }
    end
    # Verify you have more than the 1 VPN gateway
    describe alicloud_vpn_gateways do
      its('entries.count') { should be > 1 }
    end
  "

  attr_reader :table

  # FilterTable setup
  FilterTable.create
    .register_column(:ids, field: :id)
    .register_column(:names, field: :name)
    .register_column(:descriptions, field: :description)
    .register_column(:vpc_ids, field: :vpc_id)
    .register_column(:vswitch_ids, field: :vswitch_id)
    .register_column(:internet_ips, field: :internet_ip)
    .register_column(:statuses, field: :status)
    .register_column(:business_statuses, field: :business_status)
    .register_column(:specs, field: :spec)
    .register_column(:charge_types, field: :charge_type)
    .register_column(:ipsec_enableds, field: :ipsec_enabled)
    .register_column(:ssl_enableds, field: :ssl_enabled)
    .register_column(:ssl_max_connections_s, field: :ssl_max_connections)
    .register_column(:tags_s, field: :tags)
    .register_column(:created_time_stamps, field: :created_time_stamp)
    .register_column(:expire_time_stamps, field: :expire_time_stamp)
    .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters
    @table = fetch_data
  end

  def fetch_data
    vpn_gateway_rows = []
    catch_alicloud_errors do
      @vpn_gateways = @alicloud.vpc_client.request(
        action: "DescribeVpnGateways",
        params: {
          'RegionId': opts[:region],
        }
      )["VpnGateways"]["VpnGateway"]
    end

    return [] if !@vpn_gateways || @vpn_gateways.empty?

    @vpn_gateways.each do |vpn_gateway|
      vpn_gateway_rows += [{
        id:                  vpn_gateway["VpnGatewayId"],
        name:                vpn_gateway["Name"],
        description:         vpn_gateway["Description"],
        vpc_id:              vpn_gateway["VpcId"],
        vswitch_id:          vpn_gateway["VSwitchId"],
        internet_ip:         vpn_gateway["InternetIp"],
        status:              vpn_gateway["Status"],
        business_status:     vpn_gateway["BusinessStatus"],
        spec:                vpn_gateway["Spec"],
        charge_type:         vpn_gateway["ChargeType"],
        ipsec_enabled:       vpn_gateway["IpsecVpn"],
        ssl_enabled:         vpn_gateway["SslVpn"],
        ssl_max_connections: vpn_gateway["SslMaxConnections"],
        tags:                (map_tags vpn_gateway["Tags"]["Tag"] if vpn_gateway.key?("Tags")),
        created_time_stamp:  vpn_gateway["CreateTime"],
        expire_time_stamp:   vpn_gateway["EndTime"],
      }]
    end

    @table = vpn_gateway_rows
  end

  def to_s
    "AliCloud VPN Gateways"
  end
end
