# Underclocker  
Script to reduce CPU frequencies when temperature is too high  
  
En mi equipo tengo un problema: se calienta mucho. Ya hago todo lo normal: limpieza, cambio de pasta térmica (una de calidad), alterar la velocidad del ventilador… Pero nada: cuando hago algo que requiere potencia, se pone a 90~98ºC. Está diseñado así: este procesador tiene una temperatura de trabajo “normal” de 95ºC y una crítica de 105ºC, el “throttling” lo estableció el fabricante en la BIOS y no se puede modificar. Pero no me gusta: puede dañar otros componentes.  
Así que… me puse manos a la obra.  
  
¡OJO! ¡PRECAUCIÓN ¡CUIDADÍN!  
Es un trabajo en curso, no está terminado, lo he probado en muy poco equipos y no me hago responsable de los daños que pudiera ocasionar. Recomiendo ejecutarlo en equipos de pruebas, siempre bajo supervisión.  
Nota: Que yo sepa, no se puede usar en máquinas virtuales: no tienen sensores.  
  
He escrito un script que mide cada segundo la temperatura de todos los núcleos:  
* Si pasa de un valor, baja la frecuencia máxima del núcleo una cantidad de Mhz proporcional entre la temperatura actual y la deseada (para reaccionar rápido ante picos de calor).  
* Si queda por debajo de otro valor, sube un poco la frecuencia.  
En cada cambio de frecuencia espera 5 segundos para que el disipador reaccione y vuelve a repetir el ciclo. Así, la temperatura se acaba estabilizando al valor deseado en cuestión de segundos (10, 30… depende de la cantidad de “saltos” que deba hacer), y se va adaptando a las necesidades del momento.  
  
El script puede generar un log con los cambios de frecuencia y temperatura en un archivo y/o mostrar notificaciones en el escritorio, además de por la salida estándar (terminal, si se ejecuta desde uno). El usuario puede establecer la ruta y la longitud máxima del log.  
Además, se puede dejar funcionando indefinidamente (ideal para tenerlo como autoejecutable) o establecer un período de tiempo (para tests de estrés y rendimiento), además de establecer un retraso en la ejecución.  
El script tiene un rudimentario soporte de idiomas. Lee la salida de _locale_ y utiliza una lista de frases en el idioma coincidente. Por defecto, en inglés. **Puede colaborar añadiendo idiomas**  
Lee temperatura de gráficas nVidia (probado sólo con una GTX 950M, con drivers propietarios). Comprueba si nvidia-smi existe y se ejecuta sin errores; de lo contrario, no intentará leer temperaturas de GPU. **Soporte parcial:** sólo lee la temperatura para añadirla al log; no puede modificar frecuencias, no se ha probado con drivers libres, ni con gráficas muy modernas ni muy antiguas.  
Al terminar la ejecución (señal SIGINT, por ejemplo con Ctrl+C) muestra un mensaje con la máxima temperatura alcanzada y restaura la frecuencia máxima por defecto.  
  
Se pueden establecer las variables dentro del script, pasárselas como argumentos o introducirlas por diálogos gráficos. Incluye un argumento -h para recibir ayuda básica.  
La prioridad la tienen los argumentos pasados por consola; si se ha pasado alguno, el modo gráfico no preguntará por él. En los diálogos, el valor por defecto será el que esté establecido en las variables del script.  
La congifuración por cuadros de diálogo se puede desactivar desde la variable $gui en el script.  
Además, si no se detecta la variable $DISPLAY, se asume que está sin modo gráfico o no interactivo, por lo que ni muestra notificaciones ni utiliza diálogos.La idea es adaptarse lo mejor posible a estas situaciones:  
* Usuario ejecuta el script directamente, sin parámetros y sin tocar las variables: El script le pregunta si quiere establecerlas de forma gráfica. Si quiere, se pregunta todo, tomando por defecto los valores escritos en el script. Si no quiere, toma dichos valores como válidos.  
* Usuario ejecuta el script desde una consola no interactiva (P.E.: Una distro sin escritorio, sólo terminal): No hay notificaciones ni cuadros de diálogo. Puede usar parámetros; de lo contrario, se toman los valores por defecto.  
* Se configura el script para autoarranque: o bien se establecen todos los valores por parámetros o se anula el GUI (editando la variable $gui = false o mediante el parámetro -g). En este último caso, el script dará prioridad a los parámetros y tomará el resto de valores por defecto.
  
**Dos scripts en uno**  
Leer las temperaturas es fácil, pero establecer el valor de frecuencia sólo se puede hacer como superusuario. Por este motivo, he dividido el script en dos: underclocker.sh tiene permisos de usuario normal, y cuando hay que hacer un cambio llama al script /usr/bin/setfreq.sh con sudo.  
  
Underclocker detecta si existe setfreq.sh. Si no existe, inicia una instalación del mismo:
1. El script cpufreq.sh, el que requiere permisos, se crea en /usr/bin/setfreq.sh, con propietario root:root y permisos 755. Todo su contenido ya está incluído en el cuerpo de Underclocker, así que no es necesario descargarlo aparte.  
2. Para evitar que pida contraseña cada vez (sobre todo, para pder usarlo en una shell no interactiva), es necesario añadir permisos de sudo sin contraseña para el segundo script. Durante la instalación se añade la línea [ALL ALL=(ALL) NOPASSWD: /usr/bin/setfreq.sh] al final de /etc/sudoers. Para evitar duplicidades, antes se comprueba que dicha línea no exista ya.  
  
Setfreq.sh tiene dos funciones:
1. Cambiar la frecuencia de los núcleos. Para ello, Underclocker le envía como primer parámetro el número del núcleo a cambiar y como segundo parámetro la frecuencia deseada.  
2. Cambiar el "governor", esto es, el modo de consumo energético del procesador. Underclocker enviará como primer parámetro la cadena "governor" y como segundo parámetro el nombre del governor deseado.  

**Ayuda**
Este script monitoriza la temperatura de la CPU, reduce la frecuencia máxima cuando es muy alta y la aumenta cuando es suficientemente baja, y puede crear un log con sus acciones, temperaturas, fecuencias y fecha y hora. de cada evento.  
  
Lista de parámetros válidos:  
  -d <segundos> 	 Retraso antes de ejecutar el script.  
  -t <segundos> 	 Tiempo en segundos de ejecución del script. Si es 0, el script no parará.  
  -p <governor> 	 Power governor (usar [-p list] para seleccionarlo de una lista)  
  -l <ºC> 	 Temperatura máxima deseada.  
  -r <ºC> 	 Temperatura mínima para aumentar la frecuencia.  
  -f <file> 	 Archivo a usar como log.  
  -s <size> 	 Tamaño máximo, en filas, del archivo de log.  
  -n <yes | no> 	 Activar o desactivar notificaciones de escritorio.  
  -g 	 Deshabilita la configuración gráfica.  
  
Ejemplo: Limita la frecuencia cuando la temperatura llega a 85ºC, la restaura cuando la temperatura es menor de 75ºC y muestra notificaciones de escritorio:  
  ./underclocker.sh -l 85 -r 75 -n yes  

Ejemplo: Limita la frecuencia cuando la temperatura llega a 70ºC, la restaura cuando la temperatura es menor de 50ºC, espera 30 segundos antes de ejecutar el script, se ejecuta durante 5 minutos (300 segundos), desactiva la confguración gráfica y guarda el log en <HOME>/temper.txt:  
  ./underclocker.sh -l 70 -r 50 -d 30 -t 300 -g -f ~/temper.txt
