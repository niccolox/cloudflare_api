defmodule CloudflareApi.CacheEntry do
  @moduledoc """
  """

  @enforce_keys [:timestamp, :dns_record]
  defstruct [:timestamp, :dns_record]

  @type t :: %__MODULE__{
          timestamp: integer(),
          dns_record: CloudflareApi.DnsRecord.t()
        }
end
