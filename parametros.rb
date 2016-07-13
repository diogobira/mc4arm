require 'roo'
require 'probability.rb'
require 'loader.rb'

class Parametros

	#Includes
	include Probability
	include Loader

	#Accessors para atributos derivados.
	attr_accessor :participantes
	attr_accessor :parametros

	#Inicialização
	def initialize(arquivo)

		sh = Roo::Spreadsheet.open(arquivo).sheet(0)
	
		keys = sh.row(1)
		types = sh.row(2)
		columns = sh.row(1).count
		
		@parametros = Hash.new
		(3..sh.last_row).each do |i|
			
			h = Hash.new
			
			(0..columns).each do |j|
				case types[j]
					when "Number" 
						h[keys[j].to_sym] = sh.row(i)[j].to_f
					when "String"
						h[keys[j].to_sym] = sh.row(i)[j].to_s
					when "Distribution"
						sp = sh.row(i)[j].split(" ")
						h[keys[j].to_sym] = {:distr  => sp[0], 
									  :params => sp.drop(1).map{|x| x.to_f}} 	
				end
			end
			
			@parametros[i-2] = h
		end
		
		#Arrays iniciais de participantes e dependentes
		@participantes = load_participantes(@parametros[1][:geral_arquivo_pessoas])
		
	end


end
