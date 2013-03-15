require 'lib/finance'
require 'ostruct'

class Analyzer

	include Finance

	def initialize
	end

	############################################################################
	# Métodos principais
	############################################################################
	
	############################################################################
	# Métodos de apoio
	############################################################################

	def teste
		@transactions = []
		@transactions << Transaction.new(-1000, :date => Time.utc(1985,01,01))
		@transactions << Transaction.new(  600, :date => Time.utc(1990,01,01))
		@transactions << Transaction.new(  600, :date => Time.utc(1995,01,01))
		puts @transactions.xnpv(0.6)	
	end

	#Recupera os arrays de fluxo de caixa para uma dada simulação e combinação de parâmetros
	def get_cashflows(simulation_id, combination_id)
		cashflows = Array.new
		return cashflows
	end

	#Calula o NPV de um fluxo de caixa
	def npv(cashflow, rate)
	end

	#Calula o FV de um fluxo de caixa
	def fv(cashflow, rate)
	end

	#Calcula o valor em caixa em um dado instante do tempo
	def cash_availability(t, cashflow, rate)
	end

	#Calula o NPV de cada um dos casflows de uma lista
	def npvs(cashflow_list, rate)
	end

	############################################################################
	# Médias
	############################################################################

	#Calcula a média simples do NPV de um cashflow dada uma lista de possíveis taxas de desconto
	def mean_npv(cashflows,rates)
	end

	def mean_fv(cashflows,rates)
	end

	def mean_cash_availability(t, cashflows, rates)
	end

	############################################################################
	#
	############################################################################


end
