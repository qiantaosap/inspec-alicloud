# frozen_string_literal: true

require "alicloud_backend"

class AliVpnConnection < AliCloudResourceBase
  name "alicloud_vpn_connection"
  desc "Verifies properties for an individual AliCloud VPN connection"
  example "
  describe alicloud_vpn_connection('vpn-1234567890') do
    it { should exist }
  end
  "
  attr_reader :vpn_gateway_id, :vpn_connection_id, :status, :local_subnet, :remote_subnet,
              :local_id, :remote_id, :vpn_connection_name

  def initialize(opts = {})
    opts = { vpn_connection_id: opts } if opts.is_a?(String)

    super(opts)
    validate_parameters(required: %i{vpn_connection_id})
    catch_alicloud_errors do
      @resp = @alicloud.vpc_client.request(
        action: "DescribeVpnConnection",
        params: {
          'RegionId': opts[:region],
          'VpnConnectionId': opts[:vpn_connection_id],
        }
      )
    end

    # DescribeVpnConnection will always return a hash with all attributes set to empty string even if the given VpcId is incorrect.
    if @resp.nil? || @resp["VpnConnectionId"].empty?
      @vpn_connection_id = "empty response"
      return
    end

    @vpn_connection_info           = @resp
    @vpn_connection_id             = @vpn_connection_info["VpnConnectionId"]
    @vpn_gateway_id                = @vpn_connection_info["VpnGatewayId"]
    @local_subnet                  = @vpn_connection_info["LocalSubnet"]
    @remote_subnet                 = @vpn_connection_info["RemoteSubnet"]
    @status                        = @vpn_connection_info["Status"]
    @local_id                      = @vpn_connection_info["IkeConfig"]["LocalId"]
    @remote_id                     = @vpn_connection_info["IkeConfig"]["RemoteId"]
    @vpn_connection_name           = @vpn_connection_info["Name"]
  end

  def exists?
    !@vpn_connection_info.nil?
  end

  def to_s
    "VPN Connection #{@vpc_id}"
  end
end
