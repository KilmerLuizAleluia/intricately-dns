module Api
  module V1
    class DnsRecordsController < ApplicationController
      PAGE_SIZE = 30

      # GET /dns_records
      def index
        return render status: :unprocessable_entity if dns_params[:page].nil?
        dns = paginated_dns

        json_response = {
          total_records: dns.count,
          records: records_json(dns),
          related_hostnames: related_hostnames_json(dns)
        }

        render json: json_response, status: :ok
      end

      # POST /dns_records
      def create
        dns_record = CreateDnsRecordService.new(ip: dns_params[:dns_records][:ip]).call
        CreateOrUpdateHostnamesService.new(
          dns_record: dns_record,
          hostnames_attributes: dns_params[:dns_records][:hostnames_attributes]
        ).call

        render json: { id: dns_record.id }, status: :created
      end

      private

      def paginated_dns
        dns_records = DnsRecord.all.limit(PAGE_SIZE).offset(page_offset)
        dns_records = select_included_hostnames(dns_records) if dns_params[:included].present?
        dns_records = reject_excluded_hostnames(dns_records) if dns_params[:excluded].present?

        dns_records
      end

      def records_json(dns)
        records = []
        dns.each { |dns|
          record_json = { id: dns.id, ip_address: dns.ip_address }
          records << record_json
        }

        records
      end

      def related_hostnames_json(dns)
        hn_ids = []
        related_hostnames = []
        dns.each { |d| hn_ids << d.hostname_ids }
        hn_frequencies = hn_ids.flatten.tally

        hn_frequencies.each { |hn|
          next if included_ids.include?(hn[0])
          json = {
            count: hn[1],
            hostname: Hostname.find(hn[0]).name
          }
          related_hostnames << json
        }

        related_hostnames
      end

      def select_included_hostnames(dns_records)
        dns_records.select { |dns|
          ((included_ids) - dns.hostname_ids).empty?
        }
      end

      def reject_excluded_hostnames(dns_records)
        dns_records.reject  { |dns|
          (excluded_ids & dns.hostname_ids).present?
        }
      end

      def included_ids
        return [] unless dns_params[:included].present?
        names = dns_params[:included]&.split(',')
        names.map { |name| Hostname.find_by(name: name).id }
      end

      def excluded_ids
        return [] unless dns_params[:excluded].present?
        names = dns_params[:excluded]&.split(',')
        names.map { |name| Hostname.find_by(name: name).id }
      end

      def page_offset
        (dns_params[:page].to_i - 1) * PAGE_SIZE
      end

      def dns_params
        params.permit(
          :page,
          :included,
          :excluded,
          dns_records: [:ip, hostnames_attributes: [:hostname]]
        )
      end
    end
  end
end
