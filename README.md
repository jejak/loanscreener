# Loan Screener

Loan Screener is a proto Command-line Interface program to screen defaulting loans in a banking infrastructure taking the loan data, the loan credit policy data and stock market quotes from the internet from one or more banking subsidiaries.

The program
- takes url-s of Json files of market data, loan data and credit policies as command-line parameters and
- generates json output on STDOUT showing which loans are now in default
- if any error occured it would be reported on STDERR  

Notes:
* Loans contain:
    - a reference to the credit policy
    - a loan id
    - an amount which the borrower has borrowed.
    - a series of equity positions, consisting of an ISIN (id) and the number of shares owned.
* Credit policies consist of a policy id, a currency and a minimum acceptable equity price.
  - Any equity whose price is below this (per share) is ignored for the purposes of calculating the collateral of the loan.
  - Any equity whose currency does not match is ignored.
* The value of the collateral is number of eligible shares x eligible price of share. If the credit policy deems shares ineligible they are omitted from the calculation.
* A loan is considered in default if the eligible value of the collateral is less than the outstanding amount borrowed.


Example output:

````````````````````
$ ruby -Ilib bin/loan-screener http://ws.jenojakab.com/files/marketdata.json \
              http://ws.jenojakab.com/files/loandata.json \
              http://ws.jenojakab.com/files/creditpolicy.json

[
  {
    "id": "loan1234",
    "creditpolicy": "policy1234",
    "amount": 10000,
    "eligible_collateral": 9999,
  },
  ...
]
````````````````````

  The project also contains:
     * unit test and
     * documentation

## Design

* the choice of programming language is: ruby
* use the Net::HTTP lib of the Ruby Standard Library to do http get to retrieve the market data, loan data and credit policies data from the internet
* use the json lib of the Ruby Standard Library which is natively support the json format
* used JSON.parse() and JSON.to_json() to do conversion between json and ruby expressions

Call Follow
- get the content of market data, loan data and credit policy json
- processed loan data which is an array of loan for default checks
- for all loan calculated eligible colleteral value
- eligibilty check done for the position data according to the loan credit policy (eligibility check for currency and price threshold)
- default established
- if eligible-calculated-loan-colleteral-value> < loan-amount
- generate report from all collected defaulted loan
- report entries formatted as per requirement

*Note: if there is no any eligible positon for a loan then this loan is not regarded as defaulting loan*

Unit test
- used Ruby MiniTests framwork for unit testing and
- used Ruby WebMock to fake remote HTTP file server so that the test cases can run without a real internet connection   
- the test checks error and success senerios
- if report expacted the reporting entries are checked if they are complete in the output json

## Notation

*The folder where the git project has been cloned will be referred as **Code** from now*.

## To build the program

### Run bundle install  

To build the program run the following commands.

````````````````````
> cd Code
> bundle install
````````````````````

## To run the Loan Screener program

### Do the build step

Do the above build step

### See Usage

````````````````````````
Usage: ruby -Ilib bin/loanscreener <url-of-marketdata-json> <url-of-loandata-json> <url-of-creditpolicy-json>
       ruby -Ilib bin/loanscreener http://ws.jenojakab.com/files/marketdata.json \
                     http://ws.jenojakab.com/files/loandata.json \
                     http://ws.jenojakab.com/files/creditpolicy.json

Options:
--help        Prints this help"
````````````````````````

## Run these Commands

````````````````````````
> cd Code
> ruby -Ilib bin/loanscreener <url-of-marketdata-json> <url-of-loandata-json> <url-of-creditpolicydata-json>
````````````````````````

## To Run the unit test

````````````````````````
> cd Code
> rake test
````````````````````````

The test results would genereted on the console.

(Example result)

````````````````````````
> rake test

# Running:

 .....

Finished in 0.032282s, 154.8846 runs/s, 1827.6378 assertions/s.

5 runs, 59 assertions, 0 failures, 0 errors, 0 skips

````````````````````````

