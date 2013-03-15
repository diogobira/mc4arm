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
require 'analyzer'

############################################################################
# Opções 
############################################################################
class MC4ARMOptionsParser

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  # Return a structure describing the options.
  def self.parse(args)

    # Opções default
		data = Time.now
    options = OpenStruct.new
		options.log_level = "INFO"
		options.directory = "resultados_"
		options.parameter_file = "parametros.yml"
		options.run_times = 1
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
        options.run_times = n
      end

			#ID da simulação a ser analisada
      opts.on("-i","--id ID", "ID da simulação") do |id|
        options.id = id
      end

			#Diretório de saída dos resultados da simulação
      opts.on("-d","--dir DIRECTORY", "Diretório de resultados da simulação") do |d|
        options.directory = d
      end

			#Diretório de saída dos resultados da simulação
      opts.on("-o","--output-format FORMAT", ["csv","xml","html"], "Formato dos resultados (csv, xml, html)") do |d|
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

case options.mode

	when "simular"
		dispatcher = Dispatcher.new(options.parameter_file,options.run_times)
		dispatcher.run

	when "listar"
		browser = Browser.new()
		browser.listar_simulacoes

	when "analisar"
		analyzer = Analyzer.new()
		analyzer.teste

	else

	end


#pp options
#pp ARGV
