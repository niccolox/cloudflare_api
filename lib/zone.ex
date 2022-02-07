defmodule CloudflareApi.Zone do
  @moduledoc ~S"""
  """

  alias CloudflareApi.Utils

  @enforce_keys []
  defstruct [
  ]

  def cf_url(zone) do
    "https://api.cloudflare.com/client/v4/zones/#{zone.zone_id}/dns_records"
  end

  def to_cf_json(zone) do
    %{
    }
  end

  def from_cf_json(%{zone_id: _} = zone) do
    from_cf_json(Utils.map_atom_keys_to_strings(zone))
  end

  def from_cf_json(zone) do
    %CloudflareApi.Zone{
    }
  end
end
