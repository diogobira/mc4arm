#!/bin/env ruby
# encoding: utf-8

$:.unshift('.')

############################################################################
# Informações Gerais
############################################################################


############################################################################
# Dependências
############################################################################
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require 'parametros'
require 'simulador'
require 'dispatcher'
require 'browser'

#require 'analyzer'

############################################################################
# Opções 
############################################################################
class MC4ARMOptionsParser

  # Return a structure describing the options.
  def self.parse(args)

    # Opções default
		data = Time.now
    options = OpenStruct.new
		options.log_file = "/tmp/mc4arm.log"
		options.log_level = "INFO"
		options.simulation_directory = "tmp/simulacoes"
		options.analysis_directory = "tmp/analises"
		options.parameter_file = "parametros.xlsx"
		options.run_times = 1
		options.initial_wealth = 0
		options.notification_mail = ["diogobira@gmail.com"]
		options.paralelization_mode = "thread"
		options.output_format = "csv"
		options.charts = false

    # Parsing da Opções
    opt_parser = OptionParser.new do |opts|

      opts.banner = "Usage: mc4arm.rb [options]"
      opts.separator ""

			#Modo de execução
      opts.on("-m","--mode MODE",["listar", "simular", "analisar"], "Selecione modo de execução (listar, simular, analisar)") do |m|
        options.mode = m
      end

			#Quantidade de execucoes
      opts.on("-f","--parameter-file FILENAME", "Arquivo de parametros de simulação") do |filename|
        options.parameter_file = filename
      end

			#Quantidade de execucoes
      opts.on("-t","--run-times N", "Quantidade de execucoes") do |n|
        options.run_times = n.to_i
      end

			#Riqueza inicial do plano
      opts.on("-w","--initial-wealth W", "Riqueza inicial do plano") do |w|
        options.initial_wealth = w.to_i
      end


			#ID da simulação a ser analisada
      opts.on("-k","--key KEY", "Identificação da simulação") do |key|
        options.key = key
      end

			#Diretório de saída dos resultados da análise da simulação
      opts.on("--analysis-dir DIRECTORY", "Diretório de resultados da análise da simulação") do |d|
        options.analysis_directory = d
      end

			#Formato de saída dos resultados da simulação
      opts.on("-o","--output-format FORMAT", ["db", "csv","xml","html"], "Formato dos resultados (db, csv, xml, html)") do |d|
        options.output_format = d
      end

			#Gerar gráficos
      opts.on("-c","--charts", "Gerar graficos") do 
        options.charts = true
      end

			#Nível de log
      opts.on("-l","--log-level LEVEL", "Nivel de log da simulação") do |d|
        options.log_level = d
      end

			#Modo de paralelização
      opts.on("-p","--paralelization-mode MODE",["thread", "ironIO"], "Modo de paralelização a ser usada (thread, ironIO)") do |p|
        options.paralelization_mode = p
      end

      # Lista de emails para notificação
      opts.on("--mail mail1,mail2,mail3", Array, "Lista de emails para notificação") do |list|
        options.notification_mail = list
      end

			#Ajuda do programa
      opts.on_tail("-h", "--help", "Exibe esta mensagem de ajuda") do
        puts opts
				puts ""
        exit
      end

			#Versão do programa
     opts.on_tail("-v", "--version", "Exibe a versao do programa") do
        puts OptionParser::Version.join('.')
				puts ""
        exit
      end

    end

    opt_parser.parse!(args)
    options
  end  

end  

############################################################################
# Fluxo Principal 
############################################################################

options = MC4ARMOptionsParser.parse(ARGV)

#Modo de execução do Programa
case options.mode

	when "simular"
		dispatcher = Dispatcher.new(options.parameter_file,options.run_times)
		dispatcher.run

	when "listar"
		browser = Browser.new
		browser.listar_simulacoes()

	when "analisar"
		#Dir.mkdir(options.analysis_directory + "/#{options.key}_#{Time.now.strftime("%Y%m%d_%Hh%Mmin")}")
		analyzer = Analyzer.new(options.key)
		analyzer.teste

	else

	end


#pp options
#pp ARGV
