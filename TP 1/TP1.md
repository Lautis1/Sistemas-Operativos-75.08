TP1: Memoria virtual en JOS
===========================

backtrace_func_names
--------------------

Salida del comando `backtrace`:

```

K> backtrace
ebp f0110f08 eip f0100a36 args 00000001 f0110f30 00000000 0000000a 00000009
kern/monitor.c:131: runcmd+0xf0100a36
ebp f0110f88 eip f0100a7f args f0102124 f0110fcc f0110fb8 f0100112 00000000
kern/monitor.c:149: monitor+0xf0100a7f
ebp f0110f98 eip f0100112 args 00000000 f0110fcc 00000083 f0100b02 00010094
kern/init.c:84: _panic+0xf0100112
ebp f0110fb8 eip f0100b40 args f0102189 00000083 f0102160 f0100b29 00010094
kern/pmap.c:241: page_init+0xf0100b40
ebp f0110fd8 eip f01000e1 args 00000005 00001aac 00000650 00000000 00000000
kern/init.c:45: i386_init+0xf01000e1
ebp f0110ff8 eip f010003e args 00112021 00000000 00000000 00000000 00000000
kern/entry.S:84: entry+0xf010003e

...
```


boot_alloc_pos
--------------

a) Para la primera parte se uso el comando `readelf -a obj/kern/kernel` y se busco el simbolo `end` cuyo valor era `0xf0114950`. Matematicamente se resolvio:

```
(f0114950)base16 = (4027664720)base10
X = PAGESIZE - (4027664720 % PAGESIZE) = 4096 - 2384 = 1712
(nextfree)base10 = 4027664720 + X = 4027664720 + 1712 = 4027666432
(nextfree)base16 = 0xf0115000
```

b) Luego se resolvio en gdb verificando que lo calculado era correcto

```
(gdb) finish
Run till exit from #0  boot_alloc (n=4027666432) at kern/pmap.c:109
=> 0xf0100ef4 <mem_init+26>:    mov    %eax,0xf0114948
mem_init () at kern/pmap.c:145
145             kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
Value returned is $7 = (void *) 0xf0115000
```


page_alloc
----------
`page2pa()` es una funcion que tiene por objetivo pasar de un puntero de page_info a la posicion en memoria fisica de la pagina que representa ese puntero.

`page2kva()` es el equivalente a la anterior definicion pero con una direccion virtual de kernel.


map_region_large
----------------

Las siguientes direcciones cumplieron las condiciones para poder ser mapeadas con large pages (64):


```
f0000000
f0400000
f0800000
f0c00000
f1000000
f1400000
f1800000
f1c00000
f2000000
f2400000
f2800000
f2c00000
f3000000
f3400000
f3800000
f3c00000
f4000000
f4400000
f4800000
f4c00000
f5000000
f5400000
f5800000
f5c00000
f6000000
f6400000
f6800000
f6c00000
f7000000
f7400000
f7800000
f7c00000
f8000000
f8400000
f8800000
f8c00000
f9000000
f9400000
f9800000
f9c00000
fa000000
fa400000
fa800000
fac00000
fb000000
fb400000
fb800000
fbc00000
fc000000
fc400000
fc800000
fcc00000
fd000000
fd400000
fd800000
fdc00000
fe000000
fe400000
fe800000
fec00000
ff000000
ff400000
ff800000
ffc00000
```

Esto implica que por cada una de ellas se ahorro una pagina intermedia.
Cada pagina ocupa 4K ---> 4K * 64 = 256K

A esto se le debe sumar la optimizacion de `entrypgdir.c` que equivale a una pagina mas.

Espacio total optimizado: `260K`

La cantidad no depende de la computadora, resulta fija ya que es un intervalo de memoria que cumple con
las condiciones y no depende de la memoria fisica disponible.

