defmodule CloudflareApi.CacheTest do
  use ExUnit.Case
  doctest CloudflareApi.Cache

  alias CloudflareApi.{Cache, DnsRecord}

  @test_hostname "test.example.com"

  setup do
    IO.puts "Hello!"
    Cache.flush()

    on_exit fn ->
      IO.puts "Goodbye!"
      Cache.flush()
    end
  end

  describe "cache" do
    # start_supervised({CloudflareApi.Cache, []})
    #setup [:cache_dns_record]

    #setup do
    #  cache_dns_record()
    #end

    test "expired is hidden" do
      lljkkjl
    end

    test "includes, update, get, flush, dump, delete all work" do
      hn1 = "hostname1.example.com"
      hn2 = "hostname2.example.com"

      drf1 = dns_record_fixture(hn1)
      drf2 = dns_record_fixture(hn2)

      assert false == Cache.includes?(hn1)
      assert drf1 == Cache.add_or_update(drf1)

      assert true == Cache.includes?(hn1)
      assert drf1 == Cache.get(hn1)
      assert [drf1] == Cache.dump()
      assert :ok == Cache.flush()

      assert drf1 == Cache.add_or_update(hn1, drf1)
      assert drf2 == Cache.add_or_update(hn2, drf2)

      assert dump_res = Cache.dump_cache()
      assert true == Map.has_key?(dump_res.hostnames, hn1)
      assert true == Map.has_key?(dump_res.hostnames, hn2)
      assert drf1 == Map.get(dump_res.hostnames, hn1).dns_record
      assert drf2 == Map.get(dump_res.hostnames, hn2).dns_record
      assert dump_res = Cache.dump()
      hns1 = Enum.map(dump_res, fn dr -> dr.hostname end)
      assert true == hn1 in hns1
      assert true == hn2 in hns1

      assert :ok == Cache.delete(hn2)
      assert true == Cache.includes?(hn1)
      assert false == Cache.includes?(hn2)
      assert dump_res = Cache.dump_cache()
      assert true == Map.has_key?(dump_res.hostnames, hn1)
      assert false == Map.has_key?(dump_res.hostnames, hn2)
      assert drf1 == Map.get(dump_res.hostnames, hn1).dns_record
      assert nil == Map.get(dump_res.hostnames, hn2)
      assert true == Cache.includes?(hn1)
      assert false == Cache.includes?(hn2)

      assert :ok == Cache.flush()
      assert [] == Cache.dump()
      assert %{} == Cache.dump_cache().hostnames
      assert false == Cache.includes?(hn1)
      assert false == Cache.includes?(hn2)
    end
  end

  defp dns_record_fixture(hostname \\ @test_hostname) do
    %DnsRecord{
      id: "abcd1123",
      zone_id: "",
      hostname: hostname,
      ip: "192.168.2.2",
      type: :MX,
      ttl: 15
    }
  end

  defp cache_dns_record(dns_record \\ dns_record_fixture()) do
    {:ok, dns_record: Cache.add_or_update(dns_record)}
  end
end
