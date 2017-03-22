# encoding: UTF-8

require "net/http"
require "uri"
require "json"

class LoanScreener

  attr_accessor :uri_marketdatajson
  attr_accessor :uri_loandatajson
  attr_accessor :uri_creditpolicyjson

  attr_accessor :marketdata
  attr_accessor :loandata
  attr_accessor :creditpolicy

  def initialize(uris)
    @uri_marketdatajson = uris['marketdatajson']
    @uri_loandatajson = uris['loandatajson']
    @uri_creditpolicyjson = uris['creditpolicyjson']
    @marketdata = nil
    @loandata = nil
    @creditpolicy = nil
    @defaulting_loans = []
  end

  def fetch_data_from_json(uri, &block)
    resp = Net::HTTP.get_response(URI(uri))
    data = case resp
    when Net::HTTPSuccess then
        JSON.parse(resp.body)
    else
      raise "uri:#{uri} cannot be accessed"
    end
    if block
      # Return the yield-ed data from the block
      yield data
    else
      # Return the or
      data
    end
  end

  def load_data()
    @marketdata = fetch_data_from_json(uri_marketdatajson) do |md|
      # Turn market data into a hash for faster lookups
      h = Hash.new
      md.each do |item|
        h[ item['id'] ] = item if item['id']
      end
      h
    end
    @loandata = fetch_data_from_json(uri_loandatajson)
    @creditpolicy = fetch_data_from_json(uri_creditpolicyjson)
    self
  end

  def create_report()
    puts @defaulting_loans.to_json
  end

  def screen()
    # Process loan entries
    loandata.each do |loan|

      eligible_positions = 0
      collateral_value = 0

      # Validity check on loan entry
      # Skip the loan if not valid
      next if(!loan['creditpolicy'])
      next if(!loan['positions'])
      next if(!loan['amount'])

      l_cp = loan['creditpolicy']

      # Validity check on credit policy entry of loan
      # skip the loan if not valid
      l_cpe = creditpolicy[l_cp]
      next if !l_cpe
      l_cp_ccy = l_cpe['currency']
      next if !l_cp_ccy
      l_cp_pric = l_cpe['price']
      next if !l_cp_pric

      loan['positions'].each do |po|
        # Validity check on loan position data
        # Skip loan position if not valid
        p_id = po['id']
        next if !p_id
        p_qty = po['quantity']
        next if !p_qty

        # Validity check on market data entry of loan position
        # Skip loan position if not valid
        p_mde = marketdata[ po['id'] ]
        next if !p_mde
        p_md_ccy = p_mde['currency']
        next if !p_md_ccy
        p_md_pric = p_mde['price']
        next if !p_md_pric

        # Eligibility test on the loan position
        # Skip loan position if not eligible
        next if(p_md_ccy != l_cp_ccy)
        next if(p_md_pric < l_cp_pric)

        # Eligible position so it needs to add to the loan collateral value
        # STDERR.puts "po=#{po}"
        # STDERR.puts "l_cp=#{l_cp}"
        # STDERR.puts "p_mde=#{p_mde}"
        eligible_positions = (eligible_positions + 1)
        collateral_value = (collateral_value + p_qty * p_md_pric)
        # STDERR.puts "collateral_value=#{collateral_value}"
      end
      # Skip loan if it has no any eligible position
      next if(eligible_positions < 1)
      # Skip loan if not in default
      # STDERR.puts "loan=#{loan}"
      next if(collateral_value > loan['amount'])
      # Generate alert report for the defaulting loan
      report = {
        "id" => loan['id'],
        "creditpolicy" => loan['creditpolicy'],
        "amount" => loan['amount'],
        "eligible_collateral" => collateral_value
      }
      # STDERR.puts "report=#{report}"
      @defaulting_loans.push(report)
    end
    # STDERR.puts "@defaulting_loans=#{@defaulting_loans}"
    self
  end
end
