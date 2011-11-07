###############################################################################
# Scraping paraderos transantiago por recorrido
# http://github/Lucyan
###############################################################################
# version: 0.1b - 07-11-2011
#   versión alternativa, que genera archivos SQL para ser insertados
#
# - Paso 1: Obtiene listado de recorridos
# - Paso 2: Obtiene paraderos Ida de recorridos - out: salida/ida.txt
# - Paso 2: Obtiene paraderos Regreso de recorridos - out: salida/regreso.txt
###############################################################################

require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'open-uri'

puts "--- Iniciando Proceso Scraping paraderos de transantiago ---"
puts "Descargando listado de Recorridos..."


#--------------------------------------------------------------------------------------
# Inicio Paso 1
#--------------------------------------------------------------------------------------
url = "http://www.transantiago.gob.cl/paradero.do"
agent = Mechanize.new
page = agent.get(url)

i = 0
recorridos = []
# Busqueda por formulario
page.forms.each do |f|
  # Busqueda por campo
  f.fields.each do |field|
    # Select listado de recorridos
    if field.node["name"] == 'servicioBus'
      # Obtención opciones
      field.options.each do |opt|
         if opt.text.length < 10
           # Obtención texto opcion
           recorridos[i] = opt.text
           i += 1
         end
      end
    end
  end
end

puts "Descarga finalizada, se descargaron #{recorridos.length} recorridos"
#--------------------------------------------------------------------------------------
# Fin Paso 1
#--------------------------------------------------------------------------------------
puts "----------------------------------------------------------------"


#--------------------------------------------------------------------------------------
# Inicio Paso 2
#--------------------------------------------------------------------------------------
puts "Iniciando proceso descarga paraderos por recorrido-ida"

total = recorridos.length
procesando = 1
procesoTotal = 0
# Nuevo fichero en modo lectura (si existe, es eliminado)
File.open('salida/ida.sql', 'w') do |ida|
  # Ciclo recorre recorridos
  recorridos.each do |recorrido|
    puts "Procesando #{procesando} de #{total}"
    # Definición url por recorrido
    url = "http://www.transantiago.gob.cl/showItinerario.do?servicio=#{recorrido}&sentido=Ida"
    page = agent.get(url)
    # Obtención filas de tabla paraderos
    tabla = page.at("//table[@id='r_tabla']").search('tr')
    calle1 = []
    calle2 = []
    parada = []
    i = 0
    # Recorrido tabla paraderos
    tabla.each do |fila|
      # Obtención de columna esquina
      esquina = fila.search('td.r_esquina').text
      # Obtención columna paradero
      paradero = fila.search('td.f_SIMT').text
      # Inicio separación y formateo esquina y paradero
      calle1[i] = esquina.split(" / ").first
      calle2[i] = esquina.split(" / ").last
      if calle2[i] != nil
        caracter = calle2[i].scan(/-/);
        caracter.each do |c|
          if c == "-"
            calle1[i] = calle2[i].split(" - ").first
            calle2[i] = calle2[i].split(" - ").last
          end
        end
      end
      if esquina != nil
        par = paradero.split("(").last
        if par != nil
          parada[i] = par.split(")").first
        end
      end
      # Fin separación y formateo
      if calle1[i] != nil
        i += 1
      end
    end
    # Escribe en archivo
    i = 0
    parada.each do |p|
      ida.puts "insert into recorridos (recorrido, paradero, esquina, interseccion) values (#{recorrido},#{p},#{calle1[i]},#{calle2[i]});"
      i += 1
      procesoTotal += 1
    end
    procesando += 1
  end
end

puts "Descarga finalizada, se descargaron #{procesoTotal} registros"
#--------------------------------------------------------------------------------------
# Fin Paso 2
#--------------------------------------------------------------------------------------
puts "----------------------------------------------------------------"


#--------------------------------------------------------------------------------------
# Inicio Paso 3
#--------------------------------------------------------------------------------------
puts "Iniciando proceso descarga paraderos por recorrido-Regreso"

total = recorridos.length
procesando = 1
procesoTotal = 0
# Nuevo fichero en modo lectura (si existe, es eliminado)
File.open('salida/regreso.sql', 'w') do |regreso|
  # Ciclo recorre recorridos
  recorridos.each do |recorrido|
    puts "Procesando #{procesando} de #{total}"
    # Definición url por recorrido
    url = "http://www.transantiago.gob.cl/showItinerario.do?servicio=#{recorrido}&sentido=Regreso"
    page = agent.get(url)
    # Obtención filas de tabla paraderos
    tabla = page.at("//table[@id='r_tabla']").search('tr')
    calle1 = []
    calle2 = []
    parada = []
    i = 0
    # Recorrido tabla paraderos
    tabla.each do |fila|
      # Obtención de columna esquina
      esquina = fila.search('td.r_esquina').text
      # Obtención columna paradero
      paradero = fila.search('td.f_SIMT').text
      # Inicio separación y formateo esquina y paradero
      calle1[i] = esquina.split(" / ").first
      calle2[i] = esquina.split(" / ").last
      if calle2[i] != nil
        caracter = calle2[i].scan(/-/);
        caracter.each do |c|
          if c == "-"
            calle1[i] = calle2[i].split(" - ").first
            calle2[i] = calle2[i].split(" - ").last
          end
        end
      end
      if esquina != nil
        par = paradero.split("(").last
        if par != nil
          parada[i] = par.split(")").first
        end
      end
      # Fin separación y formateo
      if calle1[i] != nil
        i += 1
      end
    end
    # Escribe en archivo
    i = 0
    parada.each do |p|
      regreso.puts "insert into recorridos (recorrido, paradero, esquina, interseccion) values (#{recorrido},#{p},#{calle1[i]},#{calle2[i]})"
      i += 1
      procesoTotal += 1
    end
    procesando += 1
  end
end
puts "Descarga finalizada, se descargaron #{procesoTotal} registros"
#--------------------------------------------------------------------------------------
# Fin Paso 3
#--------------------------------------------------------------------------------------
