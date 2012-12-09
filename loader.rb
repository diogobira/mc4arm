require 'csv'

module Loader

	#Carrega um arquivo CSV em um array de hashes com keys definidas pelos cabeçalhos do CSV
	def csv2hashes(arquivo)
		csv_data = CSV.read arquivo
		headers = csv_data.shift.map {|i| i.to_sym}
		string_data = csv_data.map {|row| row.map {|cell| cell.to_s}}
		array_of_hashes = string_data.map {|row| Hash[*headers.zip(row).flatten]}
		return array_of_hashes
	end
	

end
