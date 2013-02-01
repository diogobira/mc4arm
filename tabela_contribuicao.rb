require 'algorithms.rb'
include Containers

class TabelaContribuicao < Trie

	#Carrega a Trie a partir de um array de hashes
	def load(arr)
		arr.each do |c|
			key = c[:status] + c[:quadro] + c[:nivel] + c[:classe].to_i.to_s
			self.push(key,c)
		end
	end

	#Faz uma pesquisa na Trie
	def detect(status,quadro,nivel,classe)
		key = status + quadro + nivel + classe.to_i.to_s
		node = self.get(key)
	end

end


