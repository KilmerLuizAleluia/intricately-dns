# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


first = DnsRecord.create(ip_address: '1.1.1.1')
second = DnsRecord.create(ip_address: '2.2.2.2')
third = DnsRecord.create(ip_address: '3.3.3.3')
fourth = DnsRecord.create(ip_address: '4.4.4.4')
fifth = DnsRecord.create(ip_address: '4.4.4.4')

Hostname.create(name: 'lorem.com', dns_records: [first])
Hostname.create(name: 'ipsum.com', dns_records: [first, second, third, fourth])
Hostname.create(name: 'dolor.com', dns_records: [first, third, fourth, fifth])
Hostname.create(name: 'amet.com', dns_records: [first, third, fourth])
Hostname.create(name: 'sit.com', dns_records: [fourth, fifth])