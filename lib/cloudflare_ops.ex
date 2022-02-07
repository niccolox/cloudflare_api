defmodule DomainNameOperator.CloudflareOps do
  # %CloudflareARecord{
  #   zone: zone_id,
  #   hostname: hostname,
  #   #ip: List.first(service.status.loadBalancer.ingress).ip
  #   ip: ip
  # }
  def record_present?(record) do
    # relevant_a_records()
  end

  def get_a_records do
    Cloudflare.Zone.index()
  end

  def relevant_a_records(hostname) do
    get_a_records()
    |> Map.get("status")
    |> Map.get("addresses")
    |> Enum.filter(fn a -> a["type"] == "ExternalIP" end)
    |> List.flatten()
  end

  def create_a_record(ip) do
  end

  def remove_a_record(ip) do
  end
end
