#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'time'
require 'base64'
require 'openssl'
require 'rexml/document'
require 'rexml/formatters/pretty'
require 'optparse'

class S3G
  ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID']
  SECRET_ACCESS_KEY_ID = ENV['AWS_SECRET_ACCESS_KEY_ID']
  SUB_RESOURCE_NAMES = %w(acl lifecycle location logging notification partNumber policy requestPayment torrent uploadId uploads versionId versioning versions website)

  def start(path)
    uri = URI.parse("https://s3-#{ENV['AWS_REGION']}.amazonaws.com")
    uri.merge!(path)

    puts "GET #{uri.to_s}"

    req = Net::HTTP::Get.new(uri)
    date = Time.now.httpdate
    req['Authorization'] = "AWS #{ACCESS_KEY_ID}:#{self.signature(date, uri.request_uri)}"
    req['Date'] = date

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    doc = REXML::Document.new(res.body)
    REXML::Formatters::Pretty.new.write(doc, STDOUT)
  end

  # https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/RESTAuthentication.html#ConstructingTheCanonicalizedResourceElement
  def canonicalized_resource(path)
    uri = URI.parse(path)
    return path unless uri.query
    pairs = URI.decode_www_form(uri.query)
    uri.query = pairs.select { |k, v| SUB_RESOURCE_NAMES.include?(k) }.map { |k, v| v.empty? ? k : "#{k}=#{v}" }.join('&')
    uri.to_s
  end

  # https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/RESTAuthentication.html#RESTAuthenticationExamples
  def signature(date, path)
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest::SHA1.new,
        SECRET_ACCESS_KEY_ID,
        self.string_to_sign(date, path)
      )
    ).chomp
  end

  def string_to_sign(date, path)
    "GET\n\n\n#{date}\n#{self.canonicalized_resource(path)}"
  end
end

params = ARGV.getopts('', 'path:')
S3G.new.start(params['path'] || '/')
