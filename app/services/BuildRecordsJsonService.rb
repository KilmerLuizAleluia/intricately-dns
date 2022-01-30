class BuildRecordsJsonService
  attr_reader :dns_records

  def initialize(args)
    @dns_records = args[:dns_records]
  end

  def call
    records = []
    dns_records.each { |dns|
      record_json = { id: dns.id, ip_address: dns.ip_address }
      records << record_json
    }

    records
  end
end