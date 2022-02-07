defmodule CloudflareApi do
  #use Tesla, only: [:get], docs: false
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.cloudflare.com/client/v4"
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.BearerAuth, token: "token"

  def new(cloudflare_api_token) do
    Tesla.client [
      {Tesla.Middleware.BaseUrl, "https://api.cloudflare.com/client/v4"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BearerAuth, token: cloudflare_api_token}
    ]
  end

  def client(cloudflare_api_token) do
    c = CloudflareApi.new(cloudflare_api_token)
    fn -> c end
  end

  @doc false
  def uri_encode_opts(opts) do
    URI.encode_query(opts, :rfc3986)
  end

  @doc false
  def opts_to_query_str(opts) do
    opts
    |> Enum.map(fn {k, v} -> {url_encode(k), url_encode(v)} end)
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
  end

  defmodule DnsRecords do
    def list(client, zone_id, opts \\ nil) do
      # TODO validate zone and raise exception if invalid
      case opts do
        nil -> get(client, "/zones/#{zone_id}/dns_records")
        _ -> get(client, "/zones/#{zone_id}/dns_records?#{uri_encode_opts(opts)}")
      end
    end

    def list_for_hostname(client, zone_id, hostname, type \\ nil) do
      case type do
        nil -> list(client, zone_id, name: hostname)
        _ -> list(client, zone_id, name: hostname, type: "A")
      end
    end

    def create(client, zone_id, hostname, ip, type \\ "A") do
      post(client, "/zones/#{zone_id}/dns_records", %{
        type: type,
        name: hostname,
        content: ip,
        ttl: "1",
        proxied: false
      })
    end
  end

  defmodule Zones do
    def list do

    end
  end
end


# HTTP
# |> auth("Bearer <token>")
# |> headers(accept: "application/json")
# |> headers("content-type":, "application/json")
# |> get("https://example.con/api/v1/hello?name=bob")


cf = CloudflareApi.client(token)
ClouflareApi.list_dns_records(cf)


CloudflareApi.client(token)
|> ClouflareApi.DnsRecords.list()
|> Enum.map(fn a -> a end)

