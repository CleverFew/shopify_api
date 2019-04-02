# frozen_string_literal: true
require 'test_helper'

class ApiVersionTest < Test::Unit::TestCase
  def teardown
    super
    ShopifyAPI::ApiVersion.clear_defined_versions
    ShopifyAPI::ApiVersion.define_known_versions
  end

  test "no version creates url that start with /admin/" do
    assert_equal(
      "/admin/resource_path/id.json",
      ShopifyAPI::ApiVersion::NoVersion.new.construct_api_path("resource_path/id.json")
    )
  end

  test "no version creates graphql url that start with /admin/api" do
    assert_equal(
      "/admin/api/graphql.json",
      ShopifyAPI::ApiVersion::NoVersion.new.construct_graphql_path
    )
  end

  test "unstable version creates url that start with /admin/api/unstable/" do
    assert_equal(
      "/admin/api/unstable/resource_path/id.json",
      ShopifyAPI::ApiVersion::Unstable.new.construct_api_path("resource_path/id.json")
    )
  end

  test "unstable version creates graphql url that start with /admin/api/unstable/" do
    assert_equal(
      "/admin/api/unstable/graphql.json",
      ShopifyAPI::ApiVersion::Unstable.new.construct_graphql_path
    )
  end

  test "coerce_to_version returns any version object given" do
    version = ShopifyAPI::ApiVersion::Unstable.new
    assert_same(version, ShopifyAPI::ApiVersion.coerce_to_version(version))
  end

  test "coerce_to_version converts a known version into a version object" do
    versions = [
      ShopifyAPI::ApiVersion::Unstable.new,
      ShopifyAPI::ApiVersion::NoVersion.new,
    ]

    assert_equal(versions, [
      ShopifyAPI::ApiVersion.coerce_to_version('unstable'),
      ShopifyAPI::ApiVersion.coerce_to_version(:no_version),
    ])
  end

  test "coerce_to_version raises when coercing a string that doesn't match a known version" do
    assert_raises ShopifyAPI::ApiVersion::UnknownVersion do
      ShopifyAPI::ApiVersion.coerce_to_version('made up version')
    end
  end

  test "additional defined versions will also be coerced" do
    versions = [
      TestApiVersion.new('my_name'),
      TestApiVersion.new('other_name'),
    ]

    versions.each do |version|
      ShopifyAPI::ApiVersion.define_version(version)
    end

    assert_equal(versions, [
      ShopifyAPI::ApiVersion.coerce_to_version('my_name'),
      ShopifyAPI::ApiVersion.coerce_to_version('other_name'),
    ])
  end

  class TestApiVersion < ShopifyAPI::ApiVersion
    def initialize(name)
      @version_name = name
    end
  end
end