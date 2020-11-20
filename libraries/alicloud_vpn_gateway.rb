# frozen_string_literal: true

require "alicloud_backend"

class AliCloudVpnGateway < AliCloudResourceBase
  name "alicloud_vpn_gateway"
  desc "Verifies properties for an individual AliCloud VPN Gateway"
  example "
  describe alicloud_vpn_gateway('vpn-uf6s23apf4n33') do
    it { should exist }
  end
  "
  attr_reader :vpn_gateway_id, :vpn_gateway_name, :description, :vpc_id,
              :vswitch_id, :internet_ip, :status, :business_status, :spec,
              :charge_type, :ipsec_enabled, :ssl_enabled, :ssl_max_connections,
              :tags, :created_time_stamp, :expire_time_stamp

  def initialize(opts = {})
    opts = { vpn_gateway_id: opts } if opts.is_a? String

    super(opts)
    validate_parameters(required: %i{vpn_gateway_id})
    catch_alicloud_errors do
      @resp = @alicloud.vpc_client.request(
        action: "DescribeVpnGateway",
        params: {
          'RegionId':     opts[:region],
          'VpnGatewayId': opts[:vpn_gateway_id],
        }
      )
    end

    if @resp.nil?
      @vpn_gateway_id = "empty response"
      return
    end

    @vpn_gateway         = @resp
    @vpn_gateway_id      = @vpn_gateway["VpnGatewayId"]
    @vpn_gateway_name    = @vpn_gateway["Name"]
    @description         = @vpn_gateway["Description"]
    @vpc_id              = @vpn_gateway["VpcId"]
    @vswitch_id          = @vpn_gateway["VSwitchId"]
    @internet_ip         = @vpn_gateway["InternetIp"]
    @status              = @vpn_gateway["Status"]
    @business_status     = @vpn_gateway["BusinessStatus"]
    @spec                = @vpn_gateway["Spec"]
    @charge_type         = @vpn_gateway["ChargeType"]
    @ipsec_enabled       = @vpn_gateway["IpsecVpn"]
    @ssl_enabled         = @vpn_gateway["SslVpn"]
    @ssl_max_connections = @vpn_gateway["SslMaxConnections"]
    @tags                = map_tags @vpn_gateway["Tags"]["Tag"] if @vpn_gateway.key?("Tags")
    @created_time_stamp  = @vpn_gateway["CreateTime"]
    @expire_time_stamp   = @vpn_gateway["EndTime"]
  end

  def exists?
    !@vpn_gateway.nil?
  end

  def to_s
    "VPN Gateway #{vpn_gateway_id}"
  end
end
