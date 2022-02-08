defmodule CloudflareApi.Zone do
  @moduledoc ~S"""
  Makes a struct and convenience functions around A Cloudflare Zone object.

  See Cloudflare docs:  https://api.cloudflare.com/#zone-properties
  """

  alias CloudflareApi.Utils

  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :development_mode,
    :original_name_servers,
    :original_registrar,
    :original_dnshost,
    :created_on,
    :modified_on,
    :activated_on,
    :owner,
    :account,
    :permissions,
    :plan,
    :plan_pending,
    :status,
    :paused,
    :type,
    :name_servers
  ]

  def cf_url(zone) do
    "https://api.cloudflare.com/client/v4/zones/#{zone.zone_id}/dns_records"
  end

  def to_cf_json(zone) do
    Utils.struct_to_map(zone)
  end

  def from_cf_json(%{"zone_id" => _} = zone) do
    # https://stackoverflow.com/a/41980865/2062384
    struct(CloudflareApi.Zone, zone)
  end

  def from_cf_json(zone) do
    from_cf_json(Utils.map_atom_keys_to_strings(zone))
  end
end
