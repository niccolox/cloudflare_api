defmodule CloudflareApiTest do
  use ExUnit.Case
  doctest CloudflareApi

  alias CloudflareApi.DnsRecords

  @test_token "<populate me!>"

  test "It all works" do
    # Because this test requires real cloudlfare, we jam it all into one subroutine
    c = CloudflareApi.client(@test_token)
    DnsRecords.list(c, "abc")
    assert c
  end

  test "#client/1" do
  end

  test "#new/1" do
  end

  test "#uri_encode_opts/1" do
  end

  test "#opts_to_query_str/1" do
  end

  describe "DnsRecords" do
    test "#list/3" do
    end

    test "#list_for_hostname/4" do
    end

    test "#create/3" do
    end
  end
end
