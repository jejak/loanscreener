# encoding: UTF-8

require_relative "test_helper"

class LoanScreenerTestSet1 < Minitest::Test

  include LsrTestCommons

  def setup
    @uris = {
      "marketdatajson" => marketdata_uri,
      "loandatajson" => loandata_uri,
      "creditpolicyjson" => creditpolicy_uri
    }

    @lsr = LoanScreener.new @uris
  end

  def test__two_loans_one_pos_not_eligible_by_cp_thr__should_return_one_loan_alert

    # Stubs
    create_stubs()

    out, err = capture_io do
      @lsr
        .load_data()
        .screen()
        .create_report()
    end

    # Check if there is no error output
    assert_empty err

    # Check captured output
    json_res = out
    res = JSON.parse(json_res)

    assert_kind_of Array, res
    assert_equal 1, res.length
    res.each do |rep|
      # Check report entry
      assert_kind_of Hash, rep
      assert_equal 4, rep.length
      # Check if all fields are present
      assert rep.key?("id")
      assert rep.key?("creditpolicy")
      assert rep.key?("amount")
      assert rep.key?("eligible_collateral")
    end
    expCollateralValue = (17.2000 * 97002)
    assert_equal expCollateralValue, res[0]["eligible_collateral"]
  end

  def test__two_loans_one_pos_not_eligible_by_cp_thr__should_return_two_loan_alert

    loandata_body[0]['amount'] = 480023

    # Stubs
    create_stubs()

    out, err = capture_io do
      @lsr
        .load_data()
        .screen()
        .create_report()
    end

    # Check if there is no error output
    assert_empty err

    # Check captured output
    json_res = out
    res = JSON.parse(json_res)

    assert_kind_of Array, res
    assert_equal 2, res.length
    res.each do |rep|
      # Check report entry
      assert_kind_of Hash, rep
      assert_equal 4, rep.length
      # Check if all fields are present
      assert rep.key?("id")
      assert rep.key?("creditpolicy")
      assert rep.key?("amount")
      assert rep.key?("eligible_collateral")
    end
    expCollateralValue1 = (3.7800 * 81188)
    assert_equal expCollateralValue1, res[0]["eligible_collateral"]
    expCollateralValue2 = (17.2000 * 97002)
    assert_equal expCollateralValue2, res[1]["eligible_collateral"]
  end

  def test__two_loans_two_pos_not_eligible_by_cp_ccyandthr__should_return_one_loan_alert

    loandata_body[0]['amount'] = 480023
    marketdata_body[2]['currency'] = 'EUR'

    # Stubs
    create_stubs()

    out, err = capture_io do
      @lsr
        .load_data()
        .screen()
        .create_report()
    end

    # Check if there is no error output
    assert_empty err

    # Check captured output
    json_res = out
    res = JSON.parse(json_res)

    assert_kind_of Array, res
    assert_equal 1, res.length
    res.each do |rep|
      # Check report entry
      assert_kind_of Hash, rep
      assert_equal 4, rep.length
      # Check if all fields are present
      assert rep.key?("id")
      assert rep.key?("creditpolicy")
      assert rep.key?("amount")
      assert rep.key?("eligible_collateral")
    end
    expCollateralValue = (17.2000 * 97002)
    assert_equal expCollateralValue, res[0]["eligible_collateral"]
  end

  def test__sample_data_from_files__should_return_two_loan_alert

    # Stubs
    create_stubs_file_based()

    out, err = capture_io do
      @lsr
        .load_data()
        .screen()
        .create_report()
    end

    # Check if there is no error output
    assert_empty err

    # Check captured output
    json_res = out
    res = JSON.parse(json_res)

    assert_kind_of Array, res
    assert_equal 2, res.length
    res.each do |rep|
      # Check report entry
      assert_kind_of Hash, rep
      assert_equal 4, rep.length
      # Check if all fields are present
      assert rep.key?("id")
      assert rep.key?("creditpolicy")
      assert rep.key?("amount")
      assert rep.key?("eligible_collateral")
    end
  end

  def test__internal_server_error__should_return_error

    # Stubs
    create_error_stubs()

    exp = assert_raises RuntimeError  do
      @lsr
        .load_data()
        .screen()
        .create_report()
    end

    # Verify exception
    err = exp.to_s
    assert_match(/Cannot/i, err)

  end

end
