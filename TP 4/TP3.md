Tarea: env_return


Al terminar un proceso su función umain() ¿dónde retoma la ejecución el kernel? Describir la secuencia de llamadas desde que termina umain() hasta que el kernel dispone del proceso.

`umain` es encapsulado por la libmain.c dentro de `libmain`. Cuando el codigo de `umain` finaliza su ejecuccion libmain llama a la funcion `exit` que a su vez llama
a la funcion `sys_env_destroy`, generando una syscall. Luego la syscall es manejada por trap y despachada a su correspondiente handler. Finalmente termina ejecutando la logica de `sys_env_destroy`.

¿En qué cambia la función env_destroy() en este TP, respecto al TP anterior?

En el trabajo anterior, env_destroy directamente destruia el proceso y liberaba la memoria. En este nuevo tp, hay que verificar en que CPU esta corriendo el proceso ya que si no esta en la cpu que handlea la syscall, hay que cambiarlo de estado a env_diying para que cuando se le vuelva a dar env_run, se sepa que este ya no esta en funcionamiento y se lo termine de liberar.

---------------------------------------------------------------------------------------

Tarea: sys_yield

Leer y estudiar el código del programa user/yield.c. Cambiar la función i386_init() para lanzar tres instancias de dicho programa, y mostrar y explicar la salida de make qemu-nox.

Salida:


    $ make qemu-nox
    + cc kern/init.c
    + ld obj/kern/kernel
    + mk obj/kern/kernel.img

    *** Use Ctrl-a x to exit qemu

    qemu-system-i386 -nographic -drive file=obj/kern/kernel.img,index=0,media=disk,format=raw -serial mon:stdio -gdb tcp:127.0.0.1:26000 -D qemu.log -smp 1  -d guest_errors
    6828 decimal is 15254 octal!
    Physical memory: 131072K available, base = 640K, extended = 130432K
    check_page_free_list() succeeded!
    check_page_alloc() succeeded!
    check_page() succeeded!
    check_kern_pgdir() succeeded!
    check_page_free_list() succeeded!
    check_page_installed_pgdir() succeeded!
    SMP: CPU 0 found 1 CPU(s)
    enabled interrupts: 1 2
    [00000000] new env 00001000
    [00000000] new env 00001001
    [00000000] new env 00001002
    Hello, I am environment 00001000.
    Hello, I am environment 00001001.
    Hello, I am environment 00001002.
    Back in environment 00001000, iteration 0.
    Back in environment 00001001, iteration 0.
    Back in environment 00001002, iteration 0.
    Back in environment 00001000, iteration 1.
    Back in environment 00001001, iteration 1.
    Back in environment 00001002, iteration 1.
    Back in environment 00001000, iteration 2.
    Back in environment 00001001, iteration 2.
    Back in environment 00001002, iteration 2.
    Back in environment 00001000, iteration 3.
    Back in environment 00001001, iteration 3.
    Back in environment 00001002, iteration 3.
    Back in environment 00001000, iteration 4.
    All done in environment 00001000.
    [00001000] exiting gracefully
    [00001000] free env 00001000
    Back in environment 00001001, iteration 4.
    All done in environment 00001001.
    [00001001] exiting gracefully
    [00001001] free env 00001001
    Back in environment 00001002, iteration 4.
    All done in environment 00001002.
    [00001002] exiting gracefully
    [00001002] free env 00001002
    No runnable environments in the system!
    Welcome to the JOS kernel monitor!
    Type 'help' for a list of commands.

Lo que muestra la anterior salida es la ejecucion del programa yield.c, este lo que hace es realizar un ciclo for en el que muestra su PID y luego cede el uso del procesador.
Por eso, como vemos los 3 procesos dicen hello uno detras del otro, ya que el primero está cediendo el uso del procesador al ejecutar la syscall de print, luego viene el siguiente y asi. En el momento que comienzan a decir back in enviroment lo que esta sucediendo es que cada proceso está en el ciclo for (donde está el yield). Al llamar a la syscall yield el scheduler lo que hace es simplemente poner a correr el siguiente enviroment y asi sucesivamente. Para finalizar cada proceso llega a su 4ta iteracion, sale del ciclo for, dice "All done in ..." y termina su funcion umain, aqui lo que sucede es que el kernel hace free de ese entorno.

---------------------------------------------------------------------------------------

Tarea: envid2env

Si un proceso llama a `sys_env_destroy(0)` eso por consiguiente llamara a `envid2env(0, &e, 1)` y envid2env devolvera un puntero al currentenv. De esta manera se destruira de manera exitosa el environment actual de manera polite.

---------------------------------------------------------------------------------------
Tarea: dumbfork

1. En caso de que el proceso padre reserve una pagina con `sys_page_alloc` esta se agregara al espacio de direcciones del mismo y sera copiada luego por el proceso hijo como cualquier otra pagina.

2. No se preserva el estado de solo lectura ya que los permisos con los que se llama a la syscall `sys_page_alloc` y `sys_page_map` incluyen el permiso `PTE_W`. Se puede saber si una pagina se puede escribir de la siguiente manera.

```
for(addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE){

    // Observo los permisos del pgdirentry *pgdirentry & PTE_W
    pde_t *pgdirentry = (pde_t *)(PGADDR(PDX(uvpd),PTX(uvpd),(PDX(addr)*sizeof(pde_t)));
    

    if((*pgdirentry) & PTE_P){
        // Observo los permisos del pgtablentry *pgtablentry & PTE_W
        pte_t *pgtablentry = (pte_t *)(PGADDR(PDX(uvpt),PDX(addr),(PTX(addr)*size (pte_t))));
        
    }
}
```

3. `duppage` aloca una pagina en el proceso hijo en la direccion `addr`, mapea dicha pagina a una posicion temporal del padre (ubicado en UTEMP) y copia el contenido del padre desde la direccion origial `addr` a la temporal `UTMP`, logrando de esta manera que el proceso hijo tenga el contenido del padre. Finalmente remueve el map en el padre.

4. Si la pagina tiene que quedar como solo lectura en el proceso hijo se deberia agregar una llamada mas a `sys_page_map` que mapee sobre si mismo esa pagina con distintos permisos.

```
sys_page_map(dstenv, addr, dstenv, addr, PTE_P|PTE_U)
```

Una alternativa seria usar ese booleano para omitir el permiso de escritura en `sys_page_alloc`

5. Se usa &addr por que es una variable local y por lo tanto vive en el stack. Por esto mismo ROUNDOWN nos dara el principio de esa pagina.

---------------------------------------------------------------------------------------

Tarea: multicore_init


1. ¿Qué código copia, y a dónde, la siguiente línea de la función boot_aps()?

La funcion `boot_aps` copia el codigo que se encuentra en `mpentry.S` a un sector de memoria definido por `MPENTRY_PADDR` precisamente la direccion fisica `0x7000`. Este es 
un sector de memoria reservado para el codigo de booteo correspondiente a los APs Cpu.

2. ¿Para qué se usa la variable global mpentry_kstack? ¿Qué ocurriría si el espacio para este stack se reservara en el archivo kern/mpentry.S, de manera similar a bootstack en el archivo kern/entry.S?

La variable `mpentry_kstack` apunta al stack que utilizara el CPU que se desea inicializar. Dicho stack depende del numero del cpu que se esta inicializando por eso no puede ser parte del archivo `kern/mpentry.S` ya que ese codigo sera comun para todos los APs Cpu.

3. Cuando QEMU corre con múltiples CPUs, éstas se muestran en GDB como hilos de ejecución separados. Mostrar una sesión de GDB en la que se muestre cómo va cambiando el valor de la variable global mpentry_kstack:

```
Thread 1 hit Hardware watchpoint 1: mpentry_kstack

Old value = (void *) 0x0
New value = (void *) 0xf0258000 <percpu_kstacks+65536>


Old value = (void *) 0xf0258000 <percpu_kstacks+65536>
New value = (void *) 0xf0260000 <percpu_kstacks+98304>


Thread 1 hit Hardware watchpoint 1: mpentry_kstack

Old value = (void *) 0xf0260000 <percpu_kstacks+98304>
New value = (void *) 0xf0268000 <percpu_kstacks+131072>
```

4.En el archivo kern/mpentry.S se puede leer:
```
We cannot use kern_pgdir yet because we are still
running at a low EIP.
movl $(RELOC(entry_pgdir)), %eax
```

¿Qué valor tendrá el registro %eip cuando se ejecute esa línea?
Responder con redondeo a 12 bits, justificando desde qué región de memoria se está ejecutando este código.

El EIP tendría que obtenerlo desde 0x7000 sumando las lineas de código hasta la instruccion actual. Como lo piden redondeado a 12 bits sera solo 0x7000.

¿Se detiene en algún momento la ejecución si se pone un breakpoint en mpentry_start? ¿Por qué?

La direccion del simbolo `mpentry_start` en la que gdb pondra el breakpoint no sera la misma de donde se ejecutrara. Gdb no conoce la direccion final donde se copiara el codigo, por eso de nada sirve tratar de parar la ejecuccion de esa manera.


---------------------------------------------------------------------------------------

Tarea: ipc_recv

Un proceso podría intentar enviar el valor númerico -E_INVAL vía ipc_send(). ¿Cómo es posible distinguir si es un error, o no?

```
envid_t src = -1;
int r = ipc_recv(&src, 0, NULL);

if (r < 0)
  if (/* ??? */)
    puts("Hubo error.");
  else
    puts("Valor negativo correcto.")
```
El codigo podria detectarse de la siguiente manera:


```
envid_t src = -1;
int r = ipc_recv(&src, 0, NULL);

if (r < 0)
  if (src == 0) <----- Si hay error y se envia src, se setea en 0.
    puts("Hubo error.");
  else
    puts("Valor negativo correcto.")
```

---------------------------------------------------------------------------------------

Tarea: sys_ipc_try_send


Se pide ahora explicar cómo se podría implementar una función sys_ipc_send() que sea bloqueante, es decir, que si un proceso A la usa para enviar un mensaje a B, pero B no está esperando un mensaje, el proceso A sea puesto en estado ENV_NOT_RUNNABLE, y despertado una vez B llame a ipc_recv().

Es posible que surjan varias alternativas de implementación; para cada una, indicar:

Qué cambios se necesitan en struct Env para la implementación
Qué se haría en sys_ipc_send() y en sys_ipc_recv() en esta nueva implementación
Si funcionaría que más de un proceso pueda enviar a B, y quedar todos bloqueados; y el orden en que se despertarían
Si existe en algún momento la posibilidad de deadlock

1. La primera alternativa que podria implemetarse seria similar a la logica en `sys_ipc_recv`. La idea seria que si ambas son bloqueantes, solo 1 seria bloqueante al mismo tiempo. 

```
Ej:
Recv bloqueado.
Llamo a recv() -> bloqueado.
Llamo a send() -> se envia el mensaje y se desbloquean ambos procesos.

Send bloqueado.
Llamo a send() -> bloqueado.
Llamo a recv() -> se envia el mensaje y se desbloquean ambos procesos.
```

En esta situacion solo habria que agregar una propiedad en el Struct Env que marque quien es el hilo sender y si esta bloqueado o no, para que en el momento en el que se realice el recv esa funcion desbloquee al hilo sender. 
Esto podria traer problemas si multiples procesos quisiesen enviar ya que todos se bloquearian. Solucionar esto requeriria estructuras de datos mas complejas, pero se podria prevenir mirando si ya existe un hilo que esta esperando enviar. Bajo esta situacion no se prevee que habria deadlocks.

2. Una segunda alternativa seria la de mantener una estructura auxiliar de Envs que estan queriendo enviar, esos hilos quedarian bloqueados hasta que un correspondiente rcv sea llamado para ese hilo. Esto daria lugar a un comportamiento mas general ya que multiples procesos podrian enviar a un solo proceso. Tampoco se encuentran razones que provocarian deadlocks.

---------------------------------------------------------------------------------------

¿Puede hacerse con la función set_pgfault_handler()? De no poderse, ¿cómo llega al hijo el valor correcto de la variable global _pgfault_handler?

No, este seteo se realiza desde el padre, por lo que con dicha funcion no es posible seleccionar a que env lo queremos setear (se hace automaticamente para el env que lo requiera).
Esto se hace a mano, utilizando memoria dinamica para el uxstack del hijo y tambien hacer uso de la syscall set_pfgault_upcall, con parametro _pgfault_upcall.