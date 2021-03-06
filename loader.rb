require 'csv'
require 'participante.rb'
require 'string.rb'
require 'tabua.rb'
require 'tabela_contribuicao.rb'
require 'tabela_ats.rb'
require 'tabela_fator_pensao.rb'

module Loader

	#Carrega um arquivo CSV em um array de hashes com keys definidas pelos cabeçalhos do CSV
	def csv2hashes(arquivo)
		csv_data = CSV.read(arquivo)
		headers = csv_data.shift.map {|i| i.downcase.to_sym}
		data = csv_data.map {|row| row.map {|cell| cell.to_s.is_numeric? ? cell.to_s.to_numeric : cell.to_s }}
		array_of_hashes = data.map {|row| Hash[*headers.zip(row).flatten]}
		return array_of_hashes
	end

	####################################################################
	#Carga de parâmetros estruturados - Geral
	####################################################################

	def load_participantes(arquivo)
		participantes = Array.new
		hashes = csv2hashes(arquivo)
		hashes.each {|h| participantes << Participante.new(h, true)}
		return participantes
	end

	####################################################################
	#Carga de parâmetros estruturados
	####################################################################
	def load_tabela(arquivo)
		tabela = csv2hashes(arquivo)
	end

	def load_tabua(arquivo)
		array = csv2hashes(arquivo)
		tabua = Tabua.new
		tabua.load(array)
		return tabua
	end

	def load_tabela_contribuicao(arquivo)
		array = csv2hashes(arquivo)
		tabela = TabelaContribuicao.new
		tabela.load(array)
		return tabela
	end

	def load_tabela_ats(arquivo)
		array = csv2hashes(arquivo)
		tabela = TabelaAts.new
		tabela.load(array)
		return tabela
	end

	def load_tabela_fator_pensao(arquivo)
		array = csv2hashes(arquivo)
		tabela = TabelaFatorPensao.new
		tabela.load(array)
		return tabela
	end

end
