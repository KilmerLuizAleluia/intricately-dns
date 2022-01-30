class RejectExcludedHostnamesService
	attr_reader :dns_records, :excluded

  def initialize(args)
    @dns_records = args[:dns_records]
    @excluded = args[:excluded]
  end

	def call
		dns_records.reject  { |dns|
      (excluded_ids & dns.hostname_ids).present?
    }
	end

	def excluded_ids
    return [] unless excluded.present?
    names = excluded.split(',')
    names.map { |name| Hostname.find_by(name: name).id }
  end
end