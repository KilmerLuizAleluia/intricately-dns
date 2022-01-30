class RetrievePaginatedDnsService
  attr_reader :page_size, :page, :included, :excluded

  def initialize(args)
    @page_size = args[:page_size]
    @page = args[:page].to_i
    @included = args[:included]
    @excluded = args[:excluded]
  end

  def call
    dns_records = DnsRecord.all.limit(page_size).offset(page_offset)
    dns_records = SelectIncludedHostnamesService.new(dns_records: dns_records, included: included).call
    dns_records = RejectExcludedHostnamesService.new(dns_records: dns_records, excluded: excluded).call

    dns_records
  end

  def page_offset
    (page - 1) * page_size
  end
end