defmodule CloudflareApi.DnsRecords do
  alias CloudflareApi.DnsRecord

  def list(client, zone_id, opts \\ nil) do
    # TODO validate zone and raise exception if invalid
    # with {:ok, env} <- Tesla.get(c(client), list_url(zone_id, opts)) do
    #  case env.body do
    #    %{"success" => false} -> {:err, env.body["errors"]}
    #    body -> {:ok, body}
    #  end
    # end
    case Tesla.get(c(client), list_url(zone_id, opts)) do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, to_structs(body["result"])}
      {:ok, %Tesla.Env{body: %{"errors" => errs}}} -> {:error, errs}
      err -> {:error, err}
    end
  end

  def list_for_hostname(client, zone_id, hostname, type \\ nil) do
    case type do
      nil -> list(c(client), zone_id, name: hostname)
      _ -> list(c(client), zone_id, name: hostname, type: "A")
    end
  end

  def list_for_host_domain(client, zone_id, host, domain, type \\ nil) do
    hostname = "#{host}.#{domain}"

    case type do
      nil -> list(c(client), zone_id, name: hostname)
      _ -> list(c(client), zone_id, name: hostname, type: "A")
    end
  end

  @doc ~S"""
  If the record already exists, this will exit with a success {:ok, :already_created}
  """
  def create(client, zone_id, %DnsRecord{} = record) do
    case Tesla.post(c(client), "/zones/#{zone_id}/dns_records", DnsRecord.to_cf_json(record)) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, to_struct(body["result"])}

      {:ok, %Tesla.Env{status: 400, body: %{"errors" => [%{"code" => 81057}]}}} ->
        {:ok, :already_exists}

      {:ok, %Tesla.Env{body: %{"errors" => errs}}} ->
        {:error, errs}

      err ->
        {:error, err}
    end
  end

  def create(client, zone_id, hostname, ip, type \\ "A") do
    case Tesla.post(c(client), "/zones/#{zone_id}/dns_records", %{
           type: type,
           name: hostname,
           content: ip,
           ttl: "1",
           proxied: false
         }) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, to_struct(body["result"])}

      {:ok, %Tesla.Env{status: 400, body: %{"errors" => [%{"code" => 81057}]}}} ->
        {:ok, :already_created}

      {:ok, %Tesla.Env{body: %{"errors" => errs}}} ->
        {:error, errs}

      err ->
        {:error, err}
    end
  end

  def update(client, zone_id, record_id, hostname, ip, type \\ "A") do
    case Tesla.put(c(client), "/zones/#{zone_id}/dns_records/#{record_id}", %{
           type: type,
           name: hostname,
           content: ip,
           ttl: "1",
           proxied: false
         }) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, to_struct(body["result"])}

      {:ok, %Tesla.Env{body: %{"errors" => errs}}} ->
        {:error, errs}

      err ->
        {:error, err}
    end
  end

  @doc ~S"""
  If the record already exists, this will exit with a success {:ok, :already_deleted}
  """
  def delete(client, zone_id, record_id) do
    case Tesla.delete(c(client), "/zones/#{zone_id}/dns_records/#{record_id}") do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body["result"]["id"]}

      {:ok, %Tesla.Env{status: 404, body: %{"errors" => [%{"code" => 81044}]}}} ->
        {:ok, :already_deleted}

      {:ok, %Tesla.Env{body: %{"errors" => errs}}} ->
        {:error, errs}

      err ->
        {:error, err}
    end
  end

  def hostname_exists?(client, zone_id, hostname, type \\ nil) do
    with {:ok, records} = list_for_hostname(client, zone_id, hostname) do
      # Enum.any?(records, fn r -> r.hostname == hostname end)
      Enum.count(records) > 0
    end
  end

  defp list_url(zone_id, opts) do
    case opts do
      nil -> "/zones/#{zone_id}/dns_records"
      _ -> "/zones/#{zone_id}/dns_records?#{CloudflareApi.uri_encode_opts(opts)}"
    end
  end

  defp c(%Tesla.Client{} = client), do: client
  defp c(client), do: client.()

  defp to_structs(records) when is_list(records),
    do: Enum.map(records, fn r -> to_struct(r) end)

  defp to_struct(record), do: DnsRecord.from_cf_json(record)
end
