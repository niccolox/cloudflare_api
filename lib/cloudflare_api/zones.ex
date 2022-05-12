defmodule CloudflareApi.Zones do
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
