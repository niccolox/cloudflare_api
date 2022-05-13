defmodule CloudflareApi.CacheTest do
  use ExUnit.Case
  doctest CloudflareApi.Cache

  alias CloudflareApi.DnsRecord

  describe "get" do
    test "works" do
    end
  end

  describe "update" do
    test "includes, update, get, flush, dump, delete all work" do
      hostname1 = "hostname1.example.com"
      hostname2 = "hostname2.example.com"

      assert false == CloudflareApi.Cache.includes?(hostname1)
      assert :ok == CloudflareApi.Cache.add_or_update(hostname1, dns_record_fixture())
      assert true == CloudflareApi.Cache.includes?(hostname1)
      assert dns_record_fixture() == CloudflareApi.Cache.get(hostname1)
      assert %{hostname1 => dns_record_fixture()} == CloudflareApi.Cache.dump()
      assert :ok == CloudflareApi.Cache.flush()

      assert :ok == CloudflareApi.Cache.add_or_update(hostname1, dns_record_fixture())
      assert :ok == CloudflareApi.Cache.add_or_update(hostname2, dns_record_fixture())
      assert dump_res = CloudflareApi.Cache.dump()
      assert true == Map.has_key?(dump_res, hostname1)
      assert true == Map.has_key?(dump_res, hostname2)
      assert dns_record_fixture() == Map.get(dump_res, hostname1)
      assert dns_record_fixture() == Map.get(dump_res, hostname2)

      assert dump_res = CloudflareApi.Cache.dump()
      assert true == Map.has_key?(dump_res, hostname1)
      assert true == Map.has_key?(dump_res, hostname2)
      assert dns_record_fixture() == Map.get(dump_res, hostname1)
      assert dns_record_fixture() == Map.get(dump_res, hostname2)
      assert true == CloudflareApi.Cache.includes?(hostname1)
      assert true == CloudflareApi.Cache.includes?(hostname2)

      assert :ok == CloudflareApi.Cache.delete(hostname2)
      assert true == CloudflareApi.Cache.includes?(hostname1)
      assert false == CloudflareApi.Cache.includes?(hostname2)
      assert dump_res = CloudflareApi.Cache.dump()
      assert true == Map.has_key?(dump_res, hostname1)
      assert false == Map.has_key?(dump_res, hostname2)
      assert dns_record_fixture() == Map.get(dump_res, hostname1)
      assert dns_record_fixture() == Map.get(dump_res, hostname2)
      assert true == CloudflareApi.Cache.includes?(hostname1)
      assert false == CloudflareApi.Cache.includes?(hostname2)

      assert :ok == CloudflareApi.Cache.flush()
      assert %{} == CloudflareApi.Cache.dump()
      assert false == CloudflareApi.Cache.includes?(hostname1)
      assert false == CloudflareApi.Cache.includes?(hostname2)
    end
  end

  defp dns_record_fixture do
    %DnsRecord{
      id: "abcd1123",
      zone_id: "",
      hostname: "test.example.com",
      ip: "192.168.2.2",
      type: :MX,
      ttl: 15
    }
  end

  @test_hostname "test.example.com"

  defp cache_dns_record(dns_record \\ dns_record_fixture()) do
    CloudflareApi.Cache.add_or_update(@test_hostname, dns_record)
  end
end
