defmodule CloudflareApi do
  @moduledoc """
  Documentation for `CloudflareApi`.
  """

  alias CloudflareApi.DnsRecord

  use Tesla

  @doc ~S"""
  Get a preconfigured client you can pass in to other functions

  This makes it so that you don't have to provide the `cloudflare_api_token`
  to every function call.

  ## Examples:

    iex> CloudflareApi.new("<your_token>")

  """
  def new(cloudflare_api_token) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://api.cloudflare.com/client/v4"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BearerAuth, token: cloudflare_api_token}
    ])
  end

  @doc ~S"""
  Returns a function that you can use to easily pass clients in your code.

  This makes it so you don't have to create your own client for every
  function call.  If you are going to make multiple calls then this is
  recommended for convenience and simplicity.  For example:

  ```
  # Get a function that wraps your token for you
  client = CloudflareApi.client("<my_token>")

  # Now you can call other functions like this:
  CloudflareApi.DnsRecords.list(client(), "my_zone_id)

  # If you are going to do additional processing, you can use a pipe:
  client()
  |> CloudflareApi.list("my_zone_id")
  |> Enum.map(fn record -> {record} end)
  ```

  """
  def client(cloudflare_api_token) do
    c = CloudflareApi.new(cloudflare_api_token)
    fn -> c end
  end

  @doc false
  def uri_encode_opts(opts) do
    URI.encode_query(opts, :rfc3986)
  end

  # @doc false
  # def opts_to_query_str(opts) do
  #  opts
  #  |> Enum.map(fn {k, v} -> {url_encode(k), url_encode(v)} end)
  #  |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
  # end

  defp c(%Tesla.Client{} = client), do: client
  defp c(client), do: client.()

  defmodule DnsRecords do
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
        nil -> list(client, zone_id, name: hostname)
        _ -> list(client, zone_id, name: hostname, type: "A")
      end
    end

    def create(client, zone_id, %DnsRecord{} = record) do
      Tesla.post(client, "/zones/#{zone_id}/dns_records", DnsRecord.to_cf_json(record))
    end

    def create(client, zone_id, hostname, ip, type \\ "A") do
      Tesla.post(client, "/zones/#{zone_id}/dns_records", %{
        type: type,
        name: hostname,
        content: ip,
        ttl: "1",
        proxied: false
      })
    end

    defp list_url(zone_id, opts) do
      case opts do
        nil -> "/zones/#{zone_id}/dns_records"
        _ -> "/zones/#{zone_id}/dns_records?#{CloudflareApi.uri_encode_opts(opts)}"
      end
    end

    defp c(%Tesla.Client{} = client), do: client
    defp c(client), do: client.()

    defp to_structs(records) when is_list(records), do:
      Enum.map(records, fn r -> to_struct(r) end)

    defp to_struct(record), do: DnsRecord.from_cf_json(record)
  end

  defmodule Zones do
    def list(client, opts \\ nil) do
      case Tesla.get(c(client), list_url(opts)) do
        {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body["result"]}
        {:ok, %Tesla.Env{body: %{"errors" => errs}}} -> {:error, errs}
        err -> {:error, err}
      end
    end

    defp list_url(opts) do
      case opts do
        nil -> "/zones"
        _ -> "/zones?#{CloudflareApi.uri_encode_opts(opts)}"
      end
    end

    defp c(%Tesla.Client{} = client), do: client
    defp c(client), do: client.()
  end
end

# HTTP
# |> auth("Bearer <token>")
# |> headers(accept: "application/json")
# |> headers("content-type":, "application/json")
# |> get("https://example.con/api/v1/hello?name=bob")

# cf = CloudflareApi.client(token)
# ClouflareApi.list_dns_records(cf)
#
#
# CloudflareApi.client(token)
# |> ClouflareApi.DnsRecords.list()
# |> Enum.map(fn a -> a end)
