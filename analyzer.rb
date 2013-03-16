require 'persistencia'
require 'probability'
require 'lib/finance'
require 'ostruct'

class Analyzer

	include Finance

	def initialize(sim_key)
		@sim_key = sim_key
	end

	############################################################################
	# Métodos principais
	############################################################################
	
	############################################################################
	# Métodos de apoio
	############################################################################

	def teste
		cashflows = get_cashflows(@sim_key, {:previdencia_qtd_contribuicoes_ano => 13})
		cashflows.each do |cf|
		end
	end

	#Faz um split da estrutura do cash flow em três partes: parametros, valores e anos
	def split_cashflow(cashflow)
		splited_cashflow = OpenStruct.new
		cashflow_cash, cashflow_years = Array.new, Array.new
		cashflow['flows'].each do |v|
			cashflow_cash << v['receitas'] - v['despesas']
			cashflow_years << v['ano']
		end
		cashflow.delete('flows')
		cashflow_parameters = cashflow
		splited_cashflow.parameters = cashflow_parameters
		splited_cashflow.cash = cashflow_cash
		splited_cashflow.years = cashflow_years
		return splited_cashflow
	end

	#Recupera os arrays de fluxo de caixa para uma dada simulação e outros criterios de pesquisa
	def get_cashflows(simulation_key, options = {})
		cashflows = Array.new
		criterios = {:sim_key => simulation_key}.merge!(options)		
		Persistencia.le("cashflows", criterios) do |cursor|
			cursor.each do |cf|
				cashflows << split_cashflow(cf)
			end
		end
		return cashflows
	end

	############################################################################
	# Métodos de cálculo
	############################################################################

	#Calula o NPV de um fluxo de caixa
	def npv(cashflow, rate)
		parameters, cash, years = cashflow.parameters, cashflow.cash , cashflow.years
		return cash.npv(rate)			
	end

	#Calcula o valor em caixa em um cada instante do tempo para um dado fluxo de caixa
	def cash_availability(cashflow, rate)
		availabilities = Array.new
		horizonte = cashflow.years.size
		(1..horizonte).each do |t|
			a = OpenStruct.new
			cash_until_t = cashflow.cash[0,t]
			cash_after_t = cashflow.cash[t,cashflow.years.size-1]
			npv_0_t = cash_until_t.npv(rate)
			npv_t_end = cash_after_t.npv(rate)
			a.t = cashflow.years[t] 
			a.cash = npv_0_t * (1+rate)**t
			availabilities << a
		end
		return availabilities
	end

	#Calula o NPV de cada um dos casflows de uma lista
	def npvs(cashflow_list, rate)
		npvs_list = Array.new	
		cashflow_list.each {|cf| npvs_list << npv(cashflow, rate)}
		return npvs_list
	end

	############################################################################
	# Médias
	############################################################################

	#Calcula a média simples do NPV de um cashflow dada uma lista de possíveis taxas de desconto
	def mean_npv(cashflow,rates)
		rates.each{|r| npvs_list << npv(cashflow, r)}
		return npvs_list.mean
	end

	def mean_npvs(cashflows,rates)
		cashflows.each do |cf|
		end
	end

	#Retorna um array com a disponibilidade media de caixa em ada instante do tempo dada uma lista de taxas de desconto
	def mean_cash_availability(cashflow, rates)
		mca_list = Array.new	
		ca_list = Array.new 
		rates.each {|r| ca_list << cash_availability(cashflow, r)}
		horizonte = cashflow.years.size
		(1..horizonte).each do |t|
			a = OpenStruct.new
			ca_list_at_t = Array.new
			ca_list.each do |ca|
				ca_list_at_t << ca[t-1].cash
			end
			a.cash, a.t = ca_list_at_t.mean, cashflow.years[t-1]
			mca_list << a
		end
		return mca_list
	end

	############################################################################
	#
	############################################################################

end

