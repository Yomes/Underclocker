#!/bin/bash
# -*- ENCODING: UTF-8 -*-

version=13

# Default variables. You can change it to run the script easily.
delay=0
seconds=0
t_limit=85
t_normal=75
logfile="/dev/null" # <- File used as log.
rows=250
notif="yes"
gui=true
governor=ondemand

# Test if the default governor is available
cur_gov=$(cpupower frequency-info | grep -v cpufreq | grep "The governor" | cut -d \" -f 2)
gov_num=0
governors_read=$(cpupower frequency-info | grep governors | cut -d : -f 2 | cut -c 2-)
# Make an array with the list of available governors
while read -d" " line ; do
	gov_avail+=($line)
	((gov_num++))
done <<< $(echo "$governors_read ")
	((gov_num--))
# Test each available governors to find a coincidence with de default
for gov_selected in "${!gov_avail[@]}"; do
	[[ "${gov_avail[$gov_selected]}" = "$governor" ]] && gov_exist=1 && break
done
# If the default governor is not available, it takes the current governor as default
if [[ -z $gov_exist ]]; then
	gov_selected=0
	for gov_selected in "${!gov_avail[@]}"; do
		[[ "${gov_avail[$gov_selected]}" = "$cur_gov" ]] && break
	done
	governor="${gov_avail[$gov_selected]}"
fi


# Languages
# locale | grep '^LANGUAGE=' | cut -d= -f2 | cut -d_ -f1
lang=$(locale | grep LANGUAGE= | cut -d= -f2 | cut -d_ -f1)
case $lang in

# SPANISH
	es)
	text_exiting="Saliendo..."
	txt_exit_permissions="Error. Compruebe permisos de escritura en /usr/bin. Saliendo..."
	txt_exit_term="Script terminado. Saliendo..."
	txt_tem_max="Temperatura máxima alcanzada: "
	tex_q_gui="¿Configuración gráfica?"
	tex_q_install="No se encontró el script /usr/bin/setfreq.sh Requiere permisos de administrador. ¿Instalar?"
	tex_install="Instalar"
	tex_ok="Vale"
	tex_yes="Sí"
	tex_cancel="Cancelar"
	tex_no="No"
	tex_select="Seleccionar"
	tex_create="Crear"
	tex_none="Ninguno"
	tex_t_delay="Retraso (s)"
	tex_delay="Tiempo antes de ejecutar el script: "
	tex_t_time="Tiempo (s)"
	tex_time="Tiempo ejecutando el script: "
	tex_t_maxt="Temperatura máxima (ºC)"
	tex_temp="Temperatura a la que reducir la frecuencia: "
	tex_t_nort="Temperatura normal (ºC): "
	tex_nort="Temperatura a la que subir la frecuencia: "
	tex_t_notif="Notificaciones"
	tex_notif="¿Desea notificationes de escritorio?"
	tex_t_logfile="Archivo log"
	tex_logfile="¿Seleccionar un archivo o crear uno nuevo?"
	tex_logfile_location="Ubicación del nuevo archivo: "
	tex_logfile_route="Escriba la ruta: "
	tex_t_logfile_size="Tamaño (líneas)"
	tex_logfile_size="Tamaño máximo, en líneas del archivo log: "
	tex_newsession="Nueva sesión"
	tex_max="Max: "
	tex_now="Ahora: "
	tex_decrease="Acción: Bajando "
	tex_decreasing="Bajando frecuencia máxima: "
	tex_increase="Acción: Subiendo "
	tex_increasing="Subiendo frecuencia máxima: "
	tex_gov_avail="Governors disponilbes:"
	tex_q_gov="Elija el governor deseado:"
	tex_cur_gov="El governor actual es"
	tex_new_gov="Escriba el nombre del nuevo governor"

	# Ayuda:
	tex_help="
		Este script monitoriza la temperatura de la CPU, reduce la frecuencia máxima cuando es muy alta y la aumenta cuando es suficientemente baja, y puede crear un log con sus acciones, temperaturas, fecuencias y fecha y hora. de cada evento.

		Lista de parámetros válidos:
		\n	-d <segundos> \t Retraso antes de ejecutar el script.
		\n	-t <segundos> \t Tiempo en segundos de ejecución del script. Si es 0, el script no parará.
		\n	-p <governor> \t Power governor (usar [-p list] para seleccionarlo de una lista)
		\n	-l <ºC> \t Temperatura máxima deseada.
		\n	-r <ºC> \t Temperatura mínima para aumentar la frecuencia.
		\n	-f <file> \t Archivo a usar como log.
		\n	-s <size> \t Tamaño máximo, en filas, del archivo de log.
		\n	-n <yes | no> \t Activar o desactivar notificaciones de escritorio.
		\n	-g \t Deshabilita la configuración gráfica.
		\n\n	Ejemplo: Limita la frecuencia cuando la temperatura llega a 85ºC, la restaura cuando la temperatura es menor de 75ºC y muestra notificaciones de escritorio:
		\n\n	./temperature.sh -l 85 -r 75 -n yes
		\n\n	Ejemplo: Limita la frecuencia cuando la temperatura llega a 70ºC, la restaura cuando la temperatura es menor de 50ºC, espera 30 segundos antes de ejecutar el script, se ejecuta durante 5 minutos (300 segundos), desactiva la confguración gráfica y guarda el log en <HOME>/temper.txt:
		\n\n	./tepmerature.sh -l 70 -r 50 -d 30 -t 300 -g -f ~/temper.txt
	"
	
	;;

# ENGLISH
	*)
	text_exiting="Exiting..."
	txt_exit_permissions="Error. Please, test permissions to write in /usr/bin. Exiting..."
	txt_exit_term="Script terminated. Exiting"
	txt_tem_max="Maximum temperature reached: "
	tex_q_gui="Graphical configuration?"
	tex_q_install="Script /usr/bin/setfreq.sh not found. It requires administrator permissions. ¿Install?"
	tex_install="Install"
	tex_ok="O.K."
	tex_yes="Yes"
	tex_cancel="Cancel"
	tex_no="No"
	tex_select="Select"
	tex_create="Create"
	tex_none="None"
	tex_t_delay="Delay (s)"
	tex_delay="Time waiting for start the srcipt: "
	tex_t_time="Time (s)"
	tex_time="Time running the srcipt: "
	tex_t_maxt="Max temperature (ºC)"
	tex_temp="Temperature to start reducing frequency: "
	tex_t_nort="Normal temperature (ºC): "
	tex_nort="Temperature to start increasing frequency: "
	tex_t_notif="Notifications"
	tex_notif="Do tou want desktop notifications?"
	tex_t_logfile="Log file"
	tex_logfile="Select a file or create a new one?"
	tex_logfile_location="Location of new file: "
	tex_logfile_route="Write the route: "
	tex_t_logfile_size="Size (rows)"
	tex_logfile_size="Maximum size, in rows, for the log file: "
	tex_newsession="New session"
	tex_max="Max: "
	tex_now="Now: "
	tex_decrease="Action: Decrease"
	tex_decreasing="Decreassing maximun frequency: "
	tex_increase="Action: Increase"
	tex_increasing="Increassing maximun frequency: "
	tex_gov_avail="Available governors:"
	tex_q_gov="Chose the dessired governor:"
	tex_cur_gov="Current governor is"
	tex_new_gov="Write the name for the new governor"

	# Help:
	tex_help="
		This script monitorize the temperature of the CPU, decreases the maximum frequency when temp is too high, and increase than when temp is low enough, and can create a log with its actions, temperatures, frequencies and date and time for each event.

		List of valid parameters:
		\n	-d <seconds> \t Delay before executing the sript.
		\n	-t <seconds> \t Time in seconds running the script. If 0, the script will never stop.
		\n	-p <governor> \t Power governor (use [-p list] to select from a list)
		\n	-l <ºC> \t Maximum dessired temperature.
		\n	-r <ºC> \t Minimum temperature to increase frequency.
		\n	-f <file> \t File used as log.
		\n	-s <size> \t Maximum size, in rows, for the log file.
		\n	-n <yes | no> \t Enable or disable desktop notifiacions.
		\n	-g \t Disable GUI dialogs.
		\n\n	Example: Limit frequency when the temperature is 85ºC, restore it when temperature is below 75ºC and show desktop notifications:
		\n\n	./temperature.sh -l 85 -r 75 -n yes
		\n\n	Example: Limit frequency when the temperature is 70ºC, restore it when temperature is below 50ºC, wait 30 seconds, run the script for 5 minutes (300 seconds), disable GUI dialogs and log the changes in <HOME>/temper.txt:
		\n\n	./tepmerature.sh -l 70 -r 50 -d 30 -t 300 -g -f ~/temper.txt
	"
	
	;;
esac

# Testing for needed tools:
sensors 2> /dev/stdout > /dev/null
if [ $? == 1 ]; then
	echo $text_exiting
	exit
fi

nvidia-smi > /dev/null 2> /dev/null
if [ $? == 0 ]; then
	nv=1
else
	nv=0
	t_gpu="NA"
fi


# Special argument: if /usr/bin/setfreq.sh is not present, it creates them and stablishes permissions:
if [ "$1" == "install" ]; then
	echo -e '#!/bin/bash\n# -*- ENCODING: UTF-8 -*-\n\n# Underclocker version '$version';\n# This script MUST be launched by root\n\n# Setting the governor:\nif [ "$1" == "governor" ]; then\n	a=$(cpupower frequency-set -g "$2")\n	[[ $? != 0 ]] && echo -e "Cpupower failed. Error: $a" && exit 1\n	[[ ! "$(cpupower frequency-info | grep -v cpufreq | grep $2 | cut -d\" -f2)" == "$2" ]] && echo "Governor change not setted. This script needs that governor to run." && exit 1\n	exit 0\nfi\n\n# Changing the max speed:\ncpupower -c $1 frequency-set -u $2 > /dev/null\nexit 0' > /usr/bin/setfreq.sh
	if [ $? == 1 ]; then
		echo "$txt_exit_permissions"
		exit
	fi
	chown root:root /usr/bin/setfreq.sh
	chmod 755 /usr/bin/setfreq.sh
	# This test if sudoers is configured, and configure it if not:
	if [ $(grep -c 'ALL ALL=(ALL) NOPASSWD: /usr/bin/setfreq.sh' /etc/sudoers) -eq 0 ]; then
		echo -e '\n# Users can execute this with sudo without password:\nALL ALL=(ALL) NOPASSWD: /usr/bin/setfreq.sh' >> /etc/sudoers
	fi
	exit
fi

########### Functions ###########

# Size limit for logfile:
cutlog () {
	if [ $(wc -l < "$logfile") -gt $rows ]; then
		templog=$(tail -n $rows "$logfile")
		cat <<<"$templog" > "$logfile"
	fi
}

# Exit function. Reset the max frequency.
saliendo () {
	echo
	echo "$txt_exit_term"
	echo "$txt_tem_max$t_max_total" | tee -a "$logfile"
	cpunum=0
	for cpunum in $(seq 0 $cpus); do
		sudo /usr/bin/setfreq.sh $cpunum ${f_max[$cpunum]}
		[[ $? == 1 ]] && echo "Error on /usr/bin/setfreq.sh." && exit 1
	done
	exit
}

# Read maximum frequencies
read_f_max () {
	cpunum=0
	f_max=()
	while read line ; do
		f_max+=($line)
		f_newlimit[$cpunum]=${f_max[$cpunum]}
		((cpunum ++))
	done <<< $(cpupower -c all frequency-info -l | grep -v "analyzing" | cut -d\  -f 2)
}

# Read minimum frequencies
read_f_min () {
	cpunum=0
	f_min=()
	while read line ; do
		f_min+=($line)
		((cpunum ++))
	done <<< $(cpupower -c all frequency-info -l | grep -v "analyzing" | cut -d\  -f 1)
}

# Read current frequencies
read_f_cur () {
	f_cur=()
	while read line ; do
		f_cur+=($line)
	done <<< $(cpupower -c all frequency-info -f | grep -v "analyzing" | cut -d\  -f 6)
}


# Internal variables. Please, do not change.
t_cur=0
t_max_total=0

# Variables assigned by arguments:
if [[ $1 ]]; then
	if [ $1 == "-h" ] || [ $1 == "--help" ]; then
		echo -e "$tex_help"
		exit
	fi

  # Reading arguments. Add "####" for priority over GUI diaglogs; it will be removed after that.
	while getopts d:t:p:l:r:f:s:n:g flag
	do
		case "${flag}" in
			d) delay=${OPTARG}"####";;
			t) seconds=${OPTARG}"####";;
			p) governor_arg=${OPTARG}"####";;
			l) t_limit=${OPTARG}"####";;
			r) t_normal=${OPTARG}"####";;
			f) logfile=${OPTARG}"####";;
			s) rows=${OPTARG}"####";;
			n) notif=${OPTARG}"####";;
			g) gui=false;;
			*) echo -e "$tex_help"
			exit;;
		esac
	done
fi

# Select governor from a list: 
if [[ $governor_arg == "list####" ]]; then
	# Show a list of available governors
	for line in $(seq 0 $gov_num); do
		echo $line ${gov_avail[$line]}
	done
	# Ask user for the dessired governor
	echo "$tex_cur_gov $cur_gov"
	read -r -p "$tex_q_gov (0/$gov_num) (default: $gov_selected)" a
	[[ $a ]] && gov_selected=$a
	echo "$tex_cur_gov $gov_selected ${gov_avail[$gov_selected]}"
	governor="${gov_avail[$gov_selected]}""####"
elif [[ -n "$governor_arg" ]]; then
	governor="$governor_arg"
fi
unset governor_arg

# Active or disable notifications.
# Maximum priority are:
# 1º Must exist a desktop.
# 2º Argument from console ( -g ).
# 3º Default variable at the beggining of the script ( notif= ).
# 4º If not disabled yet, show a dialog to acivate or not.

if [ -z "$DISPLAY" ]; then
 	# There are no desktop.
	notif="no"
	gui=false
elif [ $gui == true ]; then
	# There are desktop and default gui variable is true
	zenity --question --text "$tex_q_gui" --no-wrap --ok-label "$tex_ok" --cancel-label "No" 2>/dev/null
	if [ $? == 0 ]; then
		gui=true
	else
		gui=false
	fi
fi


# AUTOINSTALLATION
# Test if the correct version of the superuser part of this script is installed. If not, it launches the script on installation mode.
if [ -z "$(grep "# Underclocker version $version;" /usr/bin/setfreq.sh)" ]; then
	if [ -z "$DISPLAY" ] || [ $gui == false ]; then
 		# There are no desktop, or GUI disabled.
		read -r -p "$tex_q_install (y/n)" a
		if [ "$a" == "y" ]; then
			sudo "$0" install
		else
			echo "$text_exiting"
			exit
		fi
		unset a
	else
		# GUI enabled.
		zenity --question --text "$tex_q_install" --no-wrap --ok-label "$tex_install" --cancel-label "$tex_cancel" 2>/dev/null
		if [ $? == 0 ]; then
			pkexec $0 install
		else
			exit
		fi
	fi
fi

# GUI: Setting variables not stablished by parameters:
if [ $gui == true ]; then
	if [[ $delay != *"####"* ]]; then
		delay=$(zenity --entry --title "$tex_t_delay" --text "$tex_delay" --entry-text="$delay") 2>/dev/null
	fi

	if [[ $seconds != *"####"* ]]; then
		seconds=$(zenity --entry --title "$tex_t_time" --text "$tex_time" --entry-text="$seconds") 2>/dev/null
	fi

	# Select governor from a list: 
	if [[ $governor != *"####"* ]]; then
		gov_avail+=("Write new governor")
		# Ask user for the dessired governor
		gov_selected=$(zenity --list --title "Governors" --text "$tex_cur_gov $cur_gov\nDefault: $governor\n$tex_q_gov" --column=Menu "${gov_avail[@]}" --height 370)
		if [[ "$gov_selected" == "Write new governor" ]]; then
			governor=$(zenity --entry --title "Governor" --text "$tex_new_gov" --entry-text="new") 2>/dev/null
		elif  [[ -n "$gov_selected" ]]; then
			governor="$gov_selected"
		fi
		unset gov_selected
	fi

	if [[ $t_limit != *"####"* ]]; then
		t_limit=$(zenity --entry --title "$tex_t_maxt" --text "$tex_temp" --entry-text="$t_limit") 2>/dev/null
	fi

	if [[ $t_normal != *"####"* ]]; then
		t_normal=$(zenity --entry --title "$tex_t_nort" --text "$tex_nort" --entry-text="$t_normal") 2>/dev/null
	fi
	
	if [[ $notif != *"####"* ]]; then
		zenity --question --title "$tex_t_notif" --text "$tex_notif" --no-wrap --ok-label "$tex_yes" --cancel-label "$tex_no" 2>/dev/null
		if [ $? == 0 ]; then
			notif="yes"
		else
			notif="no"
		fi
	fi

	if [[ "$logfile" != *"####"* ]]; then
		wlf=$(zenity --question --title "$tex_t_logfile" --text "$tex_logfile" --switch --extra-button "$tex_select" --extra-button "$tex_create" --extra-button "$tex_none") 2>/dev/null
		if [ "$wlf" = "$tex_select" ]; then
			logfile_gui=$(zenity --file-selection --text "$tex_logfile_location" --filename "${HOME}/") 2>/dev/null
			if [ $? == 0 ]; then
				logfile="$logfile_gui"
			fi
		elif [ "$wlf" = "$tex_create" ]; then
			logfile_gui=$(zenity --entry --title "$tex_t_logfile" --text "$tex_logfile_route" --entry-text="${HOME}/temp_log.txt") 2>/dev/null
			if [ $? == 0 ]; then
				logfile="$logfile_gui"
			fi
		else
			logfile=/dev/null
		fi
		unset wlf
	fi
	
	logfile=${logfile%"####"}
	if [[ $rows != *"####"* ]] && [[ "$logfile" != "/dev/null" ]]; then
		rows=$(zenity --entry --title "$tex_t_logfile_size" --text "$tex_logfile_size" --entry-text="$rows") 2>/dev/null
	fi

fi

# Cleaning variables:
		notif=${notif%"####"}
		delay=${delay%"####"}
		seconds=${seconds%"####"}
		governor=${governor%"####"}
		t_limit=${t_limit%"####"}
		t_normal=${t_normal%"####"}
		logfile=${logfile%"####"}
		rows=${rows%"####"}

# Change "~" to "${HOME}" to use the "/home/user" folder in redirections:
logfile=${logfile//\~/"${HOME}"}

# For unlimited execution:
if [ $seconds == 0 ]; then
	infinite=1
	seconds=1000
else
	infinite=0	
fi

echo -e "\n$(date)\n___________________ $tex_newsession ___________________" | tee -a "$logfile"
lines=0

cutlog


sleep $delay

# Setting the governor:
sudo /usr/bin/setfreq.sh governor $governor
[[ $? == 1 ]] && echo "Error on /usr/bin/setfreq.sh." && exit 1

# Obtain current, max and min frequency:
read_f_max
read_f_min
read_f_cur

# Conunting cores:
cpus=$(cpupower -c all frequency-info -f | grep -c "analyzing")
((cpus --))

# Setting the current temperature to maximum:
for cpunum in $(seq 0 $cpus); do
	sudo /usr/bin/setfreq.sh $cpunum ${f_max[$cpunum]}
	[[ $? == 1 ]] && echo "Error on /usr/bin/setfreq.sh." && exit 1
done


trap saliendo 0

# ----------------------- Principal loop -----------------------

until [ $seconds -lt 1 ]; do

	# Read the highest temperature from all sensors:
	t_cur=$(sensors | grep °C | awk -F '+' '{print $2}' | awk -F '°C' '{print $1}' | awk -F '.' '{print $1}' | sort -nr | head -n1)
	# Update maximum teperature for this session
	if [ $t_cur -gt $t_max_total ]; then
		t_max_total=$t_cur
	fi
	
	# Decrease frequency when temperature is too high
	cpunum=0
	lim_reached=true
	for cpunum in $(seq 0 $cpus); do
		if [[ ${f_newlimit[$cpunum]} -gt ${f_min[$cpunum]} ]]; then
			lim_reached=false
			break
		fi
	done

	if [ $t_cur -gt $t_limit ] && [[ $lim_reached == false ]]; then
		# Decease frequency in proportion to excesive temperature
		diff=$((t_cur - t_limit))
		step=$((diff * 50000))
		step=$(( step > 400000 ? 400000 : step ))
		echo -e "$(date '+%y/%m/%d %H:%M:%S')\t$tex_decrease\t$tex_now$t_cur ºC\t$tex_max$t_max_total ºC\tGPU: $t_gpu ºC" | tee -a "$logfile"
		log_freq1=""
		log_freq2=""
		cpunum=0
		for cpunum in $(seq 0 $cpus); do
			if [ ${f_newlimit[$cpunum]} -gt ${f_min[$cpunum]} ]; then
			
				f_newlimit[$cpunum]=$((f_newlimit[$cpunum] - step))
				if [ ${f_newlimit[$cpunum]} -lt ${f_min[$cpunum]} ]; then
					f_newlimit[$cpunum]=${f_min[$cpunum]}
				fi
				sudo /usr/bin/setfreq.sh $cpunum ${f_newlimit[$cpunum]}
				[[ $? == 1 ]] && echo "Error on /usr/bin/setfreq.sh." && exit 1
			fi
			read_f_cur
			f_newlimit_cpunum=${f_newlimit[$cpunum]}
			f_cur_cpunum=${f_cur[$cpunum]}
			f_new_str[$cpunum]=$((f_newlimit_cpunum/1000))
			f_cur_str[$cpunum]=$((f_cur_cpunum/1000))
			[ $nv == 1 ] && t_gpu=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)
			log_freq1="$log_freq1 C$cpunum ${f_new_str[$cpunum]} "
			log_freq2="$log_freq2 C$cpunum ${f_cur_str[$cpunum]} "
			((cpunum ++))		
		done
		echo -e "$tex_max (Mhz)\t$log_freq1" | tee -a "$logfile"
		echo -e "$tex_now (Mhz)\t$log_freq2" | tee -a "$logfile"
		unset log_freq1 log_freq2
		cutlog
		((lines++))
		[ $notif == "yes" ] && notify-send "$tex_decreasing ${f_newlimit[0]}" 2>/dev/null
		sleep 4
		((seconds-=4))
	fi
	
	# Icrease frequency when temperature is acceptable
	cpunum=0
	lim_reached=true
	for cpunum in $(seq 0 $cpus); do
		if [[ ${f_newlimit[$cpunum]} -lt ${f_max[$cpunum]} ]]; then
			lim_reached=false
			break
		fi
	done
		
	if [ $t_cur -lt $t_normal ] && [[ $lim_reached == false ]]; then
		echo -e "$(date '+%y/%m/%d %H:%M:%S')\t$tex_increase\t$tex_now$t_cur ºC\t$tex_max$t_max_total ºC\tGPU: $t_gpu ºC" | tee -a "$logfile"
		cpunum=0
		for cpunum in $(seq 0 $cpus); do
			if [ ${f_newlimit[$cpunum]} -ge ${f_min[$cpunum]} ]; then
				f_newlimit[$cpunum]=$((${f_newlimit[$cpunum]} + 200000))
				if [ ${f_newlimit[$cpunum]} -gt ${f_max[$cpunum]} ]; then
					f_newlimit[$cpunum]=${f_max[$cpunum]}
				fi
				sudo /usr/bin/setfreq.sh $cpunum ${f_newlimit[$cpunum]}
				[[ $? == 1 ]] && echo "Error on /usr/bin/setfreq.sh." && exit 1
			fi
			read_f_cur
			f_newlimit_cpunum=${f_newlimit[$cpunum]}
			f_cur_cpunum=${f_cur[$cpunum]}
			f_new_str[$cpunum]=$((f_newlimit_cpunum/1000))
			f_cur_str[$cpunum]=$((f_cur_cpunum/1000))
			[ $nv == 1 ] && t_gpu=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)
			log_freq1="$log_freq1 C$cpunum ${f_new_str[$cpunum]} "
			log_freq2="$log_freq2 C$cpunum ${f_cur_str[$cpunum]} "
			((cpunum ++))		
		done
		echo -e "$tex_max (Mhz)\t$log_freq1" | tee -a "$logfile"
		echo -e "$tex_now (Mhz)\t$log_freq2" | tee -a "$logfile"
		unset log_freq1 log_freq2
		cutlog
		((lines++))
		[ $notif == "yes" ] && notify-send "$tex_increasing${f_newlimit[0]}" 2>/dev/null
		sleep 4
		((seconds-=4))
	fi

	sleep 1
	((seconds--))
	if [[ $infinite -eq 1 ]]; then
		seconds=1000
	fi
	
done

# Exiting
echo "$txt_exit_term"
echo "$txt_tem_max$t_max_total" | tee -a "$logfile"
saliendo
