#!/bin/bash

ayuda () {
	echo " ----- enccarpe -----"
	echo "Este script es para encriptar todos los archivos dentro de una carpeta con gpg"
	echo "Opciones a emplear:"
	echo "		-u  "remitente para firma""
	echo "		-c  "comprimir""
	echo "    -cp "comprimir por carpetas""
	echo " 		-b  "borrar lo ya encriptado""
	echo "		-r  "destinado""
	echo "		-d  "directorio""
	echo "		-ayuda "ayuda""
	
	echo " "
	echo "Ejemplo:"
	echo "		* enccarpe -c -r Emilio -u Emilio -d /home      <- Firma, comprime en 1 archivo el directorio home y conserva los archivos que contiene"
	echo "		* enccarpe -c -b -r Emilio -u Emilio -d /home   <- Firma, comprime en 1 archivo el directorio home y borra los archivos originales a encriptar"
	echo "		* enccarpe -r Emilio                            <- encripta por separado cada archivo dentro del directorio en donde me encuentro"
	echo "    * enccarpe -b -cp -r Emilio -u Emilio -d ./prueba/ <- Firma, comprime por directorio los archivos de cada uno y borra los archivos originales"
	echo " "
	echo "Licencia: GNU GENERAL PUBLIC LICENSE Versión 3"
	echo "Creado por: Emilio Jesus Calderon"
}
# Codigo...

# 	Funciones...

encriptarComprimidoPorCarpeta () {
	listaAdirectorios=$(find $directorio -type d)
	contador=0
	contadorArchivosAencriptar=0
	totalAdirectorios=$(find $directorio -type d | wc -l)
	for directoriosAC in $listaAdirectorios
	do
		contador=$(expr $contador + 1)
		directoriosAC=$(readlink -e $directoriosAC)
		listaAcomprimir=" "
		listaAcomprimir=$(find $directoriosAC -maxdepth 1 -type f,l,c,b)
		contadorArchivosAencriptar=$(expr $contadorArchivosAencriptar + $(find $directoriosAC -maxdepth 1 -type f,l,c,b | wc -l))
		$(zip $directoriosAC-encr.zip $listaAcomprimir > /dev/null)
		encriYa="$encri $directoriosAC-encr.zip" 
		$($encriYa)
		if [ "$parameB" == "true" ]; then
			echo "borrando originales... carpeta $contador de $totalAdirectorios"
			for borraran in $listaAcomprimir
			do
				$(rm $borraran)
			done
		else
			echo "no se borraran los originales..."
		fi
		$(mv "$directoriosAC-encr.zip.gpg" $directoriosAC > /dev/null)
		$(rm "$directoriosAC-encr.zip")
	done
	echo "finalizado. encriptado y comprimido $contadorArchivosAencriptar archivos."
}

encriptarComprimido () {
	encriYa="$encri $(date +%F).zip"
	$($encriYa)
	if [ "$parameB" == "true" ]; then
		echo "finalizado. borrando archivos normales $totalAencriptar"
		$(rm $(date +%F).zip)
		echo "$directorio$listaC"
		$(rm $listaC)
	else
		$(rm $(date +%F).zip)
		echo "finalizado. archivos encriptado y comprimido $totalAencriptar"
	fi
}

encriptarMasa () {
	contador=0
	listaAencriptar=$(find $directorio -type f,l,c,b)
	totalAencriptar=$(find $directorio -type f,l,c,b | wc -l)
	for archivosC in $listaAencriptar
	do
		contador=$(expr $contador + 1)
		encriLS="$encri $archivosC"
		$($encriLS)
		if [ "$parameB" == "true" ]; then
			echo "finalizado. borrando archivo normal $contador de $totalAencriptar"
			$(rm "$archivosC")
		else
			echo "finalizado. $contador de $totalAencriptar"
		fi
	done
}

encriptando () {
	if [ "$parameC" == "true" ]; then
		encriptarComprimido
	elif [ "$parameCP" == "true" ]; then
		encriptarComprimidoPorCarpeta
	else
		encriptarMasa
	fi
}

comprimirArchivos () {
	if [ "$parameC" == "true" ]; then
		echo "comprimiendo..."
		listaC=$(find $directorio -type f,l,c,b )
		totalAencriptar=$(find $directorio -type f,l | wc -l)
		$(zip -r $(date +%F).zip $directorio/* > /dev/null)
	elif [ "$parameCP" == "true" ]; then
		echo "comprimiendo por carpeta/s..."
	else
		echo "no se comprimira..."
	fi
}

comprobarAnterior () {
	#echo "anterior es $parametroAnterior"
	if [ "$parametroAnterior" == "-r" ]; then
		destinatario="$parametro"
		parameR="true"
		if [ -n "$(gpg --list-secret-keys | grep $destinatario)" ]; then
			parameR="true"
		else
			echo "ERROR:No se encontro llave"
			todoOkey="false"
		fi
	elif [ "$parametroAnterior" == "-u" ]; then
			remitente="$parametro"
		if [ -n "$(gpg --list-public-keys | grep $remitente)" ]; then
			parameU="true"
		else
			echo "ERROR:No se encontro llave"
			todoOkey="false"
		fi
	elif [ "$parametroAnterior" == "-d" ]; then
		if [ -d "$parametro" ]; then
			directorio="$parametro"
		else
			echo "ERROR:No es un directorio"
			todoOkey="false"
		fi
	else
		echo "ERROR SE OLVIDO PARAMETRO"
		todoOkey="false"
	fi
}

comprobarParametro () {
	if [ "$parametro" == "-c" ]; then
		parameC="true"
		if [ "$parameCP" == "true" ]; then
			todoOkey="false"
			echo "error no se puede poner -cp y -c a la vez"
		fi
	elif [ "$parametro" == "-cp" ]; then
		parameCP="true"
		if [ "$parameC" == "true" ]; then
			todoOkey="false"
			echo "error no se puede poner -cp y -c a la vez"
		fi
	elif [ "$parametro" == "-b" ]; then
		parameB="true"
	elif [ "$parametro" == "-r" ]; then
		parameR="false"
	elif [ "$parametro" == "-u" ]; then
		parameU="true"
	elif [ "$parametro" == "-d" ]; then
		parameD="true"
	elif [ "$parametro" == "-ayuda" ];then
		ayuda
	else
		if [ "$parametro" != "$1"  ]; then
			comprobarAnterior
		else
			echo "Parametro INCORRECTO"
			todoOkey="false"
		fi
	fi
}

# 	Main...

todoOkey="true"
directorio="$(pwd 2> /dev/null)"

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

for parametro in $*
do
	comprobarParametro
	parametroAnterior="$parametro"
done

if [ "$todoOkey" == "true" -a "$parameR" == "true" ]; then
	echo "Ejecutando..."
	if [ "$parameU" == "true" ]; then
		echo "firmando"
		encri="gpg -se -r $destinatario -u $remitente "
	else
		encri="gpg -e -r $destinatario "
	fi
	comprimirArchivos
	encriptando
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
else
	if [ "$parametro" == "-ayuda" ]; then
		echo "-------------------------------------------------------------"
	else
		echo "ERROR NO SEA STUPIDO PLIS, teclee bien pos"
		echo "sino, pruebe -ayuda"
	fi
fi

#"Licencia: GNU GENERAL PUBLIC LICENSE Versión 3"
#"Creado por: Emilio Jesus Calderon"

