require 'lib/finance/cashflows'
require 'lib/finance/interval'

# The *Finance* module adheres to the following conventions for
# financial calculations:
#
#  * Positive values represent cash inflows (money received); negative
#    values represent cash outflows (payments).
#  * *principal* represents the outstanding balance of a loan or annuity.
#  * *rate* represents the interest rate _per period_.
module Finance
  autoload :Amortization, 'lib/finance/amortization'
  autoload :Rate,         'lib/finance/rates'
  autoload :Transaction,  'lib/finance/transaction'
end
