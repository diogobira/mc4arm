#!/bin/env ruby
# encoding: utf-8

require 'persistencia'
require 'probability'
require 'lib/finance'
require 'ostruct'
require 'analyzer_helper.rb'

class Analyzer

	include Finance
	include AnalyzerHelper

	def initialize(sim_key)
		@sim_key = sim_key
		@cashflow_col = "cashflows"
		@parametros = parameter_combinations(@sim_key)
	end

	#Teste
	def teste
		
	end

	#Calcula o "MEAN NPV" para todos as combinações de parametros usadas em uma simulação, dada uma lista de taxas de desconto
	def run_mean_npv(rates)
		mean_npvs = Array.new
		@parametros.each do |p|
			cashflows = get_cashflows(@sim_key, p)
			mean_npvs << {:parameters => p, :mean_npv => mean_npv(cashflows,rates)}
		end
		#Do something with "mean_npvs"
	end

	#Calcula o "MEAN NPV at T" para todos as combinações de parametros usadas em uma simulação, dada uma lista de taxas de desconto	
	def run_mean_npvt(rates)
		mean_npvts = Array.new
		@parametros.each do |p|
			cashflows = get_cashflows(@sim_key, p)
			mean_npvts << {:parameters => p, :mean_npvt => mean_npvt(cashflows, rates)}
		end
		#Do something with "mean_npvs"
	end

	#Calcula o tempo para ocorrencia do crash com uma determinada probabilidade
	def run_time_to_crash(rates,options={})
		time2crash = Array.new
		@parametros.each do |p|
			cashflows = get_cashflows(@sim_key, p)
			time2crash << {:parameters => p, :t => time_to_crash(cashflows, rates, options)}
		end
		#Do something with "time2crash"
	end



end

