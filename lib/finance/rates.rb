require 'lib/finance/decimal'

module Finance
  # the Rate class provides an interface for working with interest rates.
  # {render:Rate#new}
  # @api public
  class Rate
    include Comparable

    # Accepted rate types
    TYPES = { :apr       => "effective",
              :apy       => "effective",
              :effective => "effective",
              :nominal   => "nominal" 
            }

    # @return [Integer] the duration for which the rate is valid, in months
    # @api public
    attr_accessor :duration
    # @return [DecNum] the effective interest rate
    # @api public
    attr_reader :effective
    # @return [DecNum] the nominal interest rate
    # @api public
    attr_reader :nominal

    # compare two Rates, using the effective rate
    # @return [Numeric] one of -1, 0, +1
    # @param [Rate] rate the comparison Rate
    # @example Which is better, a nominal rate of 15% compounded monthly, or 15.5% compounded semiannually?
    #   r1 = Rate.new(0.15, :nominal) #=> Rate.new(0.160755, :apr)
    #   r2 = Rate.new(0.155, :nominal, :compounds => :semiannually) #=> Rate.new(0.161006, :apr)
    #   r1 <=> r2 #=> -1
    # @api public
    def <=>(rate)
      @effective <=> rate.effective
    end

    # (see #effective)
    # @api public
    def apr
      self.effective
    end

    # (see #effective)
    # @api public
    def apy
      self.effective
    end

    # a convenience method which sets the value of @periods
    # @return none
    # @param [Symbol, Numeric] input the compounding frequency
    # @raise [ArgumentError] if input is not an accepted keyword or Numeric
    # @api private
    def compounds=(input)
      @periods = case input
                 when :annually     then Flt::DecNum 1
                 when :continuously then Flt::DecNum.infinity
                 when :daily        then Flt::DecNum 365
                 when :monthly      then Flt::DecNum 12
                 when :quarterly    then Flt::DecNum 4
                 when :semiannually then Flt::DecNum 2
                 when Numeric       then Flt::DecNum input.to_s
                 else raise ArgumentError
                 end
    end

    # set the effective interest rate
    # @return none
    # @param [DecNum] rate the effective interest rate
    # @api private
    def effective=(rate)
      @effective = rate
      @nominal = Rate.to_nominal(rate, @periods)
    end

    # create a new Rate instance
    # @return [Rate]
    # @param [Numeric] rate the decimal value of the interest rate
    # @param [Symbol] type a valid {TYPES rate type}
    # @param [optional, Hash] opts set optional attributes
    # @option opts [String] :duration a time interval for which the rate is valid
    # @option opts [String] :compounds (:monthly) the number of compounding periods per year
    # @example create a 3.5% APR rate
    #   Rate.new(0.035, :apr) #=> Rate(0.035, :apr)
    # @see http://en.wikipedia.org/wiki/Effective_interest_rate
    # @see http://en.wikipedia.org/wiki/Nominal_interest_rate
    # @api public
    def initialize(rate, type, opts={})
      # Default monthly compounding.
      opts = { :compounds => :monthly }.merge opts

      # Set optional attributes..
      opts.each do |key, value|
        send("#{key}=", value)
      end

      # Set the rate in the proper way, based on the value of type.
      begin
        send("#{TYPES.fetch(type)}=", rate.to_d)
      #rescue KeyError
			rescue 
        raise ArgumentError, "type must be one of #{TYPES.keys.join(', ')}", caller
      end
    end

    def inspect
      "Rate.new(#{self.apr.round(6)}, :apr)"
    end

    # @return [DecNum] the monthly effective interest rate
    # @example
    #   rate = Rate.new(0.15, :nominal)
    #   rate.apr.round(6) #=> DecNum('0.160755')
    #   rate.monthly.round(6) #=> DecNum('0.013396')
    # @api public
    def monthly
      (self.effective / 12).round(15)
    end

    # set the nominal interest rate
    # @return none
    # @param [DecNum] rate the nominal interest rate
    # @api private
    def nominal=(rate)
      @nominal = rate
      @effective = Rate.to_effective(rate, @periods)
    end

    # convert a nominal interest rate to an effective interest rate
    # @return [DecNum] the effective interest rate
    # @param [Numeric] rate the nominal interest rate
    # @param [Numeric] periods the number of compounding periods per year
    # @example
    #   Rate.to_effective(0.05, 4) #=> DecNum('0.05095')
    # @api public
    def Rate.to_effective(rate, periods)
      rate, periods = rate.to_d, periods.to_d

      if periods.infinite?
        rate.exp - 1
      else
        (1 + rate / periods) ** periods - 1
      end
    end

    # convert an effective interest rate to a nominal interest rate
    # @return [DecNum] the nominal interest rate
    # @param [Numeric] rate the effective interest rate
    # @param [Numeric] periods the number of compounding periods per year
    # @example
    #   Rate.to_nominal(0.06, 365) #=> DecNum('0.05827')
    # @see http://www.miniwebtool.com/nominal-interest-rate-calculator/
    # @api public
    def Rate.to_nominal(rate, periods)
      rate, periods = rate.to_d, periods.to_d

      if periods.infinite?
        (rate + 1).log
      else
        periods * ((1 + rate) ** (1 / periods) - 1)
      end
    end

    private :compounds=, :effective=, :nominal=
  end
end
