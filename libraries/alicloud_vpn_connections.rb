require 'alicloud_backend'

class AliCloudVpnConnections < AliCloudResourceBase
  name 'alicloud_vpn_connections'
  desc 'Verifies settings for AliCloud VpnConnections in bulk'

  example '
    describe alicloud_vpn_connections do
      it { should exist }
    end
  '

  attr_reader :table

  FilterTable.create
    .register_column(:vpn_gateway_ids,       field: :vpn_gateway_id)
    .register_column(:vpn_connection_ids,    field: :vpn_connection_id)
    .register_column(:status_s,              field: :status)
    .register_column(:local_subnets,         field: :local_subnet)
    .register_column(:remote_subnets,        field: :remote_subnet)
    .register_column(:local_ids,             field: :local_id)
    .register_column(:remote_ids,            field: :remote_id)
    .register_column(:vpn_connection_names,  field: :vpn_connection_name)
    .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    validate_parameters
    @table = fetch_data
  end

  def fetch_data
    connection_rows = []
    catch_alicloud_errors do
      @connections = @alicloud.vpc_client.request(
        action: 'DescribeVpnConnections',
        params: {
          'RegionId': opts[:region],
        }
      )['VpnConnections']['VpnConnection']
    end
    return [] if !@connections || @connections.empty?

    @connections.map do |connection|
      connection_rows += [{
        vpn_gateway_id: connection['VpnGatewayId'],
        vpn_connection_id: connection['VpnConnectionId'],
        status: connection['status'],
        local_subnet: connection['LocalSubnet'],
        remote_subnet: connection['RemoteSubnet'],
        local_id: connection['IkeConfig']['LocalId'],
        remote_id: connection['IkeConfig']['RemoteId'],
        vpn_connection_name: connection['Name'],
      }]
    end
    @table = connection_rows
  end

  def exists?
    !@table.nil? && !@table.empty?
  end
end
