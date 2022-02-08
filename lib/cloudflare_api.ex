defmodule CloudflareApi do
  @moduledoc """

  _NOTE:  This package is still under active development and may be refactored
  in substantive ways very soon.  If you need to get to prod soon, you may
  want to find an alternative._

  `CloudflareApi` is a thin wrapper around the Cloudflare API.  It provides
  convenient functions and elixir idioms so you don't have to use HTTP directly.

  This library subscribes to the philosophy that you a well-designed REST API
  doesn't need
  a heavy layer of abstraction on top.  There is extensive documentation for
  the CloudFlare API already, and abstracting that away .  The downside of
  course is that if you _want_ to be shielded from the API details, this isn't
  the package for you.

  For example, if you wanted to call
  [the Cloudflare endpoint for listing DNS records](https://api.cloudflare.com/#dns-records-for-a-zone-list-dns-records):

  ```
  GET zones/:zone_identifier/dns_records
  ```

  rather than using one of the many HTTP clients, you can do:

  ```
  CloudflareApi.DnsRecords.list(client, zone_id)
  ```

  The extensive query string prameters options that CloudFlare offers are
  also accessible through an `opts` `KeywordList`:

  ```
  CloudflareApi.DnsRecords.list(client, zone_id, name: hostname, type: "A")
  ```

  You may wish to look through the Livebook for an example of usage.

  _NOTE:  This package is still very new and is far from feature complete.  The
  most common endpoints will be created first, but if you need one that isn't
  provided yet you can open an issue on Github (or send a pull request).
  Because this layer is very thin, it doesn't usually take long to add new
  endpoints._

  """

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
