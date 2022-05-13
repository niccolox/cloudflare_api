defmodule CloudflareApi.Cache do
  @moduledoc """
  An optional short-term cache for API lookups.

  This lets you repeat the same requests multiple times without
  actually making a call to the Cloudflare API.  This will help a lot
  with rate limiting.  For example if you have code that queries the
  records for a particular hostname many times, this cache will allow
  you to repeat the call many times per minute and a real API call will
  only go out once every <cache-interval>.
  """

  use GenServer

  alias CloudflareApi.DnsRecord

  alias CloudflareApi.Utils
  alias CloudflareApi.Utils.Logger

  @self :cloudflare_api_cache

  @enforce_keys [:expire_seconds, :hostnames]
  defstruct expire_seconds: 120, hostnames: %{}

  @type t :: %__MODULE__{
          expire_seconds: non_neg_integer(),
          hostnames: %{String.t() => Cloudflare.DnsRecord.t()}
        }

  def start_link(args) when is_list(args) do
    Logger.debug(__ENV__, "Starting cache link with: #{Utils.to_string(args)}")
    GenServer.start_link(__MODULE__, args, name: @self)
  end

  def get(hostname) do
    ret = GenServer.call(@self, {:get, hostname})
    require IEx; IEx.pry
  end

  def add_or_update(hostname, %DnsRecord{} = record) do
    GenServer.call(@self, {:update, hostname, record})
    :ok
  end

  def update(hostname, %DnsRecord{} = record), do: add_or_update(hostname, record)

  def includes?(hostname) do
    GenServer.call(@self, {:includes, hostname})
  end

  def delete(hostname) do
    GenServer.call(@self, {:delete, hostname})
  end

  def flush do
    GenServer.call(@self, {:flush})
  end

  def dump do
    GenServer.call(@self, {:dump})
  end

  # Server

  @impl true
  def init(_init_arg) do
    #{:ok, %__MODULE__{expire_seconds: Application.get_env(:expire_seconds), hostnames: %{}}}
    {:ok, %__MODULE__{expire_seconds: 120, hostnames: %{}}}
  end

  @impl true
  def handle_call({:get, hostname}, _from, state) do
    Logger.debug(__ENV__, "Handling call for :get hostname='#{hostname}', state='#{Utils.to_string(state)}'")
    #{:reply, reply, new_state}
    {:reply, %DnsRecord{zone_id: "", hostname: "", ip: ""}, %{}}
  end

  @impl true
  def handle_call({:update, hostname, %DnsRecord{} = dns_record}, _from, state) do
    Logger.debug(__ENV__, "Handling call for :update hostname='#{hostname}', dns_record='#{Utils.to_string(dns_record)}', state='#{Utils.to_string(state)}")

    {:reply, %DnsRecord{zone_id: "", hostname: hostname, ip: ""}, %{}}
  end

  @impl true
  def handle_call({:includes, hostname}, _from, state) do
    Logger.debug(__ENV__, "Handling call for :includes hostname='#{hostname}', state='#{Utils.to_string(state)}'")

    {:reply, Map.has_key?(state, hostname), state}
  end

  @impl true
  def handle_call({:delete, hostname}, _from, state) do
    Logger.debug(__ENV__, "Handling call for :delete hostname='#{hostname}', state='#{Utils.to_string(state)}'")

    {:reply, %DnsRecord{zone_id: "", hostname: "", ip: ""}, %{}}
  end

  @impl true
  def handle_call({:flush}, _from, state) do
    Logger.debug(__ENV__, "Handling call for :flush state='#{Utils.to_string(state)}'")

    {:reply, %DnsRecord{zone_id: "", hostname: "", ip: ""}, %{}}
  end

  @impl true
  def handle_call({:dump}, _from, state) do
    Logger.debug(__ENV__, "Handling call for :dump state='#{Utils.to_string(state)}'")

    {:reply, %DnsRecord{zone_id: "", hostname: "", ip: ""}, %{}}
  end
end
