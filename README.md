# Loan Screener

Loan Screener is a proto Command-line Interface program to screen defaulting loans in a banking infrastructure taking the loan data, the loan credit policy data and the loan equity porfolio share prices (market data) from the internet from one or more banking subsidiaries.

The program
- takes url-s of Json files of market data, loan data and credit policies as command-line parameters and
- generates json output on STDOUT showing which loans are now in default
- if any error occured it would be reported on STDERR  

**Notes**
* Loans contain:
    - a reference to the credit policy
    - a loan id
    - an amount which the borrower has borrowed.
    - a series of equity positions, consisting of an ISIN (id) and the number of shares owned.
* Credit policies consist of a policy id, a currency and a minimum acceptable equity price.
  - Any equity whose price is below this (per share) is ignored for the purposes of calculating the collateral of the loan.
  - Any equity whose currency does not match is ignored.
* The value of the collateral is number of eligible shares x eligible price of share. If the credit policy deems shares ineligible they are omitted from the calculation.
* A loan is considered in default if its eligible 

**Example output**

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

## Design

* the choice of programming language is: ruby
* use the Net::HTTP lib of Ruby Standard Library to do http get to retrieve the market data, loan data and credit policies data from the internet
* use the json lib of Ruby Standard Library which natively supports the json format
* use JSON.parse() and JSON.to_json() to do conversion between json and ruby expressions

### Call Follow
- get the content of market data, loan data and credit policy json
- process loan data (which is an array of loans) for default checks
- calculate the eligible collateral value for all loan 
- do eligibilty check for the loan equity positions according to the loan credit policy (eligibility check for currency and price threshold)
- establishes if loan is in default
    * loan in default if:
        - *eligible-calculated-loan-collateral-value> < loan-amount*
- generate report from all collected defaulting loans
- format report entries as per requirement on STDOUT
- report any error occured on STDERR

*Note: if there is no any eligible positon for a loan then this loan is not regarded as defaulting loan*

### Unit Test
- used Ruby MiniTest framwork for unit testing and
- used Ruby WebMock gem to stub to mock remote HTTP file server so that the test cases can run without a real internet connection   
- the test checks error and success senerios
- if a report expected all the reporting entries are checked in the output json if all reprorting attributes are present

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

### See usage

````````````````````````
Usage: ruby -Ilib bin/loanscreener <url-of-marketdata-json> <url-of-loandata-json> <url-of-creditpolicy-json>
       ruby -Ilib bin/loanscreener http://ws.jenojakab.com/files/marketdata.json \
                     http://ws.jenojakab.com/files/loandata.json \
                     http://ws.jenojakab.com/files/creditpolicy.json

Options:
--help        Prints this help
````````````````````````

### Run these commands

````````````````````````
> cd Code
> ruby -Ilib bin/loanscreener <url-of-marketdata-json> <url-of-loandata-json> <url-of-creditpolicydata-json>
````````````````````````

## To Run the Unit Test
### Run these commands

````````````````````````
> cd Code
> rake test
````````````````````````

The test results would be genereted on the console.

### Example test results

````````````````````````
> rake test

# Running:

 .....

Finished in 0.032282s, 154.8846 runs/s, 1827.6378 assertions/s.

5 runs, 59 assertions, 0 failures, 0 errors, 0 skips

````````````````````````
