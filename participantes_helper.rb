module ParticipantesHelper

	#Indices dos participantes que atendem um determinado criterio
	def participantes_index(participantes,h)
		indexes = Array.new
		participantes.each_with_index do |p,index|
			criterios_atendidos = Array.new
			h.each_key do |k|
				criterios_atendidos << (p.instance_variable_get("@#{k.to_s}") == h[k])				
			end
			indexes << index if criterios_atendidos.reduce(:&)
		end
		return indexes
	end

	#Indices dos participantes que não atendem a um determinado critério
	def participantes_index_complementar(participantes,h)
		all_indexes = (0..participantes.length-1).to_a
		indexes = participantes_index(participantes,h)
		return all_indexes - indexes
	end

	#Indices dos participantes ativos
	def participantes_ativos(participantes)
		indexes = participantes_index(participantes,{:status=>"Ativo"})	
	end

	#Indices dos participantes desligados
	def participantes_desligados(participantes)
		indexes = participantes_index(participantes,{:status=>"Desligado"})	
	end



end
