module Api
  module V1
    class DnsRecordsController < ApplicationController
      PAGE_SIZE = 30

      # GET /dns_records
      def index
        dns = paginated_dns

        json_response = {
          total_records: dns.count,
          records: records_json,
          related_hostnames: related_hostnames_json
        }

        render json: json_response, status: :ok
      end

      # POST /dns_records
      def create
        dns_record = create_dns
        create_or_update_hostnames(dns_record)

        render json: { id: dns_record.id }, status: :created
      end

      private

      def paginated_dns
        DnsRecord.all.limit(PAGE_SIZE).offset(page_offset)
      end

      def page_offset
        (dns_params[:page].to_i - 1) * PAGE_SIZE
      end

      def records_json
        records = []
        DnsRecord.all.each { |dns|
          record_json = { id: dns.id, ip_address: dns.ip_address }
          records << record_json
        }

        records
      end

      def related_hostnames_json
        related_hostnames = []
        Hostname.all.each { |hostname|
          json = {
            count: DnsRecordHostname.where(hostname_id: hostname.id).count,
            hostname: hostname.name
          }
          related_hostnames << json
        }

        related_hostnames
      end

      def create_dns
        ip = dns_params[:dns_records][:ip]
        DnsRecord.find_or_create_by!(ip_address: ip)
      end

      def create_or_update_hostnames(dns_record)
        hostnames_attributes = dns_params[:dns_records][:hostnames_attributes]
        hostnames_attributes.each{ |hostname|
          model_hostname = Hostname.find_or_create_by!(name: hostname[:hostname])
          model_hostname.dns_records << dns_record
          model_hostname.save!
        }
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
