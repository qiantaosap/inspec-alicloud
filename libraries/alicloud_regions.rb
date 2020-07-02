# frozen_string_literal: true

require 'alicloud_backend'

class AliCloudRegions < AliCloudResourceBase
  name 'alicloud_regions'
  desc 'Verifies settings for AliCloud Regions in bulk'

  example '
    describe alicloud_regions do
      it { should exist }
    end
  '

  attr_reader :table

  FilterTable.create
             .register_column(:region_names,       field: :region_name)
             .register_column(:endpoints,          field: :region_endpoint)
             .register_column(:region_local_names, field: :region_local_name)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    super(opts)
    @table = fetch_data
  end

  def fetch_data
    region_rows = []
    catch_alicloud_errors do
      @regions = @alicloud.ecs_client.request(action: 'DescribeRegions')['Regions']['Region']
    end
    return [] if !@regions || @regions.empty?
    @regions.each do |region|
      region_rows += [{ region_name: region['RegionId'],
                        region_endpoint: region['RegionEndpoint'],
                        region_local_name: region['LocalName']}]
    end
    @table = region_rows
  end
end