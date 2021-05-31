TP2: Procesos de usuario
========================

env_alloc
---------
1 - 0x1000, 0x1001, 0x1002, 0x1003, 0x1004

2 - 0x1276, 0x2276, 0x3276, 0x4276, 0x5276

env_init_percpu
---------------
Funcion lgdt(): carga una direccion lineal y un limite en modo protegido. Son ejecutadas en modo "real-address" para permitirle al procesador inicializar antes de switchear a modo protegido.
Carga los valores del operando fuente dentro del registro GDT (global descriptor table).
El operando fuente especifica un bloque de memoria de 6 bytes que contiene la direccion base (direccion linea) y el limite del GDTR (tamaño de la tabla en bytes).
Si el tamaño del operando es 32 bits, un limite de 16 bits (los 2 bytes menos significativos de los 6 bytes nombrados antes) y una direccion de 32 bits (los 4 bytes mas signifcativos de esos 6 bytes) son cargados en el gdt.
Si el tamaño es de 16 bits, un limite de 16 bits (los 2 bytes menos significatos) y una direccion base de 24 bits (3er,4to y 5to byte) son cargados. El 6to byte del operando no se usa y el byte mas significativo de la direccion base en el gdtr se carga con ceros.

env_pop_tf
----------

El tope de la pila justo antes de la instruccion `popal` va a ser la direccion correspondiente a al struct tf, mas precisamente al inicio de los registros de proposito general.
El tope de la pila justo antes de la instruccion `iret` va a ser la direccion correspondiente al registro %eip guardado.
El tercer elemento de la pila justo antes de la instruccion `iret` va a ser la direccion correspondiente al registro %eflags guardado.

El nivel de privilegio se encuentra almacenado en el registro %cs en sus 2 ultimos bits. La instruccion `iret` va a chequear que el usuario tenga privilegios antes de poder ejecutarse, mirando precisamente estos 2 bits del registro %cs.



gdb_hello
---------

1 - Cinco primeras líneas de info registers en el monitor de QEMU.

```
EAX=003bc000 EBX=00010094 ECX=f03bc000 EDX=0000020c
ESI=00010094 EDI=00000000 EBP=f0119fd8 ESP=f0119fbc
EIP=f0102ff0 EFL=00000092 [--S-A--] CPL=0 II=0 A20=1 SMM=0 HLT=0
ES =0010 00000000 ffffffff 00cf9300 DPL=0 DS   [-WA]
CS =0008 00000000 ffffffff 00cf9a00 DPL=0 CS32 [-R-]
```

3 - Valor de `tf`.
```
$1 = (struct Trapframe *) 0xf01c8000
```

4 - Enteros de trapframe (17)
```
0xf01c8000:	0x00000000	0x00000000	0x00000000	0x00000000
0xf01c8010:	0x00000000	0x00000000	0x00000000	0x00000000
0xf01c8020:	0x00000023	0x00000023	0x00000000	0x00000000
0xf01c8030:	0x00800020	0x0000001b	0x00000000	0xeebfe000
0xf01c8040:	0x00000023
```

7 - Valores y descripcion de lo apuntado por el registro $sp
```
0x00000000 -> uint32_t reg_edi 
0x00000000 -> uint32_t reg_esi  
0x00000000 -> uint32_t reg_ebp  
0x00000000 -> uint32_t reg_oesp 		/* Useless */
0x00000000 -> uint32_t reg_ebx 
0x00000000 -> uint32_t reg_edx  
0x00000000 -> uint32_t reg_ecx  
0x00000000 -> uint32_t reg_eax  
0x00000023 -> uint16 tf_es + padding 16bits. Se configura en la funcion `env_alloc`
0x00000023 -> uint16_t tf_ds + padding 16bits. Se configura en la funcion `env_alloc`
0x00000000 -> uint32_t tf_trapno
0x00000000 -> uint32_t tf_err
0x00800020 -> uintptr_t tf_eip . Se configura en la funcion `load_icode`
0x0000001b -> uint16_t tf_cs  + padding 16bits. Se configura en la funcion `env_alloc`
0x00000000 -> uint32_t tf_eflags 
0xeebfe000 -> uintptr_t tf_esp . Se configura en la funcion `load_icode`
0x00000000 -> uint16_t tf_ss  
```

8 - Cinco primeras líneas de info registers en el monitor de QEMU antes de `iret`. Aqui lo que se puede ver es 
como los valores que estaban en el stack fueron siendo cargados en sus correspondientes registros.
```
EAX=00000000 EBX=00000000 ECX=00000000 EDX=00000000
ESI=00000000 EDI=00000000 EBP=00000000 ESP=f01c8030
EIP=f0103003 EFL=00000096 [--S-AP-] CPL=0 II=0 A20=1 SMM=0 HLT=0
ES =0023 00000000 ffffffff 00cff300 DPL=3 DS   [-WA]
CS =0008 00000000 ffffffff 00cf9a00 DPL=0 CS32 [-R-]
```

Valor del contador de programa con p $pc o p $eip luego de `iret`.
```
$2 = (void (*)()) 0x800020
```

Valor del contador de programa con p $pc o p $eip luego de `iret`, con simbolos cargados.
```
$3 = (void (*)()) 0x800020 <_start>
```

La última vez la salida de info registers en QEMU. Se puede ver que el valor de los registros paso a ser
la configuracion que teniamos en el stack y aparte se le suma el cambio en los registros $eip apuntando al `_start` de del programa `hello` y el cambio en el registro $cs con el cambio de permisos. 
```
EAX=00000000 EBX=00000000 ECX=00000000 EDX=00000000
ESI=00000000 EDI=00000000 EBP=00000000 ESP=eebfe000
EIP=00800020 EFL=00000002 [-------] CPL=3 II=0 A20=1 SMM=0 HLT=0
ES =0023 00000000 ffffffff 00cff300 DPL=3 DS   [-WA]
CS =001b 00000000 ffffffff 00cffa00 DPL=3 CS32 [-R-]
```

Se puede ver que luego de la instruccion , el valor de $EIP=0000e05b lo cual implica que
ya no estamos en el programa `hello`. La instruccion `int` genera una interrupcion, lo cual implica
que el procesador vuele a modo kernel. El continuar la ejecucion provoca que el programa se reinicie, posiblemente
porque todavia no esta configurado el mecanismo para manejar dichas interrupciones.


PARTE 3
-------

-¿Cómo decidir si usar TRAPHANDLER o TRAPHANDLER_NOEC? ¿Qué pasaría si se usara solamente la primera?
-----------------------------------------------------------------------------------------------------
TRAPHANDLER se usa para las traps en las que el cpu pushea un codigo de error al stack.
TRAPHANDLER_NOEC se usa para las traps en las que el cpu NO pushea un codigo de error al stack, pero si pushea un 0, para que el trapframe tenga el mismo formato en cualquier caso.
Para ver cual trap si produce codigo de error, debemos mirar Tabla 6-1 en [IA32-3A]: Protected-Mode Exceptions and Interrupts, columna Error Code.


-¿Qué cambia, en la invocación de handlers, el segundo parámetro (istrap) de la macro SETGATE? ¿Por qué se elegiría un comportamiento u otro durante un syscall?
-----------------------------------------------------
El parametro 'istrap' es un booleano que indica si esa gate es una trap o no. Tambien, nos indica si cuando ella se ejecute, se van a poder manejar otras interrupciones o no, y si va a permitir el encadenamiento de varias interrupciones o si va a poder ser ejecutada ella sola.

-Leer user/softint.c y ejecutarlo con make run-softint-nox. ¿Qué interrupción trata de generar? ¿Qué interrupción se genera? Si son diferentes a la que invoca el programa… ¿cuál es el mecanismo por el que ocurrió esto, y por qué motivos? ¿Qué modificarían en JOS para cambiar este comportamiento?
-------------------------------------------------------------------------------------------
Viendo el codigo de umain, vemos que se quiere generar una page fault (0x0000000e)
Viendo la ejecucion de make run-softint-nox vemos que se genera:
trap 0x0000000d, que hace referencia a General Protection Fault.

PARTE 5
-------
-¿En qué se diferencia el código de la versión en evilhello.c mostrada arriba?
------------------------------------------------------------------------------
El codigo en evilhello.c imprime con sys_cputs los primeros 100 caracteres de la direccion
0xf010000c
El codigo mostrado en la consigna muestra 1 caracter de la direccion de memoria 0xf010000c pero utilizando un puntero
de intermediario.

El codigo de la consigna produce el mismo resultado que el codigo original de evilhello.c
el codigo original le pasa a sys_cputs una direccion de memoria invalida: 0xf010000c es una posicion del kernel a la que cualquier proceso de user no tiene acceso. El codigo de la consigna usa una direccion valida, ya que la variable first se encuentra declarada en el stack de este proceso.

-¿En qué cambia el comportamiento durante la ejecución?¿Por qué? ¿Cuál es el mecanismo?
---------------------------------------------------------------------------------------
El codigo de evilhello.c intentara acceder a la memoria del kernel durante un syscall, pero el sistema se encuentra en modo kernel, por lo que si no se protege el kernel tendra acceso a esa posicion.
El codigo de la consigna intenta leer el contendio de la posicicion del kernel desreferenciando el puntero, por lo que se realiza en user mode, y se generaria una T_PGFLT.

- Listar las direcciones de memoria que se acceden en ambos casos, y en qué ring se realizan. ¿Es esto un problema? ¿Por qué?
    En el caso original, las posiciones de memoria son accedidas directamente en el ring 1. Se esta usando al kernel
    como intermediario para acceder a direcciones protegidas. 0xf010000c corresponde al entrypoint del kernel, espacio que no deberia de estar disponible para el usuario. Direcciones accedidas [0xf010000c, 0xf010019c).
    En el segundo caso se utiliza un puntero intermediario donde se guarda la direccion que se quiere acceder, se desreferencia y luego se referencia nuevamente. En este caso la misma direccion de memoria se trata de acceder
    desde el ring 3, aqui al no tener permisos de acceso el hardware lanza un page fault.

