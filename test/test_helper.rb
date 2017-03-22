# encoding: UTF-8

require 'minitest/autorun'
require 'webmock/minitest'
require 'json'
require 'loanscreener'

module LsrTestCommons

  def example_com()
    @example_com ||= "example.com"
  end

  def marketdata_uri()
    @marketdata_uri ||=
      "http://#{example_com}/marketdata.json"
  end

  def marketdata_body()
    @marketdata_body ||= [
      {
        "currency" => "USD",
        "ticker" => "FTR",
        "exchange" => "USNASD",
        "id" => "US35906A1088",
        "price" => 3.6500,
        "name" => "Frontier Communications Corp"
      },
      {
        "currency" => "USD",
        "ticker" => "UNIB",
        "exchange" => "USOTC",
        "id" => "US9140901052",
        "price" => 17.2000,
        "name" => "University Bancorp Inc. (MI)"
      },
      {
        "currency" => "USD",
        "ticker" => "ELMD",
        "exchange" => "USAMEX",
        "id" => "US2854091087",
        "price" => 3.7800,
        "name" => "Electromed Inc."
      }
    ]
  end

  def loandata_uri()
    @loandata_uri ||=
      "http://#{example_com}/loandata.json"
  end

  def loandata_body()
    @loandata_body ||= [
      {
        "amount" => 10, # 480023,
        "creditpolicy" => "policy1",
        "id" => "loan1",
        "positions" => [
          {
            "id" => "US2854091087",
            "quantity" => 81188
          }
        ]
      },
      {
        "amount" => 2533492,
        "creditpolicy" => "policy2",
        "id" => "loan0",
        "positions" => [
          {
            "id" => "US35906A1088",
            "quantity" => 4736
          },
          {
            "id" => "US9140901052",
            "quantity" => 97002
          }
        ]
      }
    ]
  end

  def creditpolicy_uri()
    @creditpolicy_uri ||=
      "http://#{example_com}/creditpolicy.json"
  end

  def creditpolicy_body()
    @creditpolicy_body ||= {
      "policy1" => {
        "currency" => "USD",
        "price" => 1.00
      },
      "policy2" => {
        "currency" => "USD",
        "price" => 10.00
      }
    }
  end

  def create_stubs()
    stub_request(:get, marketdata_uri)
      .to_return(body: marketdata_body().to_json())
    stub_request(:get, loandata_uri)
      .to_return(body: loandata_body().to_json())
    stub_request(:get, creditpolicy_uri)
      .to_return(body: creditpolicy_body().to_json())
  end

    def create_stubs_file_based(dir = "#{File.join(File.dirname(__FILE__), '..', 'data')}")
    marketdata_file = File.join(dir, 'marketdata.json')
    loandata_file = File.join(dir, 'loandata.json')
    creditpolicy_file = File.join(dir, 'creditpolicy.json')

    stub_request(:get, marketdata_uri)
      .to_return(body: File.read(marketdata_file))
    stub_request(:get, loandata_uri)
      .to_return(body: File.read(loandata_file))
    stub_request(:get, creditpolicy_uri)
      .to_return(body: File.read(creditpolicy_file))
  end

  def create_error_stubs()
    stub_request(:get, marketdata_uri)
      .to_return(status: [500, "Internal Server Error"])
    stub_request(:get, loandata_uri)
      .to_return(status: [500, "Internal Server Error"])
    stub_request(:get, creditpolicy_uri)
      .to_return(status: [500, "Internal Server Error"])
  end

end
