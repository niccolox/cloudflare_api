defmodule CloudflareApi.CloudflareARecord do
  @moduledoc ~S"""
  """

  @enforce_keys [:zone, :hostname, :ip]
  defstruct [:zone, :hostname, :ip, type: "A", ttl: "1", proxied: false]

  def cf_url(record) do
    "https://api.cloudflare.com/client/v4/zones/#{record.zone}/dns_records"
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
end
