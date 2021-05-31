
obj/user/breakpoint.debug:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	f3 0f 1e fb          	endbr32 
  80003d:	55                   	push   %ebp
  80003e:	89 e5                	mov    %esp,%ebp
  800040:	56                   	push   %esi
  800041:	53                   	push   %ebx
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800048:	e8 19 01 00 00       	call   800166 <sys_getenvid>
	if (id >= 0)
  80004d:	85 c0                	test   %eax,%eax
  80004f:	78 12                	js     800063 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800051:	25 ff 03 00 00       	and    $0x3ff,%eax
  800056:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x35>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0a 00 00 00       	call   800087 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	f3 0f 1e fb          	endbr32 
  80008b:	55                   	push   %ebp
  80008c:	89 e5                	mov    %esp,%ebp
  80008e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800091:	e8 53 04 00 00       	call   8004e9 <close_all>
	sys_env_destroy(0);
  800096:	83 ec 0c             	sub    $0xc,%esp
  800099:	6a 00                	push   $0x0
  80009b:	e8 a0 00 00 00       	call   800140 <sys_env_destroy>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    

008000a5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
  8000ab:	83 ec 1c             	sub    $0x1c,%esp
  8000ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b4:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000bf:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c8:	74 04                	je     8000ce <syscall+0x29>
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f 08                	jg     8000d6 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	50                   	push   %eax
  8000da:	ff 75 e0             	pushl  -0x20(%ebp)
  8000dd:	68 ca 1d 80 00       	push   $0x801dca
  8000e2:	6a 23                	push   $0x23
  8000e4:	68 e7 1d 80 00       	push   $0x801de7
  8000e9:	e8 51 0f 00 00       	call   80103f <_panic>

008000ee <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000ee:	f3 0f 1e fb          	endbr32 
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f8:	6a 00                	push   $0x0
  8000fa:	6a 00                	push   $0x0
  8000fc:	6a 00                	push   $0x0
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
  800109:	b8 00 00 00 00       	mov    $0x0,%eax
  80010e:	e8 92 ff ff ff       	call   8000a5 <syscall>
}
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <sys_cgetc>:

int
sys_cgetc(void)
{
  800118:	f3 0f 1e fb          	endbr32 
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800122:	6a 00                	push   $0x0
  800124:	6a 00                	push   $0x0
  800126:	6a 00                	push   $0x0
  800128:	6a 00                	push   $0x0
  80012a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012f:	ba 00 00 00 00       	mov    $0x0,%edx
  800134:	b8 01 00 00 00       	mov    $0x1,%eax
  800139:	e8 67 ff ff ff       	call   8000a5 <syscall>
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800140:	f3 0f 1e fb          	endbr32 
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014a:	6a 00                	push   $0x0
  80014c:	6a 00                	push   $0x0
  80014e:	6a 00                	push   $0x0
  800150:	6a 00                	push   $0x0
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	ba 01 00 00 00       	mov    $0x1,%edx
  80015a:	b8 03 00 00 00       	mov    $0x3,%eax
  80015f:	e8 41 ff ff ff       	call   8000a5 <syscall>
}
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800166:	f3 0f 1e fb          	endbr32 
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800170:	6a 00                	push   $0x0
  800172:	6a 00                	push   $0x0
  800174:	6a 00                	push   $0x0
  800176:	6a 00                	push   $0x0
  800178:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017d:	ba 00 00 00 00       	mov    $0x0,%edx
  800182:	b8 02 00 00 00       	mov    $0x2,%eax
  800187:	e8 19 ff ff ff       	call   8000a5 <syscall>
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <sys_yield>:

void
sys_yield(void)
{
  80018e:	f3 0f 1e fb          	endbr32 
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800198:	6a 00                	push   $0x0
  80019a:	6a 00                	push   $0x0
  80019c:	6a 00                	push   $0x0
  80019e:	6a 00                	push   $0x0
  8001a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001aa:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001af:	e8 f1 fe ff ff       	call   8000a5 <syscall>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b9:	f3 0f 1e fb          	endbr32 
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001c3:	6a 00                	push   $0x0
  8001c5:	6a 00                	push   $0x0
  8001c7:	ff 75 10             	pushl  0x10(%ebp)
  8001ca:	ff 75 0c             	pushl  0xc(%ebp)
  8001cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d0:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d5:	b8 04 00 00 00       	mov    $0x4,%eax
  8001da:	e8 c6 fe ff ff       	call   8000a5 <syscall>
}
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e1:	f3 0f 1e fb          	endbr32 
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001eb:	ff 75 18             	pushl  0x18(%ebp)
  8001ee:	ff 75 14             	pushl  0x14(%ebp)
  8001f1:	ff 75 10             	pushl  0x10(%ebp)
  8001f4:	ff 75 0c             	pushl  0xc(%ebp)
  8001f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fa:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ff:	b8 05 00 00 00       	mov    $0x5,%eax
  800204:	e8 9c fe ff ff       	call   8000a5 <syscall>
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020b:	f3 0f 1e fb          	endbr32 
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800215:	6a 00                	push   $0x0
  800217:	6a 00                	push   $0x0
  800219:	6a 00                	push   $0x0
  80021b:	ff 75 0c             	pushl  0xc(%ebp)
  80021e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800221:	ba 01 00 00 00       	mov    $0x1,%edx
  800226:	b8 06 00 00 00       	mov    $0x6,%eax
  80022b:	e8 75 fe ff ff       	call   8000a5 <syscall>
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800232:	f3 0f 1e fb          	endbr32 
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80023c:	6a 00                	push   $0x0
  80023e:	6a 00                	push   $0x0
  800240:	6a 00                	push   $0x0
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800248:	ba 01 00 00 00       	mov    $0x1,%edx
  80024d:	b8 08 00 00 00       	mov    $0x8,%eax
  800252:	e8 4e fe ff ff       	call   8000a5 <syscall>
}
  800257:	c9                   	leave  
  800258:	c3                   	ret    

00800259 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800259:	f3 0f 1e fb          	endbr32 
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800263:	6a 00                	push   $0x0
  800265:	6a 00                	push   $0x0
  800267:	6a 00                	push   $0x0
  800269:	ff 75 0c             	pushl  0xc(%ebp)
  80026c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026f:	ba 01 00 00 00       	mov    $0x1,%edx
  800274:	b8 09 00 00 00       	mov    $0x9,%eax
  800279:	e8 27 fe ff ff       	call   8000a5 <syscall>
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800280:	f3 0f 1e fb          	endbr32 
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80028a:	6a 00                	push   $0x0
  80028c:	6a 00                	push   $0x0
  80028e:	6a 00                	push   $0x0
  800290:	ff 75 0c             	pushl  0xc(%ebp)
  800293:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800296:	ba 01 00 00 00       	mov    $0x1,%edx
  80029b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a0:	e8 00 fe ff ff       	call   8000a5 <syscall>
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a7:	f3 0f 1e fb          	endbr32 
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002b1:	6a 00                	push   $0x0
  8002b3:	ff 75 14             	pushl  0x14(%ebp)
  8002b6:	ff 75 10             	pushl  0x10(%ebp)
  8002b9:	ff 75 0c             	pushl  0xc(%ebp)
  8002bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002c9:	e8 d7 fd ff ff       	call   8000a5 <syscall>
}
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	f3 0f 1e fb          	endbr32 
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002da:	6a 00                	push   $0x0
  8002dc:	6a 00                	push   $0x0
  8002de:	6a 00                	push   $0x0
  8002e0:	6a 00                	push   $0x0
  8002e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ea:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ef:	e8 b1 fd ff ff       	call   8000a5 <syscall>
}
  8002f4:	c9                   	leave  
  8002f5:	c3                   	ret    

008002f6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002f6:	f3 0f 1e fb          	endbr32 
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	05 00 00 00 30       	add    $0x30000000,%eax
  800305:	c1 e8 0c             	shr    $0xc,%eax
}
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80030a:	f3 0f 1e fb          	endbr32 
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800314:	ff 75 08             	pushl  0x8(%ebp)
  800317:	e8 da ff ff ff       	call   8002f6 <fd2num>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	c1 e0 0c             	shl    $0xc,%eax
  800322:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800327:	c9                   	leave  
  800328:	c3                   	ret    

00800329 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800329:	f3 0f 1e fb          	endbr32 
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800335:	89 c2                	mov    %eax,%edx
  800337:	c1 ea 16             	shr    $0x16,%edx
  80033a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800341:	f6 c2 01             	test   $0x1,%dl
  800344:	74 2d                	je     800373 <fd_alloc+0x4a>
  800346:	89 c2                	mov    %eax,%edx
  800348:	c1 ea 0c             	shr    $0xc,%edx
  80034b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800352:	f6 c2 01             	test   $0x1,%dl
  800355:	74 1c                	je     800373 <fd_alloc+0x4a>
  800357:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80035c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800361:	75 d2                	jne    800335 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800363:	8b 45 08             	mov    0x8(%ebp),%eax
  800366:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80036c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800371:	eb 0a                	jmp    80037d <fd_alloc+0x54>
			*fd_store = fd;
  800373:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800376:	89 01                	mov    %eax,(%ecx)
			return 0;
  800378:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80037f:	f3 0f 1e fb          	endbr32 
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800389:	83 f8 1f             	cmp    $0x1f,%eax
  80038c:	77 30                	ja     8003be <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80038e:	c1 e0 0c             	shl    $0xc,%eax
  800391:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800396:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80039c:	f6 c2 01             	test   $0x1,%dl
  80039f:	74 24                	je     8003c5 <fd_lookup+0x46>
  8003a1:	89 c2                	mov    %eax,%edx
  8003a3:	c1 ea 0c             	shr    $0xc,%edx
  8003a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ad:	f6 c2 01             	test   $0x1,%dl
  8003b0:	74 1a                	je     8003cc <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003bc:	5d                   	pop    %ebp
  8003bd:	c3                   	ret    
		return -E_INVAL;
  8003be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c3:	eb f7                	jmp    8003bc <fd_lookup+0x3d>
		return -E_INVAL;
  8003c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003ca:	eb f0                	jmp    8003bc <fd_lookup+0x3d>
  8003cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d1:	eb e9                	jmp    8003bc <fd_lookup+0x3d>

008003d3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003d3:	f3 0f 1e fb          	endbr32 
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e0:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003e5:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003ea:	39 08                	cmp    %ecx,(%eax)
  8003ec:	74 33                	je     800421 <dev_lookup+0x4e>
  8003ee:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8003f1:	8b 02                	mov    (%edx),%eax
  8003f3:	85 c0                	test   %eax,%eax
  8003f5:	75 f3                	jne    8003ea <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8003fc:	8b 40 48             	mov    0x48(%eax),%eax
  8003ff:	83 ec 04             	sub    $0x4,%esp
  800402:	51                   	push   %ecx
  800403:	50                   	push   %eax
  800404:	68 f8 1d 80 00       	push   $0x801df8
  800409:	e8 18 0d 00 00       	call   801126 <cprintf>
	*dev = 0;
  80040e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800411:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800417:	83 c4 10             	add    $0x10,%esp
  80041a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80041f:	c9                   	leave  
  800420:	c3                   	ret    
			*dev = devtab[i];
  800421:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800424:	89 01                	mov    %eax,(%ecx)
			return 0;
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	eb f2                	jmp    80041f <dev_lookup+0x4c>

0080042d <fd_close>:
{
  80042d:	f3 0f 1e fb          	endbr32 
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	57                   	push   %edi
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
  800437:	83 ec 28             	sub    $0x28,%esp
  80043a:	8b 75 08             	mov    0x8(%ebp),%esi
  80043d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800440:	56                   	push   %esi
  800441:	e8 b0 fe ff ff       	call   8002f6 <fd2num>
  800446:	83 c4 08             	add    $0x8,%esp
  800449:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80044c:	52                   	push   %edx
  80044d:	50                   	push   %eax
  80044e:	e8 2c ff ff ff       	call   80037f <fd_lookup>
  800453:	89 c3                	mov    %eax,%ebx
  800455:	83 c4 10             	add    $0x10,%esp
  800458:	85 c0                	test   %eax,%eax
  80045a:	78 05                	js     800461 <fd_close+0x34>
	    || fd != fd2)
  80045c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80045f:	74 16                	je     800477 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800461:	89 f8                	mov    %edi,%eax
  800463:	84 c0                	test   %al,%al
  800465:	b8 00 00 00 00       	mov    $0x0,%eax
  80046a:	0f 44 d8             	cmove  %eax,%ebx
}
  80046d:	89 d8                	mov    %ebx,%eax
  80046f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800472:	5b                   	pop    %ebx
  800473:	5e                   	pop    %esi
  800474:	5f                   	pop    %edi
  800475:	5d                   	pop    %ebp
  800476:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80047d:	50                   	push   %eax
  80047e:	ff 36                	pushl  (%esi)
  800480:	e8 4e ff ff ff       	call   8003d3 <dev_lookup>
  800485:	89 c3                	mov    %eax,%ebx
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 1a                	js     8004a8 <fd_close+0x7b>
		if (dev->dev_close)
  80048e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800491:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800494:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800499:	85 c0                	test   %eax,%eax
  80049b:	74 0b                	je     8004a8 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80049d:	83 ec 0c             	sub    $0xc,%esp
  8004a0:	56                   	push   %esi
  8004a1:	ff d0                	call   *%eax
  8004a3:	89 c3                	mov    %eax,%ebx
  8004a5:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	56                   	push   %esi
  8004ac:	6a 00                	push   $0x0
  8004ae:	e8 58 fd ff ff       	call   80020b <sys_page_unmap>
	return r;
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	eb b5                	jmp    80046d <fd_close+0x40>

008004b8 <close>:

int
close(int fdnum)
{
  8004b8:	f3 0f 1e fb          	endbr32 
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c5:	50                   	push   %eax
  8004c6:	ff 75 08             	pushl  0x8(%ebp)
  8004c9:	e8 b1 fe ff ff       	call   80037f <fd_lookup>
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	79 02                	jns    8004d7 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004d5:	c9                   	leave  
  8004d6:	c3                   	ret    
		return fd_close(fd, 1);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	6a 01                	push   $0x1
  8004dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8004df:	e8 49 ff ff ff       	call   80042d <fd_close>
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	eb ec                	jmp    8004d5 <close+0x1d>

008004e9 <close_all>:

void
close_all(void)
{
  8004e9:	f3 0f 1e fb          	endbr32 
  8004ed:	55                   	push   %ebp
  8004ee:	89 e5                	mov    %esp,%ebp
  8004f0:	53                   	push   %ebx
  8004f1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004f4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004f9:	83 ec 0c             	sub    $0xc,%esp
  8004fc:	53                   	push   %ebx
  8004fd:	e8 b6 ff ff ff       	call   8004b8 <close>
	for (i = 0; i < MAXFD; i++)
  800502:	83 c3 01             	add    $0x1,%ebx
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	83 fb 20             	cmp    $0x20,%ebx
  80050b:	75 ec                	jne    8004f9 <close_all+0x10>
}
  80050d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800512:	f3 0f 1e fb          	endbr32 
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	57                   	push   %edi
  80051a:	56                   	push   %esi
  80051b:	53                   	push   %ebx
  80051c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80051f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800522:	50                   	push   %eax
  800523:	ff 75 08             	pushl  0x8(%ebp)
  800526:	e8 54 fe ff ff       	call   80037f <fd_lookup>
  80052b:	89 c3                	mov    %eax,%ebx
  80052d:	83 c4 10             	add    $0x10,%esp
  800530:	85 c0                	test   %eax,%eax
  800532:	0f 88 81 00 00 00    	js     8005b9 <dup+0xa7>
		return r;
	close(newfdnum);
  800538:	83 ec 0c             	sub    $0xc,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	e8 75 ff ff ff       	call   8004b8 <close>

	newfd = INDEX2FD(newfdnum);
  800543:	8b 75 0c             	mov    0xc(%ebp),%esi
  800546:	c1 e6 0c             	shl    $0xc,%esi
  800549:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80054f:	83 c4 04             	add    $0x4,%esp
  800552:	ff 75 e4             	pushl  -0x1c(%ebp)
  800555:	e8 b0 fd ff ff       	call   80030a <fd2data>
  80055a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80055c:	89 34 24             	mov    %esi,(%esp)
  80055f:	e8 a6 fd ff ff       	call   80030a <fd2data>
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800569:	89 d8                	mov    %ebx,%eax
  80056b:	c1 e8 16             	shr    $0x16,%eax
  80056e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800575:	a8 01                	test   $0x1,%al
  800577:	74 11                	je     80058a <dup+0x78>
  800579:	89 d8                	mov    %ebx,%eax
  80057b:	c1 e8 0c             	shr    $0xc,%eax
  80057e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800585:	f6 c2 01             	test   $0x1,%dl
  800588:	75 39                	jne    8005c3 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80058a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058d:	89 d0                	mov    %edx,%eax
  80058f:	c1 e8 0c             	shr    $0xc,%eax
  800592:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800599:	83 ec 0c             	sub    $0xc,%esp
  80059c:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a1:	50                   	push   %eax
  8005a2:	56                   	push   %esi
  8005a3:	6a 00                	push   $0x0
  8005a5:	52                   	push   %edx
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 34 fc ff ff       	call   8001e1 <sys_page_map>
  8005ad:	89 c3                	mov    %eax,%ebx
  8005af:	83 c4 20             	add    $0x20,%esp
  8005b2:	85 c0                	test   %eax,%eax
  8005b4:	78 31                	js     8005e7 <dup+0xd5>
		goto err;

	return newfdnum;
  8005b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005b9:	89 d8                	mov    %ebx,%eax
  8005bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005be:	5b                   	pop    %ebx
  8005bf:	5e                   	pop    %esi
  8005c0:	5f                   	pop    %edi
  8005c1:	5d                   	pop    %ebp
  8005c2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ca:	83 ec 0c             	sub    $0xc,%esp
  8005cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d2:	50                   	push   %eax
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	53                   	push   %ebx
  8005d7:	6a 00                	push   $0x0
  8005d9:	e8 03 fc ff ff       	call   8001e1 <sys_page_map>
  8005de:	89 c3                	mov    %eax,%ebx
  8005e0:	83 c4 20             	add    $0x20,%esp
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	79 a3                	jns    80058a <dup+0x78>
	sys_page_unmap(0, newfd);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	56                   	push   %esi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 19 fc ff ff       	call   80020b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005f2:	83 c4 08             	add    $0x8,%esp
  8005f5:	57                   	push   %edi
  8005f6:	6a 00                	push   $0x0
  8005f8:	e8 0e fc ff ff       	call   80020b <sys_page_unmap>
	return r;
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	eb b7                	jmp    8005b9 <dup+0xa7>

00800602 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800602:	f3 0f 1e fb          	endbr32 
  800606:	55                   	push   %ebp
  800607:	89 e5                	mov    %esp,%ebp
  800609:	53                   	push   %ebx
  80060a:	83 ec 1c             	sub    $0x1c,%esp
  80060d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800610:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800613:	50                   	push   %eax
  800614:	53                   	push   %ebx
  800615:	e8 65 fd ff ff       	call   80037f <fd_lookup>
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	85 c0                	test   %eax,%eax
  80061f:	78 3f                	js     800660 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800627:	50                   	push   %eax
  800628:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80062b:	ff 30                	pushl  (%eax)
  80062d:	e8 a1 fd ff ff       	call   8003d3 <dev_lookup>
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	85 c0                	test   %eax,%eax
  800637:	78 27                	js     800660 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800639:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80063c:	8b 42 08             	mov    0x8(%edx),%eax
  80063f:	83 e0 03             	and    $0x3,%eax
  800642:	83 f8 01             	cmp    $0x1,%eax
  800645:	74 1e                	je     800665 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800647:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80064a:	8b 40 08             	mov    0x8(%eax),%eax
  80064d:	85 c0                	test   %eax,%eax
  80064f:	74 35                	je     800686 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800651:	83 ec 04             	sub    $0x4,%esp
  800654:	ff 75 10             	pushl  0x10(%ebp)
  800657:	ff 75 0c             	pushl  0xc(%ebp)
  80065a:	52                   	push   %edx
  80065b:	ff d0                	call   *%eax
  80065d:	83 c4 10             	add    $0x10,%esp
}
  800660:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800663:	c9                   	leave  
  800664:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800665:	a1 04 40 80 00       	mov    0x804004,%eax
  80066a:	8b 40 48             	mov    0x48(%eax),%eax
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	53                   	push   %ebx
  800671:	50                   	push   %eax
  800672:	68 39 1e 80 00       	push   $0x801e39
  800677:	e8 aa 0a 00 00       	call   801126 <cprintf>
		return -E_INVAL;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800684:	eb da                	jmp    800660 <read+0x5e>
		return -E_NOT_SUPP;
  800686:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80068b:	eb d3                	jmp    800660 <read+0x5e>

0080068d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80068d:	f3 0f 1e fb          	endbr32 
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	57                   	push   %edi
  800695:	56                   	push   %esi
  800696:	53                   	push   %ebx
  800697:	83 ec 0c             	sub    $0xc,%esp
  80069a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006a5:	eb 02                	jmp    8006a9 <readn+0x1c>
  8006a7:	01 c3                	add    %eax,%ebx
  8006a9:	39 f3                	cmp    %esi,%ebx
  8006ab:	73 21                	jae    8006ce <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ad:	83 ec 04             	sub    $0x4,%esp
  8006b0:	89 f0                	mov    %esi,%eax
  8006b2:	29 d8                	sub    %ebx,%eax
  8006b4:	50                   	push   %eax
  8006b5:	89 d8                	mov    %ebx,%eax
  8006b7:	03 45 0c             	add    0xc(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	57                   	push   %edi
  8006bc:	e8 41 ff ff ff       	call   800602 <read>
		if (m < 0)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	85 c0                	test   %eax,%eax
  8006c6:	78 04                	js     8006cc <readn+0x3f>
			return m;
		if (m == 0)
  8006c8:	75 dd                	jne    8006a7 <readn+0x1a>
  8006ca:	eb 02                	jmp    8006ce <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cc:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006ce:	89 d8                	mov    %ebx,%eax
  8006d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5f                   	pop    %edi
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006d8:	f3 0f 1e fb          	endbr32 
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	53                   	push   %ebx
  8006e0:	83 ec 1c             	sub    $0x1c,%esp
  8006e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e9:	50                   	push   %eax
  8006ea:	53                   	push   %ebx
  8006eb:	e8 8f fc ff ff       	call   80037f <fd_lookup>
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	78 3a                	js     800731 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006fd:	50                   	push   %eax
  8006fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800701:	ff 30                	pushl  (%eax)
  800703:	e8 cb fc ff ff       	call   8003d3 <dev_lookup>
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	85 c0                	test   %eax,%eax
  80070d:	78 22                	js     800731 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80070f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800712:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800716:	74 1e                	je     800736 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800718:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80071b:	8b 52 0c             	mov    0xc(%edx),%edx
  80071e:	85 d2                	test   %edx,%edx
  800720:	74 35                	je     800757 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800722:	83 ec 04             	sub    $0x4,%esp
  800725:	ff 75 10             	pushl  0x10(%ebp)
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	50                   	push   %eax
  80072c:	ff d2                	call   *%edx
  80072e:	83 c4 10             	add    $0x10,%esp
}
  800731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800734:	c9                   	leave  
  800735:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800736:	a1 04 40 80 00       	mov    0x804004,%eax
  80073b:	8b 40 48             	mov    0x48(%eax),%eax
  80073e:	83 ec 04             	sub    $0x4,%esp
  800741:	53                   	push   %ebx
  800742:	50                   	push   %eax
  800743:	68 55 1e 80 00       	push   $0x801e55
  800748:	e8 d9 09 00 00       	call   801126 <cprintf>
		return -E_INVAL;
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800755:	eb da                	jmp    800731 <write+0x59>
		return -E_NOT_SUPP;
  800757:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80075c:	eb d3                	jmp    800731 <write+0x59>

0080075e <seek>:

int
seek(int fdnum, off_t offset)
{
  80075e:	f3 0f 1e fb          	endbr32 
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800768:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076b:	50                   	push   %eax
  80076c:	ff 75 08             	pushl  0x8(%ebp)
  80076f:	e8 0b fc ff ff       	call   80037f <fd_lookup>
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	85 c0                	test   %eax,%eax
  800779:	78 0e                	js     800789 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800781:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80078b:	f3 0f 1e fb          	endbr32 
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	53                   	push   %ebx
  800793:	83 ec 1c             	sub    $0x1c,%esp
  800796:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800799:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80079c:	50                   	push   %eax
  80079d:	53                   	push   %ebx
  80079e:	e8 dc fb ff ff       	call   80037f <fd_lookup>
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 37                	js     8007e1 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b4:	ff 30                	pushl  (%eax)
  8007b6:	e8 18 fc ff ff       	call   8003d3 <dev_lookup>
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	78 1f                	js     8007e1 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007c9:	74 1b                	je     8007e6 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ce:	8b 52 18             	mov    0x18(%edx),%edx
  8007d1:	85 d2                	test   %edx,%edx
  8007d3:	74 32                	je     800807 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	ff 75 0c             	pushl  0xc(%ebp)
  8007db:	50                   	push   %eax
  8007dc:	ff d2                	call   *%edx
  8007de:	83 c4 10             	add    $0x10,%esp
}
  8007e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007e6:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007eb:	8b 40 48             	mov    0x48(%eax),%eax
  8007ee:	83 ec 04             	sub    $0x4,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	50                   	push   %eax
  8007f3:	68 18 1e 80 00       	push   $0x801e18
  8007f8:	e8 29 09 00 00       	call   801126 <cprintf>
		return -E_INVAL;
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800805:	eb da                	jmp    8007e1 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800807:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80080c:	eb d3                	jmp    8007e1 <ftruncate+0x56>

0080080e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80080e:	f3 0f 1e fb          	endbr32 
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	83 ec 1c             	sub    $0x1c,%esp
  800819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	ff 75 08             	pushl  0x8(%ebp)
  800823:	e8 57 fb ff ff       	call   80037f <fd_lookup>
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	85 c0                	test   %eax,%eax
  80082d:	78 4b                	js     80087a <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800835:	50                   	push   %eax
  800836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800839:	ff 30                	pushl  (%eax)
  80083b:	e8 93 fb ff ff       	call   8003d3 <dev_lookup>
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	85 c0                	test   %eax,%eax
  800845:	78 33                	js     80087a <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800847:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80084e:	74 2f                	je     80087f <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800850:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800853:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085a:	00 00 00 
	stat->st_isdir = 0;
  80085d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800864:	00 00 00 
	stat->st_dev = dev;
  800867:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	53                   	push   %ebx
  800871:	ff 75 f0             	pushl  -0x10(%ebp)
  800874:	ff 50 14             	call   *0x14(%eax)
  800877:	83 c4 10             	add    $0x10,%esp
}
  80087a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    
		return -E_NOT_SUPP;
  80087f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800884:	eb f4                	jmp    80087a <fstat+0x6c>

00800886 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800886:	f3 0f 1e fb          	endbr32 
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	6a 00                	push   $0x0
  800894:	ff 75 08             	pushl  0x8(%ebp)
  800897:	e8 fb 01 00 00       	call   800a97 <open>
  80089c:	89 c3                	mov    %eax,%ebx
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	78 1b                	js     8008c0 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	ff 75 0c             	pushl  0xc(%ebp)
  8008ab:	50                   	push   %eax
  8008ac:	e8 5d ff ff ff       	call   80080e <fstat>
  8008b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b3:	89 1c 24             	mov    %ebx,(%esp)
  8008b6:	e8 fd fb ff ff       	call   8004b8 <close>
	return r;
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	89 f3                	mov    %esi,%ebx
}
  8008c0:	89 d8                	mov    %ebx,%eax
  8008c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	89 c6                	mov    %eax,%esi
  8008d0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008d9:	74 27                	je     800902 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008db:	6a 07                	push   $0x7
  8008dd:	68 00 50 80 00       	push   $0x805000
  8008e2:	56                   	push   %esi
  8008e3:	ff 35 00 40 80 00    	pushl  0x804000
  8008e9:	e8 84 11 00 00       	call   801a72 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008ee:	83 c4 0c             	add    $0xc,%esp
  8008f1:	6a 00                	push   $0x0
  8008f3:	53                   	push   %ebx
  8008f4:	6a 00                	push   $0x0
  8008f6:	e8 09 11 00 00       	call   801a04 <ipc_recv>
}
  8008fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800902:	83 ec 0c             	sub    $0xc,%esp
  800905:	6a 01                	push   $0x1
  800907:	e8 cb 11 00 00       	call   801ad7 <ipc_find_env>
  80090c:	a3 00 40 80 00       	mov    %eax,0x804000
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	eb c5                	jmp    8008db <fsipc+0x12>

00800916 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800916:	f3 0f 1e fb          	endbr32 
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 40 0c             	mov    0xc(%eax),%eax
  800926:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800933:	ba 00 00 00 00       	mov    $0x0,%edx
  800938:	b8 02 00 00 00       	mov    $0x2,%eax
  80093d:	e8 87 ff ff ff       	call   8008c9 <fsipc>
}
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <devfile_flush>:
{
  800944:	f3 0f 1e fb          	endbr32 
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 40 0c             	mov    0xc(%eax),%eax
  800954:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 06 00 00 00       	mov    $0x6,%eax
  800963:	e8 61 ff ff ff       	call   8008c9 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_stat>:
{
  80096a:	f3 0f 1e fb          	endbr32 
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	53                   	push   %ebx
  800972:	83 ec 04             	sub    $0x4,%esp
  800975:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 40 0c             	mov    0xc(%eax),%eax
  80097e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800983:	ba 00 00 00 00       	mov    $0x0,%edx
  800988:	b8 05 00 00 00       	mov    $0x5,%eax
  80098d:	e8 37 ff ff ff       	call   8008c9 <fsipc>
  800992:	85 c0                	test   %eax,%eax
  800994:	78 2c                	js     8009c2 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800996:	83 ec 08             	sub    $0x8,%esp
  800999:	68 00 50 80 00       	push   $0x805000
  80099e:	53                   	push   %ebx
  80099f:	e8 ec 0c 00 00       	call   801690 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a4:	a1 80 50 80 00       	mov    0x805080,%eax
  8009a9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009af:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ba:	83 c4 10             	add    $0x10,%esp
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <devfile_write>:
{
  8009c7:	f3 0f 1e fb          	endbr32 
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 0c             	sub    $0xc,%esp
  8009d1:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d7:	8b 52 0c             	mov    0xc(%edx),%edx
  8009da:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009e0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009e5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009ea:	0f 47 c2             	cmova  %edx,%eax
  8009ed:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8009f2:	50                   	push   %eax
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	68 08 50 80 00       	push   $0x805008
  8009fb:	e8 48 0e 00 00       	call   801848 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a00:	ba 00 00 00 00       	mov    $0x0,%edx
  800a05:	b8 04 00 00 00       	mov    $0x4,%eax
  800a0a:	e8 ba fe ff ff       	call   8008c9 <fsipc>
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_read>:
{
  800a11:	f3 0f 1e fb          	endbr32 
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 40 0c             	mov    0xc(%eax),%eax
  800a23:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a28:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a33:	b8 03 00 00 00       	mov    $0x3,%eax
  800a38:	e8 8c fe ff ff       	call   8008c9 <fsipc>
  800a3d:	89 c3                	mov    %eax,%ebx
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	78 1f                	js     800a62 <devfile_read+0x51>
	assert(r <= n);
  800a43:	39 f0                	cmp    %esi,%eax
  800a45:	77 24                	ja     800a6b <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a47:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4c:	7f 33                	jg     800a81 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a4e:	83 ec 04             	sub    $0x4,%esp
  800a51:	50                   	push   %eax
  800a52:	68 00 50 80 00       	push   $0x805000
  800a57:	ff 75 0c             	pushl  0xc(%ebp)
  800a5a:	e8 e9 0d 00 00       	call   801848 <memmove>
	return r;
  800a5f:	83 c4 10             	add    $0x10,%esp
}
  800a62:	89 d8                	mov    %ebx,%eax
  800a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    
	assert(r <= n);
  800a6b:	68 84 1e 80 00       	push   $0x801e84
  800a70:	68 8b 1e 80 00       	push   $0x801e8b
  800a75:	6a 7c                	push   $0x7c
  800a77:	68 a0 1e 80 00       	push   $0x801ea0
  800a7c:	e8 be 05 00 00       	call   80103f <_panic>
	assert(r <= PGSIZE);
  800a81:	68 ab 1e 80 00       	push   $0x801eab
  800a86:	68 8b 1e 80 00       	push   $0x801e8b
  800a8b:	6a 7d                	push   $0x7d
  800a8d:	68 a0 1e 80 00       	push   $0x801ea0
  800a92:	e8 a8 05 00 00       	call   80103f <_panic>

00800a97 <open>:
{
  800a97:	f3 0f 1e fb          	endbr32 
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	83 ec 1c             	sub    $0x1c,%esp
  800aa3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aa6:	56                   	push   %esi
  800aa7:	e8 a1 0b 00 00       	call   80164d <strlen>
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab4:	7f 6c                	jg     800b22 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ab6:	83 ec 0c             	sub    $0xc,%esp
  800ab9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800abc:	50                   	push   %eax
  800abd:	e8 67 f8 ff ff       	call   800329 <fd_alloc>
  800ac2:	89 c3                	mov    %eax,%ebx
  800ac4:	83 c4 10             	add    $0x10,%esp
  800ac7:	85 c0                	test   %eax,%eax
  800ac9:	78 3c                	js     800b07 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800acb:	83 ec 08             	sub    $0x8,%esp
  800ace:	56                   	push   %esi
  800acf:	68 00 50 80 00       	push   $0x805000
  800ad4:	e8 b7 0b 00 00       	call   801690 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae9:	e8 db fd ff ff       	call   8008c9 <fsipc>
  800aee:	89 c3                	mov    %eax,%ebx
  800af0:	83 c4 10             	add    $0x10,%esp
  800af3:	85 c0                	test   %eax,%eax
  800af5:	78 19                	js     800b10 <open+0x79>
	return fd2num(fd);
  800af7:	83 ec 0c             	sub    $0xc,%esp
  800afa:	ff 75 f4             	pushl  -0xc(%ebp)
  800afd:	e8 f4 f7 ff ff       	call   8002f6 <fd2num>
  800b02:	89 c3                	mov    %eax,%ebx
  800b04:	83 c4 10             	add    $0x10,%esp
}
  800b07:	89 d8                	mov    %ebx,%eax
  800b09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    
		fd_close(fd, 0);
  800b10:	83 ec 08             	sub    $0x8,%esp
  800b13:	6a 00                	push   $0x0
  800b15:	ff 75 f4             	pushl  -0xc(%ebp)
  800b18:	e8 10 f9 ff ff       	call   80042d <fd_close>
		return r;
  800b1d:	83 c4 10             	add    $0x10,%esp
  800b20:	eb e5                	jmp    800b07 <open+0x70>
		return -E_BAD_PATH;
  800b22:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b27:	eb de                	jmp    800b07 <open+0x70>

00800b29 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b29:	f3 0f 1e fb          	endbr32 
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b33:	ba 00 00 00 00       	mov    $0x0,%edx
  800b38:	b8 08 00 00 00       	mov    $0x8,%eax
  800b3d:	e8 87 fd ff ff       	call   8008c9 <fsipc>
}
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b44:	f3 0f 1e fb          	endbr32 
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b50:	83 ec 0c             	sub    $0xc,%esp
  800b53:	ff 75 08             	pushl  0x8(%ebp)
  800b56:	e8 af f7 ff ff       	call   80030a <fd2data>
  800b5b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b5d:	83 c4 08             	add    $0x8,%esp
  800b60:	68 b7 1e 80 00       	push   $0x801eb7
  800b65:	53                   	push   %ebx
  800b66:	e8 25 0b 00 00       	call   801690 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b6b:	8b 46 04             	mov    0x4(%esi),%eax
  800b6e:	2b 06                	sub    (%esi),%eax
  800b70:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b76:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b7d:	00 00 00 
	stat->st_dev = &devpipe;
  800b80:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b87:	30 80 00 
	return 0;
}
  800b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b96:	f3 0f 1e fb          	endbr32 
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba4:	53                   	push   %ebx
  800ba5:	6a 00                	push   $0x0
  800ba7:	e8 5f f6 ff ff       	call   80020b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bac:	89 1c 24             	mov    %ebx,(%esp)
  800baf:	e8 56 f7 ff ff       	call   80030a <fd2data>
  800bb4:	83 c4 08             	add    $0x8,%esp
  800bb7:	50                   	push   %eax
  800bb8:	6a 00                	push   $0x0
  800bba:	e8 4c f6 ff ff       	call   80020b <sys_page_unmap>
}
  800bbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <_pipeisclosed>:
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 1c             	sub    $0x1c,%esp
  800bcd:	89 c7                	mov    %eax,%edi
  800bcf:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bd1:	a1 04 40 80 00       	mov    0x804004,%eax
  800bd6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	57                   	push   %edi
  800bdd:	e8 32 0f 00 00       	call   801b14 <pageref>
  800be2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800be5:	89 34 24             	mov    %esi,(%esp)
  800be8:	e8 27 0f 00 00       	call   801b14 <pageref>
		nn = thisenv->env_runs;
  800bed:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bf3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	39 cb                	cmp    %ecx,%ebx
  800bfb:	74 1b                	je     800c18 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bfd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c00:	75 cf                	jne    800bd1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c02:	8b 42 58             	mov    0x58(%edx),%eax
  800c05:	6a 01                	push   $0x1
  800c07:	50                   	push   %eax
  800c08:	53                   	push   %ebx
  800c09:	68 be 1e 80 00       	push   $0x801ebe
  800c0e:	e8 13 05 00 00       	call   801126 <cprintf>
  800c13:	83 c4 10             	add    $0x10,%esp
  800c16:	eb b9                	jmp    800bd1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c18:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c1b:	0f 94 c0             	sete   %al
  800c1e:	0f b6 c0             	movzbl %al,%eax
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <devpipe_write>:
{
  800c29:	f3 0f 1e fb          	endbr32 
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 28             	sub    $0x28,%esp
  800c36:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c39:	56                   	push   %esi
  800c3a:	e8 cb f6 ff ff       	call   80030a <fd2data>
  800c3f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	bf 00 00 00 00       	mov    $0x0,%edi
  800c49:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c4c:	74 4f                	je     800c9d <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c51:	8b 0b                	mov    (%ebx),%ecx
  800c53:	8d 51 20             	lea    0x20(%ecx),%edx
  800c56:	39 d0                	cmp    %edx,%eax
  800c58:	72 14                	jb     800c6e <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c5a:	89 da                	mov    %ebx,%edx
  800c5c:	89 f0                	mov    %esi,%eax
  800c5e:	e8 61 ff ff ff       	call   800bc4 <_pipeisclosed>
  800c63:	85 c0                	test   %eax,%eax
  800c65:	75 3b                	jne    800ca2 <devpipe_write+0x79>
			sys_yield();
  800c67:	e8 22 f5 ff ff       	call   80018e <sys_yield>
  800c6c:	eb e0                	jmp    800c4e <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c75:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c78:	89 c2                	mov    %eax,%edx
  800c7a:	c1 fa 1f             	sar    $0x1f,%edx
  800c7d:	89 d1                	mov    %edx,%ecx
  800c7f:	c1 e9 1b             	shr    $0x1b,%ecx
  800c82:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c85:	83 e2 1f             	and    $0x1f,%edx
  800c88:	29 ca                	sub    %ecx,%edx
  800c8a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c8e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c92:	83 c0 01             	add    $0x1,%eax
  800c95:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c98:	83 c7 01             	add    $0x1,%edi
  800c9b:	eb ac                	jmp    800c49 <devpipe_write+0x20>
	return i;
  800c9d:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca0:	eb 05                	jmp    800ca7 <devpipe_write+0x7e>
				return 0;
  800ca2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <devpipe_read>:
{
  800caf:	f3 0f 1e fb          	endbr32 
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 18             	sub    $0x18,%esp
  800cbc:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cbf:	57                   	push   %edi
  800cc0:	e8 45 f6 ff ff       	call   80030a <fd2data>
  800cc5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cc7:	83 c4 10             	add    $0x10,%esp
  800cca:	be 00 00 00 00       	mov    $0x0,%esi
  800ccf:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cd2:	75 14                	jne    800ce8 <devpipe_read+0x39>
	return i;
  800cd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd7:	eb 02                	jmp    800cdb <devpipe_read+0x2c>
				return i;
  800cd9:	89 f0                	mov    %esi,%eax
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    
			sys_yield();
  800ce3:	e8 a6 f4 ff ff       	call   80018e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800ce8:	8b 03                	mov    (%ebx),%eax
  800cea:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ced:	75 18                	jne    800d07 <devpipe_read+0x58>
			if (i > 0)
  800cef:	85 f6                	test   %esi,%esi
  800cf1:	75 e6                	jne    800cd9 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800cf3:	89 da                	mov    %ebx,%edx
  800cf5:	89 f8                	mov    %edi,%eax
  800cf7:	e8 c8 fe ff ff       	call   800bc4 <_pipeisclosed>
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	74 e3                	je     800ce3 <devpipe_read+0x34>
				return 0;
  800d00:	b8 00 00 00 00       	mov    $0x0,%eax
  800d05:	eb d4                	jmp    800cdb <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d07:	99                   	cltd   
  800d08:	c1 ea 1b             	shr    $0x1b,%edx
  800d0b:	01 d0                	add    %edx,%eax
  800d0d:	83 e0 1f             	and    $0x1f,%eax
  800d10:	29 d0                	sub    %edx,%eax
  800d12:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d1d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d20:	83 c6 01             	add    $0x1,%esi
  800d23:	eb aa                	jmp    800ccf <devpipe_read+0x20>

00800d25 <pipe>:
{
  800d25:	f3 0f 1e fb          	endbr32 
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d34:	50                   	push   %eax
  800d35:	e8 ef f5 ff ff       	call   800329 <fd_alloc>
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	0f 88 23 01 00 00    	js     800e6a <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d47:	83 ec 04             	sub    $0x4,%esp
  800d4a:	68 07 04 00 00       	push   $0x407
  800d4f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d52:	6a 00                	push   $0x0
  800d54:	e8 60 f4 ff ff       	call   8001b9 <sys_page_alloc>
  800d59:	89 c3                	mov    %eax,%ebx
  800d5b:	83 c4 10             	add    $0x10,%esp
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	0f 88 04 01 00 00    	js     800e6a <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6c:	50                   	push   %eax
  800d6d:	e8 b7 f5 ff ff       	call   800329 <fd_alloc>
  800d72:	89 c3                	mov    %eax,%ebx
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	85 c0                	test   %eax,%eax
  800d79:	0f 88 db 00 00 00    	js     800e5a <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7f:	83 ec 04             	sub    $0x4,%esp
  800d82:	68 07 04 00 00       	push   $0x407
  800d87:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8a:	6a 00                	push   $0x0
  800d8c:	e8 28 f4 ff ff       	call   8001b9 <sys_page_alloc>
  800d91:	89 c3                	mov    %eax,%ebx
  800d93:	83 c4 10             	add    $0x10,%esp
  800d96:	85 c0                	test   %eax,%eax
  800d98:	0f 88 bc 00 00 00    	js     800e5a <pipe+0x135>
	va = fd2data(fd0);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	ff 75 f4             	pushl  -0xc(%ebp)
  800da4:	e8 61 f5 ff ff       	call   80030a <fd2data>
  800da9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dab:	83 c4 0c             	add    $0xc,%esp
  800dae:	68 07 04 00 00       	push   $0x407
  800db3:	50                   	push   %eax
  800db4:	6a 00                	push   $0x0
  800db6:	e8 fe f3 ff ff       	call   8001b9 <sys_page_alloc>
  800dbb:	89 c3                	mov    %eax,%ebx
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	0f 88 82 00 00 00    	js     800e4a <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dce:	e8 37 f5 ff ff       	call   80030a <fd2data>
  800dd3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dda:	50                   	push   %eax
  800ddb:	6a 00                	push   $0x0
  800ddd:	56                   	push   %esi
  800dde:	6a 00                	push   $0x0
  800de0:	e8 fc f3 ff ff       	call   8001e1 <sys_page_map>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 20             	add    $0x20,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	78 4e                	js     800e3c <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800dee:	a1 20 30 80 00       	mov    0x803020,%eax
  800df3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800df6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800df8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dfb:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e02:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e05:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	ff 75 f4             	pushl  -0xc(%ebp)
  800e17:	e8 da f4 ff ff       	call   8002f6 <fd2num>
  800e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e21:	83 c4 04             	add    $0x4,%esp
  800e24:	ff 75 f0             	pushl  -0x10(%ebp)
  800e27:	e8 ca f4 ff ff       	call   8002f6 <fd2num>
  800e2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e32:	83 c4 10             	add    $0x10,%esp
  800e35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3a:	eb 2e                	jmp    800e6a <pipe+0x145>
	sys_page_unmap(0, va);
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	56                   	push   %esi
  800e40:	6a 00                	push   $0x0
  800e42:	e8 c4 f3 ff ff       	call   80020b <sys_page_unmap>
  800e47:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e50:	6a 00                	push   $0x0
  800e52:	e8 b4 f3 ff ff       	call   80020b <sys_page_unmap>
  800e57:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e5a:	83 ec 08             	sub    $0x8,%esp
  800e5d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e60:	6a 00                	push   $0x0
  800e62:	e8 a4 f3 ff ff       	call   80020b <sys_page_unmap>
  800e67:	83 c4 10             	add    $0x10,%esp
}
  800e6a:	89 d8                	mov    %ebx,%eax
  800e6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <pipeisclosed>:
{
  800e73:	f3 0f 1e fb          	endbr32 
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e80:	50                   	push   %eax
  800e81:	ff 75 08             	pushl  0x8(%ebp)
  800e84:	e8 f6 f4 ff ff       	call   80037f <fd_lookup>
  800e89:	83 c4 10             	add    $0x10,%esp
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	78 18                	js     800ea8 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	ff 75 f4             	pushl  -0xc(%ebp)
  800e96:	e8 6f f4 ff ff       	call   80030a <fd2data>
  800e9b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea0:	e8 1f fd ff ff       	call   800bc4 <_pipeisclosed>
  800ea5:	83 c4 10             	add    $0x10,%esp
}
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eaa:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800eae:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb3:	c3                   	ret    

00800eb4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb4:	f3 0f 1e fb          	endbr32 
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ebe:	68 d6 1e 80 00       	push   $0x801ed6
  800ec3:	ff 75 0c             	pushl  0xc(%ebp)
  800ec6:	e8 c5 07 00 00       	call   801690 <strcpy>
	return 0;
}
  800ecb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <devcons_write>:
{
  800ed2:	f3 0f 1e fb          	endbr32 
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
  800edc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ee2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ee7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eed:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef0:	73 31                	jae    800f23 <devcons_write+0x51>
		m = n - tot;
  800ef2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef5:	29 f3                	sub    %esi,%ebx
  800ef7:	83 fb 7f             	cmp    $0x7f,%ebx
  800efa:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800eff:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	53                   	push   %ebx
  800f06:	89 f0                	mov    %esi,%eax
  800f08:	03 45 0c             	add    0xc(%ebp),%eax
  800f0b:	50                   	push   %eax
  800f0c:	57                   	push   %edi
  800f0d:	e8 36 09 00 00       	call   801848 <memmove>
		sys_cputs(buf, m);
  800f12:	83 c4 08             	add    $0x8,%esp
  800f15:	53                   	push   %ebx
  800f16:	57                   	push   %edi
  800f17:	e8 d2 f1 ff ff       	call   8000ee <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f1c:	01 de                	add    %ebx,%esi
  800f1e:	83 c4 10             	add    $0x10,%esp
  800f21:	eb ca                	jmp    800eed <devcons_write+0x1b>
}
  800f23:	89 f0                	mov    %esi,%eax
  800f25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <devcons_read>:
{
  800f2d:	f3 0f 1e fb          	endbr32 
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 08             	sub    $0x8,%esp
  800f37:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f40:	74 21                	je     800f63 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f42:	e8 d1 f1 ff ff       	call   800118 <sys_cgetc>
  800f47:	85 c0                	test   %eax,%eax
  800f49:	75 07                	jne    800f52 <devcons_read+0x25>
		sys_yield();
  800f4b:	e8 3e f2 ff ff       	call   80018e <sys_yield>
  800f50:	eb f0                	jmp    800f42 <devcons_read+0x15>
	if (c < 0)
  800f52:	78 0f                	js     800f63 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f54:	83 f8 04             	cmp    $0x4,%eax
  800f57:	74 0c                	je     800f65 <devcons_read+0x38>
	*(char*)vbuf = c;
  800f59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5c:	88 02                	mov    %al,(%edx)
	return 1;
  800f5e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    
		return 0;
  800f65:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6a:	eb f7                	jmp    800f63 <devcons_read+0x36>

00800f6c <cputchar>:
{
  800f6c:	f3 0f 1e fb          	endbr32 
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f76:	8b 45 08             	mov    0x8(%ebp),%eax
  800f79:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f7c:	6a 01                	push   $0x1
  800f7e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f81:	50                   	push   %eax
  800f82:	e8 67 f1 ff ff       	call   8000ee <sys_cputs>
}
  800f87:	83 c4 10             	add    $0x10,%esp
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <getchar>:
{
  800f8c:	f3 0f 1e fb          	endbr32 
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f96:	6a 01                	push   $0x1
  800f98:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9b:	50                   	push   %eax
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 5f f6 ff ff       	call   800602 <read>
	if (r < 0)
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	78 06                	js     800fb0 <getchar+0x24>
	if (r < 1)
  800faa:	74 06                	je     800fb2 <getchar+0x26>
	return c;
  800fac:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    
		return -E_EOF;
  800fb2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fb7:	eb f7                	jmp    800fb0 <getchar+0x24>

00800fb9 <iscons>:
{
  800fb9:	f3 0f 1e fb          	endbr32 
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc6:	50                   	push   %eax
  800fc7:	ff 75 08             	pushl  0x8(%ebp)
  800fca:	e8 b0 f3 ff ff       	call   80037f <fd_lookup>
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 11                	js     800fe7 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fdf:	39 10                	cmp    %edx,(%eax)
  800fe1:	0f 94 c0             	sete   %al
  800fe4:	0f b6 c0             	movzbl %al,%eax
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <opencons>:
{
  800fe9:	f3 0f 1e fb          	endbr32 
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800ff3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff6:	50                   	push   %eax
  800ff7:	e8 2d f3 ff ff       	call   800329 <fd_alloc>
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 3a                	js     80103d <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801003:	83 ec 04             	sub    $0x4,%esp
  801006:	68 07 04 00 00       	push   $0x407
  80100b:	ff 75 f4             	pushl  -0xc(%ebp)
  80100e:	6a 00                	push   $0x0
  801010:	e8 a4 f1 ff ff       	call   8001b9 <sys_page_alloc>
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 21                	js     80103d <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80101c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801025:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801027:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	50                   	push   %eax
  801035:	e8 bc f2 ff ff       	call   8002f6 <fd2num>
  80103a:	83 c4 10             	add    $0x10,%esp
}
  80103d:	c9                   	leave  
  80103e:	c3                   	ret    

0080103f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80103f:	f3 0f 1e fb          	endbr32 
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801048:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801051:	e8 10 f1 ff ff       	call   800166 <sys_getenvid>
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	ff 75 0c             	pushl  0xc(%ebp)
  80105c:	ff 75 08             	pushl  0x8(%ebp)
  80105f:	56                   	push   %esi
  801060:	50                   	push   %eax
  801061:	68 e4 1e 80 00       	push   $0x801ee4
  801066:	e8 bb 00 00 00       	call   801126 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106b:	83 c4 18             	add    $0x18,%esp
  80106e:	53                   	push   %ebx
  80106f:	ff 75 10             	pushl  0x10(%ebp)
  801072:	e8 5a 00 00 00       	call   8010d1 <vcprintf>
	cprintf("\n");
  801077:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  80107e:	e8 a3 00 00 00       	call   801126 <cprintf>
  801083:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801086:	cc                   	int3   
  801087:	eb fd                	jmp    801086 <_panic+0x47>

00801089 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801089:	f3 0f 1e fb          	endbr32 
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	53                   	push   %ebx
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801097:	8b 13                	mov    (%ebx),%edx
  801099:	8d 42 01             	lea    0x1(%edx),%eax
  80109c:	89 03                	mov    %eax,(%ebx)
  80109e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010aa:	74 09                	je     8010b5 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010ac:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b3:	c9                   	leave  
  8010b4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010b5:	83 ec 08             	sub    $0x8,%esp
  8010b8:	68 ff 00 00 00       	push   $0xff
  8010bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c0:	50                   	push   %eax
  8010c1:	e8 28 f0 ff ff       	call   8000ee <sys_cputs>
		b->idx = 0;
  8010c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	eb db                	jmp    8010ac <putch+0x23>

008010d1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010d1:	f3 0f 1e fb          	endbr32 
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010e5:	00 00 00 
	b.cnt = 0;
  8010e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f2:	ff 75 0c             	pushl  0xc(%ebp)
  8010f5:	ff 75 08             	pushl  0x8(%ebp)
  8010f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010fe:	50                   	push   %eax
  8010ff:	68 89 10 80 00       	push   $0x801089
  801104:	e8 80 01 00 00       	call   801289 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801109:	83 c4 08             	add    $0x8,%esp
  80110c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801112:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801118:	50                   	push   %eax
  801119:	e8 d0 ef ff ff       	call   8000ee <sys_cputs>

	return b.cnt;
}
  80111e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801124:	c9                   	leave  
  801125:	c3                   	ret    

00801126 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801126:	f3 0f 1e fb          	endbr32 
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801130:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801133:	50                   	push   %eax
  801134:	ff 75 08             	pushl  0x8(%ebp)
  801137:	e8 95 ff ff ff       	call   8010d1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80113c:	c9                   	leave  
  80113d:	c3                   	ret    

0080113e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 1c             	sub    $0x1c,%esp
  801147:	89 c7                	mov    %eax,%edi
  801149:	89 d6                	mov    %edx,%esi
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
  80114e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801151:	89 d1                	mov    %edx,%ecx
  801153:	89 c2                	mov    %eax,%edx
  801155:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801158:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80115b:	8b 45 10             	mov    0x10(%ebp),%eax
  80115e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801161:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801164:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80116b:	39 c2                	cmp    %eax,%edx
  80116d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801170:	72 3e                	jb     8011b0 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801172:	83 ec 0c             	sub    $0xc,%esp
  801175:	ff 75 18             	pushl  0x18(%ebp)
  801178:	83 eb 01             	sub    $0x1,%ebx
  80117b:	53                   	push   %ebx
  80117c:	50                   	push   %eax
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	ff 75 e4             	pushl  -0x1c(%ebp)
  801183:	ff 75 e0             	pushl  -0x20(%ebp)
  801186:	ff 75 dc             	pushl  -0x24(%ebp)
  801189:	ff 75 d8             	pushl  -0x28(%ebp)
  80118c:	e8 cf 09 00 00       	call   801b60 <__udivdi3>
  801191:	83 c4 18             	add    $0x18,%esp
  801194:	52                   	push   %edx
  801195:	50                   	push   %eax
  801196:	89 f2                	mov    %esi,%edx
  801198:	89 f8                	mov    %edi,%eax
  80119a:	e8 9f ff ff ff       	call   80113e <printnum>
  80119f:	83 c4 20             	add    $0x20,%esp
  8011a2:	eb 13                	jmp    8011b7 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011a4:	83 ec 08             	sub    $0x8,%esp
  8011a7:	56                   	push   %esi
  8011a8:	ff 75 18             	pushl  0x18(%ebp)
  8011ab:	ff d7                	call   *%edi
  8011ad:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011b0:	83 eb 01             	sub    $0x1,%ebx
  8011b3:	85 db                	test   %ebx,%ebx
  8011b5:	7f ed                	jg     8011a4 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b7:	83 ec 08             	sub    $0x8,%esp
  8011ba:	56                   	push   %esi
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ca:	e8 a1 0a 00 00       	call   801c70 <__umoddi3>
  8011cf:	83 c4 14             	add    $0x14,%esp
  8011d2:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  8011d9:	50                   	push   %eax
  8011da:	ff d7                	call   *%edi
}
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8011e7:	83 fa 01             	cmp    $0x1,%edx
  8011ea:	7f 13                	jg     8011ff <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8011ec:	85 d2                	test   %edx,%edx
  8011ee:	74 1c                	je     80120c <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8011f0:	8b 10                	mov    (%eax),%edx
  8011f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f5:	89 08                	mov    %ecx,(%eax)
  8011f7:	8b 02                	mov    (%edx),%eax
  8011f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fe:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8011ff:	8b 10                	mov    (%eax),%edx
  801201:	8d 4a 08             	lea    0x8(%edx),%ecx
  801204:	89 08                	mov    %ecx,(%eax)
  801206:	8b 02                	mov    (%edx),%eax
  801208:	8b 52 04             	mov    0x4(%edx),%edx
  80120b:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80120c:	8b 10                	mov    (%eax),%edx
  80120e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801211:	89 08                	mov    %ecx,(%eax)
  801213:	8b 02                	mov    (%edx),%eax
  801215:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80121a:	c3                   	ret    

0080121b <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80121b:	83 fa 01             	cmp    $0x1,%edx
  80121e:	7f 0f                	jg     80122f <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801220:	85 d2                	test   %edx,%edx
  801222:	74 18                	je     80123c <getint+0x21>
		return va_arg(*ap, long);
  801224:	8b 10                	mov    (%eax),%edx
  801226:	8d 4a 04             	lea    0x4(%edx),%ecx
  801229:	89 08                	mov    %ecx,(%eax)
  80122b:	8b 02                	mov    (%edx),%eax
  80122d:	99                   	cltd   
  80122e:	c3                   	ret    
		return va_arg(*ap, long long);
  80122f:	8b 10                	mov    (%eax),%edx
  801231:	8d 4a 08             	lea    0x8(%edx),%ecx
  801234:	89 08                	mov    %ecx,(%eax)
  801236:	8b 02                	mov    (%edx),%eax
  801238:	8b 52 04             	mov    0x4(%edx),%edx
  80123b:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80123c:	8b 10                	mov    (%eax),%edx
  80123e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801241:	89 08                	mov    %ecx,(%eax)
  801243:	8b 02                	mov    (%edx),%eax
  801245:	99                   	cltd   
}
  801246:	c3                   	ret    

00801247 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801247:	f3 0f 1e fb          	endbr32 
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801251:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801255:	8b 10                	mov    (%eax),%edx
  801257:	3b 50 04             	cmp    0x4(%eax),%edx
  80125a:	73 0a                	jae    801266 <sprintputch+0x1f>
		*b->buf++ = ch;
  80125c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80125f:	89 08                	mov    %ecx,(%eax)
  801261:	8b 45 08             	mov    0x8(%ebp),%eax
  801264:	88 02                	mov    %al,(%edx)
}
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <printfmt>:
{
  801268:	f3 0f 1e fb          	endbr32 
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801272:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801275:	50                   	push   %eax
  801276:	ff 75 10             	pushl  0x10(%ebp)
  801279:	ff 75 0c             	pushl  0xc(%ebp)
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 05 00 00 00       	call   801289 <vprintfmt>
}
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <vprintfmt>:
{
  801289:	f3 0f 1e fb          	endbr32 
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	57                   	push   %edi
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
  801293:	83 ec 2c             	sub    $0x2c,%esp
  801296:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801299:	8b 75 0c             	mov    0xc(%ebp),%esi
  80129c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80129f:	e9 86 02 00 00       	jmp    80152a <vprintfmt+0x2a1>
		padc = ' ';
  8012a4:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012a8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012af:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012b6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012bd:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012c2:	8d 47 01             	lea    0x1(%edi),%eax
  8012c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c8:	0f b6 17             	movzbl (%edi),%edx
  8012cb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012ce:	3c 55                	cmp    $0x55,%al
  8012d0:	0f 87 df 02 00 00    	ja     8015b5 <vprintfmt+0x32c>
  8012d6:	0f b6 c0             	movzbl %al,%eax
  8012d9:	3e ff 24 85 40 20 80 	notrack jmp *0x802040(,%eax,4)
  8012e0:	00 
  8012e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012e4:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8012e8:	eb d8                	jmp    8012c2 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8012ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ed:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8012f1:	eb cf                	jmp    8012c2 <vprintfmt+0x39>
  8012f3:	0f b6 d2             	movzbl %dl,%edx
  8012f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8012f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801301:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801304:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801308:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80130b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80130e:	83 f9 09             	cmp    $0x9,%ecx
  801311:	77 52                	ja     801365 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801313:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801316:	eb e9                	jmp    801301 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801318:	8b 45 14             	mov    0x14(%ebp),%eax
  80131b:	8d 50 04             	lea    0x4(%eax),%edx
  80131e:	89 55 14             	mov    %edx,0x14(%ebp)
  801321:	8b 00                	mov    (%eax),%eax
  801323:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801329:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80132d:	79 93                	jns    8012c2 <vprintfmt+0x39>
				width = precision, precision = -1;
  80132f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801332:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801335:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80133c:	eb 84                	jmp    8012c2 <vprintfmt+0x39>
  80133e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801341:	85 c0                	test   %eax,%eax
  801343:	ba 00 00 00 00       	mov    $0x0,%edx
  801348:	0f 49 d0             	cmovns %eax,%edx
  80134b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80134e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801351:	e9 6c ff ff ff       	jmp    8012c2 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801359:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801360:	e9 5d ff ff ff       	jmp    8012c2 <vprintfmt+0x39>
  801365:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801368:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80136b:	eb bc                	jmp    801329 <vprintfmt+0xa0>
			lflag++;
  80136d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801373:	e9 4a ff ff ff       	jmp    8012c2 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801378:	8b 45 14             	mov    0x14(%ebp),%eax
  80137b:	8d 50 04             	lea    0x4(%eax),%edx
  80137e:	89 55 14             	mov    %edx,0x14(%ebp)
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	56                   	push   %esi
  801385:	ff 30                	pushl  (%eax)
  801387:	ff d3                	call   *%ebx
			break;
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	e9 96 01 00 00       	jmp    801527 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  801391:	8b 45 14             	mov    0x14(%ebp),%eax
  801394:	8d 50 04             	lea    0x4(%eax),%edx
  801397:	89 55 14             	mov    %edx,0x14(%ebp)
  80139a:	8b 00                	mov    (%eax),%eax
  80139c:	99                   	cltd   
  80139d:	31 d0                	xor    %edx,%eax
  80139f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a1:	83 f8 0f             	cmp    $0xf,%eax
  8013a4:	7f 20                	jg     8013c6 <vprintfmt+0x13d>
  8013a6:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8013ad:	85 d2                	test   %edx,%edx
  8013af:	74 15                	je     8013c6 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013b1:	52                   	push   %edx
  8013b2:	68 9d 1e 80 00       	push   $0x801e9d
  8013b7:	56                   	push   %esi
  8013b8:	53                   	push   %ebx
  8013b9:	e8 aa fe ff ff       	call   801268 <printfmt>
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	e9 61 01 00 00       	jmp    801527 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013c6:	50                   	push   %eax
  8013c7:	68 1f 1f 80 00       	push   $0x801f1f
  8013cc:	56                   	push   %esi
  8013cd:	53                   	push   %ebx
  8013ce:	e8 95 fe ff ff       	call   801268 <printfmt>
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	e9 4c 01 00 00       	jmp    801527 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8013db:	8b 45 14             	mov    0x14(%ebp),%eax
  8013de:	8d 50 04             	lea    0x4(%eax),%edx
  8013e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e4:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8013e6:	85 c9                	test   %ecx,%ecx
  8013e8:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  8013ed:	0f 45 c1             	cmovne %ecx,%eax
  8013f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8013f3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013f7:	7e 06                	jle    8013ff <vprintfmt+0x176>
  8013f9:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8013fd:	75 0d                	jne    80140c <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801402:	89 c7                	mov    %eax,%edi
  801404:	03 45 e0             	add    -0x20(%ebp),%eax
  801407:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80140a:	eb 57                	jmp    801463 <vprintfmt+0x1da>
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	ff 75 d8             	pushl  -0x28(%ebp)
  801412:	ff 75 cc             	pushl  -0x34(%ebp)
  801415:	e8 4f 02 00 00       	call   801669 <strnlen>
  80141a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80141d:	29 c2                	sub    %eax,%edx
  80141f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801422:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801425:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801429:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80142c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80142e:	85 db                	test   %ebx,%ebx
  801430:	7e 10                	jle    801442 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801432:	83 ec 08             	sub    $0x8,%esp
  801435:	56                   	push   %esi
  801436:	57                   	push   %edi
  801437:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80143a:	83 eb 01             	sub    $0x1,%ebx
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	eb ec                	jmp    80142e <vprintfmt+0x1a5>
  801442:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801445:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801448:	85 d2                	test   %edx,%edx
  80144a:	b8 00 00 00 00       	mov    $0x0,%eax
  80144f:	0f 49 c2             	cmovns %edx,%eax
  801452:	29 c2                	sub    %eax,%edx
  801454:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801457:	eb a6                	jmp    8013ff <vprintfmt+0x176>
					putch(ch, putdat);
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	56                   	push   %esi
  80145d:	52                   	push   %edx
  80145e:	ff d3                	call   *%ebx
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801466:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801468:	83 c7 01             	add    $0x1,%edi
  80146b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80146f:	0f be d0             	movsbl %al,%edx
  801472:	85 d2                	test   %edx,%edx
  801474:	74 42                	je     8014b8 <vprintfmt+0x22f>
  801476:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80147a:	78 06                	js     801482 <vprintfmt+0x1f9>
  80147c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801480:	78 1e                	js     8014a0 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  801482:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801486:	74 d1                	je     801459 <vprintfmt+0x1d0>
  801488:	0f be c0             	movsbl %al,%eax
  80148b:	83 e8 20             	sub    $0x20,%eax
  80148e:	83 f8 5e             	cmp    $0x5e,%eax
  801491:	76 c6                	jbe    801459 <vprintfmt+0x1d0>
					putch('?', putdat);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	56                   	push   %esi
  801497:	6a 3f                	push   $0x3f
  801499:	ff d3                	call   *%ebx
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	eb c3                	jmp    801463 <vprintfmt+0x1da>
  8014a0:	89 cf                	mov    %ecx,%edi
  8014a2:	eb 0e                	jmp    8014b2 <vprintfmt+0x229>
				putch(' ', putdat);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	56                   	push   %esi
  8014a8:	6a 20                	push   $0x20
  8014aa:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014ac:	83 ef 01             	sub    $0x1,%edi
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	85 ff                	test   %edi,%edi
  8014b4:	7f ee                	jg     8014a4 <vprintfmt+0x21b>
  8014b6:	eb 6f                	jmp    801527 <vprintfmt+0x29e>
  8014b8:	89 cf                	mov    %ecx,%edi
  8014ba:	eb f6                	jmp    8014b2 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014bc:	89 ca                	mov    %ecx,%edx
  8014be:	8d 45 14             	lea    0x14(%ebp),%eax
  8014c1:	e8 55 fd ff ff       	call   80121b <getint>
  8014c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014cc:	85 d2                	test   %edx,%edx
  8014ce:	78 0b                	js     8014db <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014d0:	89 d1                	mov    %edx,%ecx
  8014d2:	89 c2                	mov    %eax,%edx
			base = 10;
  8014d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014d9:	eb 32                	jmp    80150d <vprintfmt+0x284>
				putch('-', putdat);
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	56                   	push   %esi
  8014df:	6a 2d                	push   $0x2d
  8014e1:	ff d3                	call   *%ebx
				num = -(long long) num;
  8014e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014e6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014e9:	f7 da                	neg    %edx
  8014eb:	83 d1 00             	adc    $0x0,%ecx
  8014ee:	f7 d9                	neg    %ecx
  8014f0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f8:	eb 13                	jmp    80150d <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8014fa:	89 ca                	mov    %ecx,%edx
  8014fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8014ff:	e8 e3 fc ff ff       	call   8011e7 <getuint>
  801504:	89 d1                	mov    %edx,%ecx
  801506:	89 c2                	mov    %eax,%edx
			base = 10;
  801508:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801514:	57                   	push   %edi
  801515:	ff 75 e0             	pushl  -0x20(%ebp)
  801518:	50                   	push   %eax
  801519:	51                   	push   %ecx
  80151a:	52                   	push   %edx
  80151b:	89 f2                	mov    %esi,%edx
  80151d:	89 d8                	mov    %ebx,%eax
  80151f:	e8 1a fc ff ff       	call   80113e <printnum>
			break;
  801524:	83 c4 20             	add    $0x20,%esp
{
  801527:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80152a:	83 c7 01             	add    $0x1,%edi
  80152d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801531:	83 f8 25             	cmp    $0x25,%eax
  801534:	0f 84 6a fd ff ff    	je     8012a4 <vprintfmt+0x1b>
			if (ch == '\0')
  80153a:	85 c0                	test   %eax,%eax
  80153c:	0f 84 93 00 00 00    	je     8015d5 <vprintfmt+0x34c>
			putch(ch, putdat);
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	56                   	push   %esi
  801546:	50                   	push   %eax
  801547:	ff d3                	call   *%ebx
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	eb dc                	jmp    80152a <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80154e:	89 ca                	mov    %ecx,%edx
  801550:	8d 45 14             	lea    0x14(%ebp),%eax
  801553:	e8 8f fc ff ff       	call   8011e7 <getuint>
  801558:	89 d1                	mov    %edx,%ecx
  80155a:	89 c2                	mov    %eax,%edx
			base = 8;
  80155c:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801561:	eb aa                	jmp    80150d <vprintfmt+0x284>
			putch('0', putdat);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	56                   	push   %esi
  801567:	6a 30                	push   $0x30
  801569:	ff d3                	call   *%ebx
			putch('x', putdat);
  80156b:	83 c4 08             	add    $0x8,%esp
  80156e:	56                   	push   %esi
  80156f:	6a 78                	push   $0x78
  801571:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  801573:	8b 45 14             	mov    0x14(%ebp),%eax
  801576:	8d 50 04             	lea    0x4(%eax),%edx
  801579:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80157c:	8b 10                	mov    (%eax),%edx
  80157e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801583:	83 c4 10             	add    $0x10,%esp
			base = 16;
  801586:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80158b:	eb 80                	jmp    80150d <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80158d:	89 ca                	mov    %ecx,%edx
  80158f:	8d 45 14             	lea    0x14(%ebp),%eax
  801592:	e8 50 fc ff ff       	call   8011e7 <getuint>
  801597:	89 d1                	mov    %edx,%ecx
  801599:	89 c2                	mov    %eax,%edx
			base = 16;
  80159b:	b8 10 00 00 00       	mov    $0x10,%eax
  8015a0:	e9 68 ff ff ff       	jmp    80150d <vprintfmt+0x284>
			putch(ch, putdat);
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	56                   	push   %esi
  8015a9:	6a 25                	push   $0x25
  8015ab:	ff d3                	call   *%ebx
			break;
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	e9 72 ff ff ff       	jmp    801527 <vprintfmt+0x29e>
			putch('%', putdat);
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	56                   	push   %esi
  8015b9:	6a 25                	push   $0x25
  8015bb:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	89 f8                	mov    %edi,%eax
  8015c2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015c6:	74 05                	je     8015cd <vprintfmt+0x344>
  8015c8:	83 e8 01             	sub    $0x1,%eax
  8015cb:	eb f5                	jmp    8015c2 <vprintfmt+0x339>
  8015cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015d0:	e9 52 ff ff ff       	jmp    801527 <vprintfmt+0x29e>
}
  8015d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5e                   	pop    %esi
  8015da:	5f                   	pop    %edi
  8015db:	5d                   	pop    %ebp
  8015dc:	c3                   	ret    

008015dd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015dd:	f3 0f 1e fb          	endbr32 
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 18             	sub    $0x18,%esp
  8015e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015fe:	85 c0                	test   %eax,%eax
  801600:	74 26                	je     801628 <vsnprintf+0x4b>
  801602:	85 d2                	test   %edx,%edx
  801604:	7e 22                	jle    801628 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801606:	ff 75 14             	pushl  0x14(%ebp)
  801609:	ff 75 10             	pushl  0x10(%ebp)
  80160c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	68 47 12 80 00       	push   $0x801247
  801615:	e8 6f fc ff ff       	call   801289 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80161a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80161d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801620:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801623:	83 c4 10             	add    $0x10,%esp
}
  801626:	c9                   	leave  
  801627:	c3                   	ret    
		return -E_INVAL;
  801628:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80162d:	eb f7                	jmp    801626 <vsnprintf+0x49>

0080162f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80162f:	f3 0f 1e fb          	endbr32 
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801639:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80163c:	50                   	push   %eax
  80163d:	ff 75 10             	pushl  0x10(%ebp)
  801640:	ff 75 0c             	pushl  0xc(%ebp)
  801643:	ff 75 08             	pushl  0x8(%ebp)
  801646:	e8 92 ff ff ff       	call   8015dd <vsnprintf>
	va_end(ap);

	return rc;
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80164d:	f3 0f 1e fb          	endbr32 
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801657:	b8 00 00 00 00       	mov    $0x0,%eax
  80165c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801660:	74 05                	je     801667 <strlen+0x1a>
		n++;
  801662:	83 c0 01             	add    $0x1,%eax
  801665:	eb f5                	jmp    80165c <strlen+0xf>
	return n;
}
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801669:	f3 0f 1e fb          	endbr32 
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801673:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801676:	b8 00 00 00 00       	mov    $0x0,%eax
  80167b:	39 d0                	cmp    %edx,%eax
  80167d:	74 0d                	je     80168c <strnlen+0x23>
  80167f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801683:	74 05                	je     80168a <strnlen+0x21>
		n++;
  801685:	83 c0 01             	add    $0x1,%eax
  801688:	eb f1                	jmp    80167b <strnlen+0x12>
  80168a:	89 c2                	mov    %eax,%edx
	return n;
}
  80168c:	89 d0                	mov    %edx,%eax
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801690:	f3 0f 1e fb          	endbr32 
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	53                   	push   %ebx
  801698:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80169e:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a3:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016a7:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016aa:	83 c0 01             	add    $0x1,%eax
  8016ad:	84 d2                	test   %dl,%dl
  8016af:	75 f2                	jne    8016a3 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016b1:	89 c8                	mov    %ecx,%eax
  8016b3:	5b                   	pop    %ebx
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016b6:	f3 0f 1e fb          	endbr32 
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 10             	sub    $0x10,%esp
  8016c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016c4:	53                   	push   %ebx
  8016c5:	e8 83 ff ff ff       	call   80164d <strlen>
  8016ca:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016cd:	ff 75 0c             	pushl  0xc(%ebp)
  8016d0:	01 d8                	add    %ebx,%eax
  8016d2:	50                   	push   %eax
  8016d3:	e8 b8 ff ff ff       	call   801690 <strcpy>
	return dst;
}
  8016d8:	89 d8                	mov    %ebx,%eax
  8016da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016df:	f3 0f 1e fb          	endbr32 
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ee:	89 f3                	mov    %esi,%ebx
  8016f0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f3:	89 f0                	mov    %esi,%eax
  8016f5:	39 d8                	cmp    %ebx,%eax
  8016f7:	74 11                	je     80170a <strncpy+0x2b>
		*dst++ = *src;
  8016f9:	83 c0 01             	add    $0x1,%eax
  8016fc:	0f b6 0a             	movzbl (%edx),%ecx
  8016ff:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801702:	80 f9 01             	cmp    $0x1,%cl
  801705:	83 da ff             	sbb    $0xffffffff,%edx
  801708:	eb eb                	jmp    8016f5 <strncpy+0x16>
	}
	return ret;
}
  80170a:	89 f0                	mov    %esi,%eax
  80170c:	5b                   	pop    %ebx
  80170d:	5e                   	pop    %esi
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801710:	f3 0f 1e fb          	endbr32 
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	56                   	push   %esi
  801718:	53                   	push   %ebx
  801719:	8b 75 08             	mov    0x8(%ebp),%esi
  80171c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171f:	8b 55 10             	mov    0x10(%ebp),%edx
  801722:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801724:	85 d2                	test   %edx,%edx
  801726:	74 21                	je     801749 <strlcpy+0x39>
  801728:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80172c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80172e:	39 c2                	cmp    %eax,%edx
  801730:	74 14                	je     801746 <strlcpy+0x36>
  801732:	0f b6 19             	movzbl (%ecx),%ebx
  801735:	84 db                	test   %bl,%bl
  801737:	74 0b                	je     801744 <strlcpy+0x34>
			*dst++ = *src++;
  801739:	83 c1 01             	add    $0x1,%ecx
  80173c:	83 c2 01             	add    $0x1,%edx
  80173f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801742:	eb ea                	jmp    80172e <strlcpy+0x1e>
  801744:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801746:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801749:	29 f0                	sub    %esi,%eax
}
  80174b:	5b                   	pop    %ebx
  80174c:	5e                   	pop    %esi
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80174f:	f3 0f 1e fb          	endbr32 
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801759:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80175c:	0f b6 01             	movzbl (%ecx),%eax
  80175f:	84 c0                	test   %al,%al
  801761:	74 0c                	je     80176f <strcmp+0x20>
  801763:	3a 02                	cmp    (%edx),%al
  801765:	75 08                	jne    80176f <strcmp+0x20>
		p++, q++;
  801767:	83 c1 01             	add    $0x1,%ecx
  80176a:	83 c2 01             	add    $0x1,%edx
  80176d:	eb ed                	jmp    80175c <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80176f:	0f b6 c0             	movzbl %al,%eax
  801772:	0f b6 12             	movzbl (%edx),%edx
  801775:	29 d0                	sub    %edx,%eax
}
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801779:	f3 0f 1e fb          	endbr32 
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	53                   	push   %ebx
  801781:	8b 45 08             	mov    0x8(%ebp),%eax
  801784:	8b 55 0c             	mov    0xc(%ebp),%edx
  801787:	89 c3                	mov    %eax,%ebx
  801789:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80178c:	eb 06                	jmp    801794 <strncmp+0x1b>
		n--, p++, q++;
  80178e:	83 c0 01             	add    $0x1,%eax
  801791:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801794:	39 d8                	cmp    %ebx,%eax
  801796:	74 16                	je     8017ae <strncmp+0x35>
  801798:	0f b6 08             	movzbl (%eax),%ecx
  80179b:	84 c9                	test   %cl,%cl
  80179d:	74 04                	je     8017a3 <strncmp+0x2a>
  80179f:	3a 0a                	cmp    (%edx),%cl
  8017a1:	74 eb                	je     80178e <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a3:	0f b6 00             	movzbl (%eax),%eax
  8017a6:	0f b6 12             	movzbl (%edx),%edx
  8017a9:	29 d0                	sub    %edx,%eax
}
  8017ab:	5b                   	pop    %ebx
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    
		return 0;
  8017ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b3:	eb f6                	jmp    8017ab <strncmp+0x32>

008017b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017b5:	f3 0f 1e fb          	endbr32 
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c3:	0f b6 10             	movzbl (%eax),%edx
  8017c6:	84 d2                	test   %dl,%dl
  8017c8:	74 09                	je     8017d3 <strchr+0x1e>
		if (*s == c)
  8017ca:	38 ca                	cmp    %cl,%dl
  8017cc:	74 0a                	je     8017d8 <strchr+0x23>
	for (; *s; s++)
  8017ce:	83 c0 01             	add    $0x1,%eax
  8017d1:	eb f0                	jmp    8017c3 <strchr+0xe>
			return (char *) s;
	return 0;
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017da:	f3 0f 1e fb          	endbr32 
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017eb:	38 ca                	cmp    %cl,%dl
  8017ed:	74 09                	je     8017f8 <strfind+0x1e>
  8017ef:	84 d2                	test   %dl,%dl
  8017f1:	74 05                	je     8017f8 <strfind+0x1e>
	for (; *s; s++)
  8017f3:	83 c0 01             	add    $0x1,%eax
  8017f6:	eb f0                	jmp    8017e8 <strfind+0xe>
			break;
	return (char *) s;
}
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017fa:	f3 0f 1e fb          	endbr32 
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	57                   	push   %edi
  801802:	56                   	push   %esi
  801803:	53                   	push   %ebx
  801804:	8b 55 08             	mov    0x8(%ebp),%edx
  801807:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80180a:	85 c9                	test   %ecx,%ecx
  80180c:	74 33                	je     801841 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180e:	89 d0                	mov    %edx,%eax
  801810:	09 c8                	or     %ecx,%eax
  801812:	a8 03                	test   $0x3,%al
  801814:	75 23                	jne    801839 <memset+0x3f>
		c &= 0xFF;
  801816:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181a:	89 d8                	mov    %ebx,%eax
  80181c:	c1 e0 08             	shl    $0x8,%eax
  80181f:	89 df                	mov    %ebx,%edi
  801821:	c1 e7 18             	shl    $0x18,%edi
  801824:	89 de                	mov    %ebx,%esi
  801826:	c1 e6 10             	shl    $0x10,%esi
  801829:	09 f7                	or     %esi,%edi
  80182b:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  80182d:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801830:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801832:	89 d7                	mov    %edx,%edi
  801834:	fc                   	cld    
  801835:	f3 ab                	rep stos %eax,%es:(%edi)
  801837:	eb 08                	jmp    801841 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801839:	89 d7                	mov    %edx,%edi
  80183b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183e:	fc                   	cld    
  80183f:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801841:	89 d0                	mov    %edx,%eax
  801843:	5b                   	pop    %ebx
  801844:	5e                   	pop    %esi
  801845:	5f                   	pop    %edi
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801848:	f3 0f 1e fb          	endbr32 
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	57                   	push   %edi
  801850:	56                   	push   %esi
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	8b 75 0c             	mov    0xc(%ebp),%esi
  801857:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80185a:	39 c6                	cmp    %eax,%esi
  80185c:	73 32                	jae    801890 <memmove+0x48>
  80185e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801861:	39 c2                	cmp    %eax,%edx
  801863:	76 2b                	jbe    801890 <memmove+0x48>
		s += n;
		d += n;
  801865:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801868:	89 fe                	mov    %edi,%esi
  80186a:	09 ce                	or     %ecx,%esi
  80186c:	09 d6                	or     %edx,%esi
  80186e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801874:	75 0e                	jne    801884 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801876:	83 ef 04             	sub    $0x4,%edi
  801879:	8d 72 fc             	lea    -0x4(%edx),%esi
  80187c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80187f:	fd                   	std    
  801880:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801882:	eb 09                	jmp    80188d <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801884:	83 ef 01             	sub    $0x1,%edi
  801887:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80188a:	fd                   	std    
  80188b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80188d:	fc                   	cld    
  80188e:	eb 1a                	jmp    8018aa <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801890:	89 c2                	mov    %eax,%edx
  801892:	09 ca                	or     %ecx,%edx
  801894:	09 f2                	or     %esi,%edx
  801896:	f6 c2 03             	test   $0x3,%dl
  801899:	75 0a                	jne    8018a5 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80189b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80189e:	89 c7                	mov    %eax,%edi
  8018a0:	fc                   	cld    
  8018a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a3:	eb 05                	jmp    8018aa <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018a5:	89 c7                	mov    %eax,%edi
  8018a7:	fc                   	cld    
  8018a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018aa:	5e                   	pop    %esi
  8018ab:	5f                   	pop    %edi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ae:	f3 0f 1e fb          	endbr32 
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018b8:	ff 75 10             	pushl  0x10(%ebp)
  8018bb:	ff 75 0c             	pushl  0xc(%ebp)
  8018be:	ff 75 08             	pushl  0x8(%ebp)
  8018c1:	e8 82 ff ff ff       	call   801848 <memmove>
}
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c8:	f3 0f 1e fb          	endbr32 
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d7:	89 c6                	mov    %eax,%esi
  8018d9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018dc:	39 f0                	cmp    %esi,%eax
  8018de:	74 1c                	je     8018fc <memcmp+0x34>
		if (*s1 != *s2)
  8018e0:	0f b6 08             	movzbl (%eax),%ecx
  8018e3:	0f b6 1a             	movzbl (%edx),%ebx
  8018e6:	38 d9                	cmp    %bl,%cl
  8018e8:	75 08                	jne    8018f2 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018ea:	83 c0 01             	add    $0x1,%eax
  8018ed:	83 c2 01             	add    $0x1,%edx
  8018f0:	eb ea                	jmp    8018dc <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8018f2:	0f b6 c1             	movzbl %cl,%eax
  8018f5:	0f b6 db             	movzbl %bl,%ebx
  8018f8:	29 d8                	sub    %ebx,%eax
  8018fa:	eb 05                	jmp    801901 <memcmp+0x39>
	}

	return 0;
  8018fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801901:	5b                   	pop    %ebx
  801902:	5e                   	pop    %esi
  801903:	5d                   	pop    %ebp
  801904:	c3                   	ret    

00801905 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801905:	f3 0f 1e fb          	endbr32 
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801912:	89 c2                	mov    %eax,%edx
  801914:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801917:	39 d0                	cmp    %edx,%eax
  801919:	73 09                	jae    801924 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  80191b:	38 08                	cmp    %cl,(%eax)
  80191d:	74 05                	je     801924 <memfind+0x1f>
	for (; s < ends; s++)
  80191f:	83 c0 01             	add    $0x1,%eax
  801922:	eb f3                	jmp    801917 <memfind+0x12>
			break;
	return (void *) s;
}
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801926:	f3 0f 1e fb          	endbr32 
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	57                   	push   %edi
  80192e:	56                   	push   %esi
  80192f:	53                   	push   %ebx
  801930:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801933:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801936:	eb 03                	jmp    80193b <strtol+0x15>
		s++;
  801938:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80193b:	0f b6 01             	movzbl (%ecx),%eax
  80193e:	3c 20                	cmp    $0x20,%al
  801940:	74 f6                	je     801938 <strtol+0x12>
  801942:	3c 09                	cmp    $0x9,%al
  801944:	74 f2                	je     801938 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801946:	3c 2b                	cmp    $0x2b,%al
  801948:	74 2a                	je     801974 <strtol+0x4e>
	int neg = 0;
  80194a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80194f:	3c 2d                	cmp    $0x2d,%al
  801951:	74 2b                	je     80197e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801953:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801959:	75 0f                	jne    80196a <strtol+0x44>
  80195b:	80 39 30             	cmpb   $0x30,(%ecx)
  80195e:	74 28                	je     801988 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801960:	85 db                	test   %ebx,%ebx
  801962:	b8 0a 00 00 00       	mov    $0xa,%eax
  801967:	0f 44 d8             	cmove  %eax,%ebx
  80196a:	b8 00 00 00 00       	mov    $0x0,%eax
  80196f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801972:	eb 46                	jmp    8019ba <strtol+0x94>
		s++;
  801974:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801977:	bf 00 00 00 00       	mov    $0x0,%edi
  80197c:	eb d5                	jmp    801953 <strtol+0x2d>
		s++, neg = 1;
  80197e:	83 c1 01             	add    $0x1,%ecx
  801981:	bf 01 00 00 00       	mov    $0x1,%edi
  801986:	eb cb                	jmp    801953 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801988:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80198c:	74 0e                	je     80199c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80198e:	85 db                	test   %ebx,%ebx
  801990:	75 d8                	jne    80196a <strtol+0x44>
		s++, base = 8;
  801992:	83 c1 01             	add    $0x1,%ecx
  801995:	bb 08 00 00 00       	mov    $0x8,%ebx
  80199a:	eb ce                	jmp    80196a <strtol+0x44>
		s += 2, base = 16;
  80199c:	83 c1 02             	add    $0x2,%ecx
  80199f:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a4:	eb c4                	jmp    80196a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019a6:	0f be d2             	movsbl %dl,%edx
  8019a9:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019ac:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019af:	7d 3a                	jge    8019eb <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019b1:	83 c1 01             	add    $0x1,%ecx
  8019b4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019b8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019ba:	0f b6 11             	movzbl (%ecx),%edx
  8019bd:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c0:	89 f3                	mov    %esi,%ebx
  8019c2:	80 fb 09             	cmp    $0x9,%bl
  8019c5:	76 df                	jbe    8019a6 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019c7:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ca:	89 f3                	mov    %esi,%ebx
  8019cc:	80 fb 19             	cmp    $0x19,%bl
  8019cf:	77 08                	ja     8019d9 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019d1:	0f be d2             	movsbl %dl,%edx
  8019d4:	83 ea 57             	sub    $0x57,%edx
  8019d7:	eb d3                	jmp    8019ac <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8019d9:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019dc:	89 f3                	mov    %esi,%ebx
  8019de:	80 fb 19             	cmp    $0x19,%bl
  8019e1:	77 08                	ja     8019eb <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019e3:	0f be d2             	movsbl %dl,%edx
  8019e6:	83 ea 37             	sub    $0x37,%edx
  8019e9:	eb c1                	jmp    8019ac <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019ef:	74 05                	je     8019f6 <strtol+0xd0>
		*endptr = (char *) s;
  8019f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019f4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019f6:	89 c2                	mov    %eax,%edx
  8019f8:	f7 da                	neg    %edx
  8019fa:	85 ff                	test   %edi,%edi
  8019fc:	0f 45 c2             	cmovne %edx,%eax
}
  8019ff:	5b                   	pop    %ebx
  801a00:	5e                   	pop    %esi
  801a01:	5f                   	pop    %edi
  801a02:	5d                   	pop    %ebp
  801a03:	c3                   	ret    

00801a04 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a04:	f3 0f 1e fb          	endbr32 
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801a16:	85 c0                	test   %eax,%eax
  801a18:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a1d:	0f 44 c2             	cmove  %edx,%eax
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	50                   	push   %eax
  801a24:	e8 a7 e8 ff ff       	call   8002d0 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	85 f6                	test   %esi,%esi
  801a2e:	74 15                	je     801a45 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801a30:	ba 00 00 00 00       	mov    $0x0,%edx
  801a35:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a38:	74 09                	je     801a43 <ipc_recv+0x3f>
  801a3a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a40:	8b 52 74             	mov    0x74(%edx),%edx
  801a43:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801a45:	85 db                	test   %ebx,%ebx
  801a47:	74 15                	je     801a5e <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801a49:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4e:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a51:	74 09                	je     801a5c <ipc_recv+0x58>
  801a53:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a59:	8b 52 78             	mov    0x78(%edx),%edx
  801a5c:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801a5e:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a61:	74 08                	je     801a6b <ipc_recv+0x67>
  801a63:	a1 04 40 80 00       	mov    0x804004,%eax
  801a68:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6e:	5b                   	pop    %ebx
  801a6f:	5e                   	pop    %esi
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    

00801a72 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a72:	f3 0f 1e fb          	endbr32 
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	57                   	push   %edi
  801a7a:	56                   	push   %esi
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a82:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a88:	eb 1f                	jmp    801aa9 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801a8a:	6a 00                	push   $0x0
  801a8c:	68 00 00 c0 ee       	push   $0xeec00000
  801a91:	56                   	push   %esi
  801a92:	57                   	push   %edi
  801a93:	e8 0f e8 ff ff       	call   8002a7 <sys_ipc_try_send>
  801a98:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	74 30                	je     801acf <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801a9f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa2:	75 19                	jne    801abd <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801aa4:	e8 e5 e6 ff ff       	call   80018e <sys_yield>
		if (pg != NULL) {
  801aa9:	85 db                	test   %ebx,%ebx
  801aab:	74 dd                	je     801a8a <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801aad:	ff 75 14             	pushl  0x14(%ebp)
  801ab0:	53                   	push   %ebx
  801ab1:	56                   	push   %esi
  801ab2:	57                   	push   %edi
  801ab3:	e8 ef e7 ff ff       	call   8002a7 <sys_ipc_try_send>
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	eb de                	jmp    801a9b <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801abd:	50                   	push   %eax
  801abe:	68 ff 21 80 00       	push   $0x8021ff
  801ac3:	6a 3e                	push   $0x3e
  801ac5:	68 0c 22 80 00       	push   $0x80220c
  801aca:	e8 70 f5 ff ff       	call   80103f <_panic>
	}
}
  801acf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad2:	5b                   	pop    %ebx
  801ad3:	5e                   	pop    %esi
  801ad4:	5f                   	pop    %edi
  801ad5:	5d                   	pop    %ebp
  801ad6:	c3                   	ret    

00801ad7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad7:	f3 0f 1e fb          	endbr32 
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ae1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ae6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ae9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aef:	8b 52 50             	mov    0x50(%edx),%edx
  801af2:	39 ca                	cmp    %ecx,%edx
  801af4:	74 11                	je     801b07 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801af6:	83 c0 01             	add    $0x1,%eax
  801af9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801afe:	75 e6                	jne    801ae6 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b00:	b8 00 00 00 00       	mov    $0x0,%eax
  801b05:	eb 0b                	jmp    801b12 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b07:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b0a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b0f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b14:	f3 0f 1e fb          	endbr32 
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1e:	89 c2                	mov    %eax,%edx
  801b20:	c1 ea 16             	shr    $0x16,%edx
  801b23:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b2a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b2f:	f6 c1 01             	test   $0x1,%cl
  801b32:	74 1c                	je     801b50 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b34:	c1 e8 0c             	shr    $0xc,%eax
  801b37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b3e:	a8 01                	test   $0x1,%al
  801b40:	74 0e                	je     801b50 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b42:	c1 e8 0c             	shr    $0xc,%eax
  801b45:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b4c:	ef 
  801b4d:	0f b7 d2             	movzwl %dx,%edx
}
  801b50:	89 d0                	mov    %edx,%eax
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    
  801b54:	66 90                	xchg   %ax,%ax
  801b56:	66 90                	xchg   %ax,%ax
  801b58:	66 90                	xchg   %ax,%ax
  801b5a:	66 90                	xchg   %ax,%ax
  801b5c:	66 90                	xchg   %ax,%ax
  801b5e:	66 90                	xchg   %ax,%ax

00801b60 <__udivdi3>:
  801b60:	f3 0f 1e fb          	endbr32 
  801b64:	55                   	push   %ebp
  801b65:	57                   	push   %edi
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	83 ec 1c             	sub    $0x1c,%esp
  801b6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b73:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b7b:	85 d2                	test   %edx,%edx
  801b7d:	75 19                	jne    801b98 <__udivdi3+0x38>
  801b7f:	39 f3                	cmp    %esi,%ebx
  801b81:	76 4d                	jbe    801bd0 <__udivdi3+0x70>
  801b83:	31 ff                	xor    %edi,%edi
  801b85:	89 e8                	mov    %ebp,%eax
  801b87:	89 f2                	mov    %esi,%edx
  801b89:	f7 f3                	div    %ebx
  801b8b:	89 fa                	mov    %edi,%edx
  801b8d:	83 c4 1c             	add    $0x1c,%esp
  801b90:	5b                   	pop    %ebx
  801b91:	5e                   	pop    %esi
  801b92:	5f                   	pop    %edi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    
  801b95:	8d 76 00             	lea    0x0(%esi),%esi
  801b98:	39 f2                	cmp    %esi,%edx
  801b9a:	76 14                	jbe    801bb0 <__udivdi3+0x50>
  801b9c:	31 ff                	xor    %edi,%edi
  801b9e:	31 c0                	xor    %eax,%eax
  801ba0:	89 fa                	mov    %edi,%edx
  801ba2:	83 c4 1c             	add    $0x1c,%esp
  801ba5:	5b                   	pop    %ebx
  801ba6:	5e                   	pop    %esi
  801ba7:	5f                   	pop    %edi
  801ba8:	5d                   	pop    %ebp
  801ba9:	c3                   	ret    
  801baa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bb0:	0f bd fa             	bsr    %edx,%edi
  801bb3:	83 f7 1f             	xor    $0x1f,%edi
  801bb6:	75 48                	jne    801c00 <__udivdi3+0xa0>
  801bb8:	39 f2                	cmp    %esi,%edx
  801bba:	72 06                	jb     801bc2 <__udivdi3+0x62>
  801bbc:	31 c0                	xor    %eax,%eax
  801bbe:	39 eb                	cmp    %ebp,%ebx
  801bc0:	77 de                	ja     801ba0 <__udivdi3+0x40>
  801bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc7:	eb d7                	jmp    801ba0 <__udivdi3+0x40>
  801bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	89 d9                	mov    %ebx,%ecx
  801bd2:	85 db                	test   %ebx,%ebx
  801bd4:	75 0b                	jne    801be1 <__udivdi3+0x81>
  801bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bdb:	31 d2                	xor    %edx,%edx
  801bdd:	f7 f3                	div    %ebx
  801bdf:	89 c1                	mov    %eax,%ecx
  801be1:	31 d2                	xor    %edx,%edx
  801be3:	89 f0                	mov    %esi,%eax
  801be5:	f7 f1                	div    %ecx
  801be7:	89 c6                	mov    %eax,%esi
  801be9:	89 e8                	mov    %ebp,%eax
  801beb:	89 f7                	mov    %esi,%edi
  801bed:	f7 f1                	div    %ecx
  801bef:	89 fa                	mov    %edi,%edx
  801bf1:	83 c4 1c             	add    $0x1c,%esp
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5f                   	pop    %edi
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	89 f9                	mov    %edi,%ecx
  801c02:	b8 20 00 00 00       	mov    $0x20,%eax
  801c07:	29 f8                	sub    %edi,%eax
  801c09:	d3 e2                	shl    %cl,%edx
  801c0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c0f:	89 c1                	mov    %eax,%ecx
  801c11:	89 da                	mov    %ebx,%edx
  801c13:	d3 ea                	shr    %cl,%edx
  801c15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c19:	09 d1                	or     %edx,%ecx
  801c1b:	89 f2                	mov    %esi,%edx
  801c1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c21:	89 f9                	mov    %edi,%ecx
  801c23:	d3 e3                	shl    %cl,%ebx
  801c25:	89 c1                	mov    %eax,%ecx
  801c27:	d3 ea                	shr    %cl,%edx
  801c29:	89 f9                	mov    %edi,%ecx
  801c2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c2f:	89 eb                	mov    %ebp,%ebx
  801c31:	d3 e6                	shl    %cl,%esi
  801c33:	89 c1                	mov    %eax,%ecx
  801c35:	d3 eb                	shr    %cl,%ebx
  801c37:	09 de                	or     %ebx,%esi
  801c39:	89 f0                	mov    %esi,%eax
  801c3b:	f7 74 24 08          	divl   0x8(%esp)
  801c3f:	89 d6                	mov    %edx,%esi
  801c41:	89 c3                	mov    %eax,%ebx
  801c43:	f7 64 24 0c          	mull   0xc(%esp)
  801c47:	39 d6                	cmp    %edx,%esi
  801c49:	72 15                	jb     801c60 <__udivdi3+0x100>
  801c4b:	89 f9                	mov    %edi,%ecx
  801c4d:	d3 e5                	shl    %cl,%ebp
  801c4f:	39 c5                	cmp    %eax,%ebp
  801c51:	73 04                	jae    801c57 <__udivdi3+0xf7>
  801c53:	39 d6                	cmp    %edx,%esi
  801c55:	74 09                	je     801c60 <__udivdi3+0x100>
  801c57:	89 d8                	mov    %ebx,%eax
  801c59:	31 ff                	xor    %edi,%edi
  801c5b:	e9 40 ff ff ff       	jmp    801ba0 <__udivdi3+0x40>
  801c60:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c63:	31 ff                	xor    %edi,%edi
  801c65:	e9 36 ff ff ff       	jmp    801ba0 <__udivdi3+0x40>
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__umoddi3>:
  801c70:	f3 0f 1e fb          	endbr32 
  801c74:	55                   	push   %ebp
  801c75:	57                   	push   %edi
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	83 ec 1c             	sub    $0x1c,%esp
  801c7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c7f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	75 19                	jne    801ca8 <__umoddi3+0x38>
  801c8f:	39 df                	cmp    %ebx,%edi
  801c91:	76 5d                	jbe    801cf0 <__umoddi3+0x80>
  801c93:	89 f0                	mov    %esi,%eax
  801c95:	89 da                	mov    %ebx,%edx
  801c97:	f7 f7                	div    %edi
  801c99:	89 d0                	mov    %edx,%eax
  801c9b:	31 d2                	xor    %edx,%edx
  801c9d:	83 c4 1c             	add    $0x1c,%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    
  801ca5:	8d 76 00             	lea    0x0(%esi),%esi
  801ca8:	89 f2                	mov    %esi,%edx
  801caa:	39 d8                	cmp    %ebx,%eax
  801cac:	76 12                	jbe    801cc0 <__umoddi3+0x50>
  801cae:	89 f0                	mov    %esi,%eax
  801cb0:	89 da                	mov    %ebx,%edx
  801cb2:	83 c4 1c             	add    $0x1c,%esp
  801cb5:	5b                   	pop    %ebx
  801cb6:	5e                   	pop    %esi
  801cb7:	5f                   	pop    %edi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    
  801cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc0:	0f bd e8             	bsr    %eax,%ebp
  801cc3:	83 f5 1f             	xor    $0x1f,%ebp
  801cc6:	75 50                	jne    801d18 <__umoddi3+0xa8>
  801cc8:	39 d8                	cmp    %ebx,%eax
  801cca:	0f 82 e0 00 00 00    	jb     801db0 <__umoddi3+0x140>
  801cd0:	89 d9                	mov    %ebx,%ecx
  801cd2:	39 f7                	cmp    %esi,%edi
  801cd4:	0f 86 d6 00 00 00    	jbe    801db0 <__umoddi3+0x140>
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	89 ca                	mov    %ecx,%edx
  801cde:	83 c4 1c             	add    $0x1c,%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5f                   	pop    %edi
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    
  801ce6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ced:	8d 76 00             	lea    0x0(%esi),%esi
  801cf0:	89 fd                	mov    %edi,%ebp
  801cf2:	85 ff                	test   %edi,%edi
  801cf4:	75 0b                	jne    801d01 <__umoddi3+0x91>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f7                	div    %edi
  801cff:	89 c5                	mov    %eax,%ebp
  801d01:	89 d8                	mov    %ebx,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f5                	div    %ebp
  801d07:	89 f0                	mov    %esi,%eax
  801d09:	f7 f5                	div    %ebp
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	31 d2                	xor    %edx,%edx
  801d0f:	eb 8c                	jmp    801c9d <__umoddi3+0x2d>
  801d11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d18:	89 e9                	mov    %ebp,%ecx
  801d1a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d1f:	29 ea                	sub    %ebp,%edx
  801d21:	d3 e0                	shl    %cl,%eax
  801d23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d27:	89 d1                	mov    %edx,%ecx
  801d29:	89 f8                	mov    %edi,%eax
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d31:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d35:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d39:	09 c1                	or     %eax,%ecx
  801d3b:	89 d8                	mov    %ebx,%eax
  801d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d41:	89 e9                	mov    %ebp,%ecx
  801d43:	d3 e7                	shl    %cl,%edi
  801d45:	89 d1                	mov    %edx,%ecx
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d4f:	d3 e3                	shl    %cl,%ebx
  801d51:	89 c7                	mov    %eax,%edi
  801d53:	89 d1                	mov    %edx,%ecx
  801d55:	89 f0                	mov    %esi,%eax
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	89 fa                	mov    %edi,%edx
  801d5d:	d3 e6                	shl    %cl,%esi
  801d5f:	09 d8                	or     %ebx,%eax
  801d61:	f7 74 24 08          	divl   0x8(%esp)
  801d65:	89 d1                	mov    %edx,%ecx
  801d67:	89 f3                	mov    %esi,%ebx
  801d69:	f7 64 24 0c          	mull   0xc(%esp)
  801d6d:	89 c6                	mov    %eax,%esi
  801d6f:	89 d7                	mov    %edx,%edi
  801d71:	39 d1                	cmp    %edx,%ecx
  801d73:	72 06                	jb     801d7b <__umoddi3+0x10b>
  801d75:	75 10                	jne    801d87 <__umoddi3+0x117>
  801d77:	39 c3                	cmp    %eax,%ebx
  801d79:	73 0c                	jae    801d87 <__umoddi3+0x117>
  801d7b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801d7f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d83:	89 d7                	mov    %edx,%edi
  801d85:	89 c6                	mov    %eax,%esi
  801d87:	89 ca                	mov    %ecx,%edx
  801d89:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d8e:	29 f3                	sub    %esi,%ebx
  801d90:	19 fa                	sbb    %edi,%edx
  801d92:	89 d0                	mov    %edx,%eax
  801d94:	d3 e0                	shl    %cl,%eax
  801d96:	89 e9                	mov    %ebp,%ecx
  801d98:	d3 eb                	shr    %cl,%ebx
  801d9a:	d3 ea                	shr    %cl,%edx
  801d9c:	09 d8                	or     %ebx,%eax
  801d9e:	83 c4 1c             	add    $0x1c,%esp
  801da1:	5b                   	pop    %ebx
  801da2:	5e                   	pop    %esi
  801da3:	5f                   	pop    %edi
  801da4:	5d                   	pop    %ebp
  801da5:	c3                   	ret    
  801da6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
  801db0:	29 fe                	sub    %edi,%esi
  801db2:	19 c3                	sbb    %eax,%ebx
  801db4:	89 f2                	mov    %esi,%edx
  801db6:	89 d9                	mov    %ebx,%ecx
  801db8:	e9 1d ff ff ff       	jmp    801cda <__umoddi3+0x6a>
