class BuildIndexJsonService
  attr_reader :dns_records, :included

  def initialize(args)
    @dns_records = args[:dns_records]
    @included = args[:included]
  end

  def call
    {
      total_records: dns_records.count,
      records: BuildRecordsJsonService.new(dns_records: dns_records).call,
      related_hostnames: BuildRelatedHostnamesJsonService.new(
        dns_records: dns_records,
        included: included
      ).call
    }
  end
end