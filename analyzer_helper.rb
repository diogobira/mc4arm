require 'persistencia'
require 'probability'
require 'lib/finance'
require 'ostruct'

module AnalyzerHelper

	include Finance

	#Retorna um array de hashes, onde cada hash representa uma combinação de parâmetro usada na simulação
	def parameter_combinations(sim_key)
		pc = Array.new
		pc << {:previdencia_qtd_contribuicoes_ano => 13}
		return pc
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


	############################################################################
	# Métodos de cálculo
	############################################################################

	#Calula o NPV de um fluxo de caixa
	def npv(cashflow, rate)
		return cashflow.cash.npv(rate)			
	end

	#Retorna uma lista de NPVs dados uma lista de cashflows e uma lista de taxas de desconto
	def npvs(cashflows, rates)
		npvs_list = Array.new
		cashflows.each do |cf|
			rates.each do |r| 
				npvs_list << npv(cf, r)
			end
		end
		return npvs_list
	end

	#Calcula a média simples do NPV de multiplos cashflows dada uma lista de taxas de desconto
	def mean_npv(cashflows,rates)
		return npvs(cashflows, rates).mean
	end

	#Calcula o NPV em um cada instante do tempo para um dado fluxo de caixa
	def npvt(cashflow, rate)
		npvts = Array.new
		horizonte = cashflow.years.size
		(1..horizonte).each do |t|
			a = OpenStruct.new
			cash_until_t = cashflow.cash[0,t]
			cash_after_t = cashflow.cash[t,cashflow.years.size-1]
			npv_0_t = cash_until_t.npv(rate)
			npv_t_end = cash_after_t.npv(rate)
			a.t = cashflow.years[t] 
			a.cash = npv_0_t * (1+rate)**t + npv_t_end
			npvts << a
		end
		return npvts
	end

	#Retorna uma lista de "NPV at T" dados uma lista de cashflows e uma lista de taxas de desconto
	def npvts(cashflows, rates)

		#Arrays auxiliares
		mnpvt_list = Array.new	
		npvt_list = Array.new 

		#Horizonte de análise
		horizonte = cashflows[0].years.size
	
		#Para cada cashflow e cada taxa, calcula o NPV at T
		cashflows.each do |cf|
			rates.each {|r| npvt_list << npvt(cf, r)}
		end

		#Para cada período, calcula o MEAN NPV at T
		(1..horizonte).each do |t|
			a = OpenStruct.new
			npvt_list_t = Array.new
			npvt_list.each { |ca| npvt_list_t << ca[t-1].cash }
			a.npvts, a.t = npvt_list_t, cashflows[0].years[t-1]
			mnpvt_list << a
		end

		return mnpvt_list

	end

	#Calcula a média simples do "MEAN NPV at T" de multiplos cashflows dada uma lista de taxas de desconto
	def mean_npvt(cashflows, rates)
		mean_npvts = Array.new
		npvts = npvts(cashflows, rates)
		npvts.each do |a|
			b = OpenStruct.new
			b.cash, b.t = a.npvts.mean, a.t
			mean_npvts << b
		end
		return mean_npvts
	end
	
	############################################################################
	# Métodos de cálculo de tempo até o crash
	############################################################################

	#Calcula o tempo para a o crash com base em uma restrição probabilística.
	def time_to_crash(cashflows, rates, options={})
		t = 0
		opt = {:prob=>1,:value=>0}
		opt.merge!(options)
		#Calcula o tempo t...
		return t
	end

	############################################################################
	# Métodos de preparação e dados para histogramas
	############################################################################

	def histogram_data_npv(cashflows, rates)
		return Probability.prepare_histogram_data(npvs(cashflows, rate))
	end

	def histogram_data_npvt(cashflows, rates)
		return Probability.prepare_histogram_data(npvts(cashflows, rates))		
	end

	############################################################################
	# Métodos de ajustes de distribuição
	############################################################################

	def fit_distribution
	end

end
