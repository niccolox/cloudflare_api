defmodule CloudflareApi.DnsRecord do
  @moduledoc ~S"""
  Makes a struct and convenience functions around A Cloudflare DNS record.

  See Cloudflare docs:  https://api.cloudflare.com/#dns-records-for-a-zone-properties
  """

  alias CloudflareApi.Utils

  @enforce_keys [:zone_id, :hostname, :ip]
  defstruct [
    :id,
    :zone_id,
    :zone_name,
    :hostname,
    :ip,
    :created_on,
    type: "A",
    ttl: "1",
    proxied: false,
    proxiable: true,
    locked: false
  ]

  def cf_url(record) do
    "https://api.cloudflare.com/client/v4/zones/#{record.zone_id}/dns_records"
  end

  def to_cf_json(record) do
    %{
      type: record.type,
      name: record.hostname,
      content: record.ip,
      ttl: record.ttl,
      proxied: record.proxied
    }
  end

  def from_cf_json(%{zone_id: _} = record) do
    record
    |> Utils.map_atom_keys_to_strings()
    |> from_cf_json()
  end

  def from_cf_json(record) do
    %CloudflareApi.DnsRecord{
      id: record["id"],
      zone_id: record["zone_id"],
      zone_name: record["zone_name"],
      hostname: record["name"],
      ip: record["content"],
      created_on: record["created_on"],
      type: record["type"],
      ttl: record["ttl"],
      proxied: record["proxied"],
      proxiable: record["proxiable"],
      locked: record["locked"]
    }
  end
end
