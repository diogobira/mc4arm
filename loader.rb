require 'csv'
require 'participante.rb'
module Loader

	#Carrega um arquivo CSV em um array de hashes com keys definidas pelos cabeçalhos do CSV
	def csv2hashes(arquivo)
		csv_data = CSV.read(arquivo)
		headers = csv_data.shift.map {|i| i.downcase.to_sym}
		string_data = csv_data.map {|row| row.map {|cell| cell.to_s}}
		array_of_hashes = string_data.map {|row| Hash[*headers.zip(row).flatten]}
		return array_of_hashes
	end

	####################################################################
	#Carga de parâmetros estruturados - Geral
	####################################################################

	def load_participantes(arquivo)
		participantes = Array.new
		hashes = csv2hashes(arquivo)
		hashes.each {|h| participantes << Participante.new(h)}
		return participantes
	end

	####################################################################
	#Carga de parâmetros estruturados - Patrocinador
	####################################################################
	def load_tabela_salarios(arquivo)
		tabela_salarios = csv2hashes(arquivo)
		return tabela_salarios
	end

	def load_tabela_ats(arquivo)
		tabela_ats = csv2hashes(arquivo)
		return tabela_ats
	end

	def load_tabela_funcoes(arquivo)
		tabela_funcoes = csv2hashes(arquivo)
		return tabela_funcoes
	end	

	####################################################################
	#Carga de parâmetros estruturados - Plano de Previdência
	####################################################################

	def load_tabua_mortalidade(arquivo)
	end

	def load_tabua_invalidez(arquivo)
	end

end
