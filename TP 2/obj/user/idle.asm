
obj/user/idle.debug:     formato del fichero elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003d:	c7 05 00 30 80 00 e0 	movl   $0x801de0,0x803000
  800044:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800047:	e8 57 01 00 00       	call   8001a3 <sys_yield>
  80004c:	eb f9                	jmp    800047 <umain+0x14>

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	f3 0f 1e fb          	endbr32 
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80005d:	e8 19 01 00 00       	call   80017b <sys_getenvid>
	if (id >= 0)
  800062:	85 c0                	test   %eax,%eax
  800064:	78 12                	js     800078 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800066:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800073:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800078:	85 db                	test   %ebx,%ebx
  80007a:	7e 07                	jle    800083 <libmain+0x35>
		binaryname = argv[0];
  80007c:	8b 06                	mov    (%esi),%eax
  80007e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	e8 a6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008d:	e8 0a 00 00 00       	call   80009c <exit>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	f3 0f 1e fb          	endbr32 
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a6:	e8 53 04 00 00       	call   8004fe <close_all>
	sys_env_destroy(0);
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 a0 00 00 00       	call   800155 <sys_env_destroy>
}
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
  8000c0:	83 ec 1c             	sub    $0x1c,%esp
  8000c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000c9:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d4:	8b 75 14             	mov    0x14(%ebp),%esi
  8000d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000dd:	74 04                	je     8000e3 <syscall+0x29>
  8000df:	85 c0                	test   %eax,%eax
  8000e1:	7f 08                	jg     8000eb <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	50                   	push   %eax
  8000ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8000f2:	68 ef 1d 80 00       	push   $0x801def
  8000f7:	6a 23                	push   $0x23
  8000f9:	68 0c 1e 80 00       	push   $0x801e0c
  8000fe:	e8 51 0f 00 00       	call   801054 <_panic>

00800103 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800103:	f3 0f 1e fb          	endbr32 
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80010d:	6a 00                	push   $0x0
  80010f:	6a 00                	push   $0x0
  800111:	6a 00                	push   $0x0
  800113:	ff 75 0c             	pushl  0xc(%ebp)
  800116:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800119:	ba 00 00 00 00       	mov    $0x0,%edx
  80011e:	b8 00 00 00 00       	mov    $0x0,%eax
  800123:	e8 92 ff ff ff       	call   8000ba <syscall>
}
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    

0080012d <sys_cgetc>:

int
sys_cgetc(void)
{
  80012d:	f3 0f 1e fb          	endbr32 
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800137:	6a 00                	push   $0x0
  800139:	6a 00                	push   $0x0
  80013b:	6a 00                	push   $0x0
  80013d:	6a 00                	push   $0x0
  80013f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800144:	ba 00 00 00 00       	mov    $0x0,%edx
  800149:	b8 01 00 00 00       	mov    $0x1,%eax
  80014e:	e8 67 ff ff ff       	call   8000ba <syscall>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800155:	f3 0f 1e fb          	endbr32 
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80015f:	6a 00                	push   $0x0
  800161:	6a 00                	push   $0x0
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016a:	ba 01 00 00 00       	mov    $0x1,%edx
  80016f:	b8 03 00 00 00       	mov    $0x3,%eax
  800174:	e8 41 ff ff ff       	call   8000ba <syscall>
}
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017b:	f3 0f 1e fb          	endbr32 
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800185:	6a 00                	push   $0x0
  800187:	6a 00                	push   $0x0
  800189:	6a 00                	push   $0x0
  80018b:	6a 00                	push   $0x0
  80018d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800192:	ba 00 00 00 00       	mov    $0x0,%edx
  800197:	b8 02 00 00 00       	mov    $0x2,%eax
  80019c:	e8 19 ff ff ff       	call   8000ba <syscall>
}
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <sys_yield>:

void
sys_yield(void)
{
  8001a3:	f3 0f 1e fb          	endbr32 
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001ad:	6a 00                	push   $0x0
  8001af:	6a 00                	push   $0x0
  8001b1:	6a 00                	push   $0x0
  8001b3:	6a 00                	push   $0x0
  8001b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8001bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c4:	e8 f1 fe ff ff       	call   8000ba <syscall>
}
  8001c9:	83 c4 10             	add    $0x10,%esp
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    

008001ce <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ce:	f3 0f 1e fb          	endbr32 
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001d8:	6a 00                	push   $0x0
  8001da:	6a 00                	push   $0x0
  8001dc:	ff 75 10             	pushl  0x10(%ebp)
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ea:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ef:	e8 c6 fe ff ff       	call   8000ba <syscall>
}
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f6:	f3 0f 1e fb          	endbr32 
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800200:	ff 75 18             	pushl  0x18(%ebp)
  800203:	ff 75 14             	pushl  0x14(%ebp)
  800206:	ff 75 10             	pushl  0x10(%ebp)
  800209:	ff 75 0c             	pushl  0xc(%ebp)
  80020c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020f:	ba 01 00 00 00       	mov    $0x1,%edx
  800214:	b8 05 00 00 00       	mov    $0x5,%eax
  800219:	e8 9c fe ff ff       	call   8000ba <syscall>
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800220:	f3 0f 1e fb          	endbr32 
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80022a:	6a 00                	push   $0x0
  80022c:	6a 00                	push   $0x0
  80022e:	6a 00                	push   $0x0
  800230:	ff 75 0c             	pushl  0xc(%ebp)
  800233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800236:	ba 01 00 00 00       	mov    $0x1,%edx
  80023b:	b8 06 00 00 00       	mov    $0x6,%eax
  800240:	e8 75 fe ff ff       	call   8000ba <syscall>
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800247:	f3 0f 1e fb          	endbr32 
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800251:	6a 00                	push   $0x0
  800253:	6a 00                	push   $0x0
  800255:	6a 00                	push   $0x0
  800257:	ff 75 0c             	pushl  0xc(%ebp)
  80025a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025d:	ba 01 00 00 00       	mov    $0x1,%edx
  800262:	b8 08 00 00 00       	mov    $0x8,%eax
  800267:	e8 4e fe ff ff       	call   8000ba <syscall>
}
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026e:	f3 0f 1e fb          	endbr32 
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800278:	6a 00                	push   $0x0
  80027a:	6a 00                	push   $0x0
  80027c:	6a 00                	push   $0x0
  80027e:	ff 75 0c             	pushl  0xc(%ebp)
  800281:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800284:	ba 01 00 00 00       	mov    $0x1,%edx
  800289:	b8 09 00 00 00       	mov    $0x9,%eax
  80028e:	e8 27 fe ff ff       	call   8000ba <syscall>
}
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800295:	f3 0f 1e fb          	endbr32 
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80029f:	6a 00                	push   $0x0
  8002a1:	6a 00                	push   $0x0
  8002a3:	6a 00                	push   $0x0
  8002a5:	ff 75 0c             	pushl  0xc(%ebp)
  8002a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ab:	ba 01 00 00 00       	mov    $0x1,%edx
  8002b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b5:	e8 00 fe ff ff       	call   8000ba <syscall>
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002bc:	f3 0f 1e fb          	endbr32 
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002c6:	6a 00                	push   $0x0
  8002c8:	ff 75 14             	pushl  0x14(%ebp)
  8002cb:	ff 75 10             	pushl  0x10(%ebp)
  8002ce:	ff 75 0c             	pushl  0xc(%ebp)
  8002d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002de:	e8 d7 fd ff ff       	call   8000ba <syscall>
}
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e5:	f3 0f 1e fb          	endbr32 
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002ef:	6a 00                	push   $0x0
  8002f1:	6a 00                	push   $0x0
  8002f3:	6a 00                	push   $0x0
  8002f5:	6a 00                	push   $0x0
  8002f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fa:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ff:	b8 0d 00 00 00       	mov    $0xd,%eax
  800304:	e8 b1 fd ff ff       	call   8000ba <syscall>
}
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80030b:	f3 0f 1e fb          	endbr32 
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	05 00 00 00 30       	add    $0x30000000,%eax
  80031a:	c1 e8 0c             	shr    $0xc,%eax
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80031f:	f3 0f 1e fb          	endbr32 
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800329:	ff 75 08             	pushl  0x8(%ebp)
  80032c:	e8 da ff ff ff       	call   80030b <fd2num>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	c1 e0 0c             	shl    $0xc,%eax
  800337:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80033e:	f3 0f 1e fb          	endbr32 
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80034a:	89 c2                	mov    %eax,%edx
  80034c:	c1 ea 16             	shr    $0x16,%edx
  80034f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800356:	f6 c2 01             	test   $0x1,%dl
  800359:	74 2d                	je     800388 <fd_alloc+0x4a>
  80035b:	89 c2                	mov    %eax,%edx
  80035d:	c1 ea 0c             	shr    $0xc,%edx
  800360:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800367:	f6 c2 01             	test   $0x1,%dl
  80036a:	74 1c                	je     800388 <fd_alloc+0x4a>
  80036c:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800371:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800376:	75 d2                	jne    80034a <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800381:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800386:	eb 0a                	jmp    800392 <fd_alloc+0x54>
			*fd_store = fd;
  800388:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80038d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800394:	f3 0f 1e fb          	endbr32 
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80039e:	83 f8 1f             	cmp    $0x1f,%eax
  8003a1:	77 30                	ja     8003d3 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003a3:	c1 e0 0c             	shl    $0xc,%eax
  8003a6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ab:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003b1:	f6 c2 01             	test   $0x1,%dl
  8003b4:	74 24                	je     8003da <fd_lookup+0x46>
  8003b6:	89 c2                	mov    %eax,%edx
  8003b8:	c1 ea 0c             	shr    $0xc,%edx
  8003bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c2:	f6 c2 01             	test   $0x1,%dl
  8003c5:	74 1a                	je     8003e1 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ca:	89 02                	mov    %eax,(%edx)
	return 0;
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    
		return -E_INVAL;
  8003d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d8:	eb f7                	jmp    8003d1 <fd_lookup+0x3d>
		return -E_INVAL;
  8003da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003df:	eb f0                	jmp    8003d1 <fd_lookup+0x3d>
  8003e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e6:	eb e9                	jmp    8003d1 <fd_lookup+0x3d>

008003e8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003e8:	f3 0f 1e fb          	endbr32 
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f5:	ba 98 1e 80 00       	mov    $0x801e98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003fa:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003ff:	39 08                	cmp    %ecx,(%eax)
  800401:	74 33                	je     800436 <dev_lookup+0x4e>
  800403:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800406:	8b 02                	mov    (%edx),%eax
  800408:	85 c0                	test   %eax,%eax
  80040a:	75 f3                	jne    8003ff <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80040c:	a1 04 40 80 00       	mov    0x804004,%eax
  800411:	8b 40 48             	mov    0x48(%eax),%eax
  800414:	83 ec 04             	sub    $0x4,%esp
  800417:	51                   	push   %ecx
  800418:	50                   	push   %eax
  800419:	68 1c 1e 80 00       	push   $0x801e1c
  80041e:	e8 18 0d 00 00       	call   80113b <cprintf>
	*dev = 0;
  800423:	8b 45 0c             	mov    0xc(%ebp),%eax
  800426:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800434:	c9                   	leave  
  800435:	c3                   	ret    
			*dev = devtab[i];
  800436:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800439:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043b:	b8 00 00 00 00       	mov    $0x0,%eax
  800440:	eb f2                	jmp    800434 <dev_lookup+0x4c>

00800442 <fd_close>:
{
  800442:	f3 0f 1e fb          	endbr32 
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 28             	sub    $0x28,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800455:	56                   	push   %esi
  800456:	e8 b0 fe ff ff       	call   80030b <fd2num>
  80045b:	83 c4 08             	add    $0x8,%esp
  80045e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800461:	52                   	push   %edx
  800462:	50                   	push   %eax
  800463:	e8 2c ff ff ff       	call   800394 <fd_lookup>
  800468:	89 c3                	mov    %eax,%ebx
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	85 c0                	test   %eax,%eax
  80046f:	78 05                	js     800476 <fd_close+0x34>
	    || fd != fd2)
  800471:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800474:	74 16                	je     80048c <fd_close+0x4a>
		return (must_exist ? r : 0);
  800476:	89 f8                	mov    %edi,%eax
  800478:	84 c0                	test   %al,%al
  80047a:	b8 00 00 00 00       	mov    $0x0,%eax
  80047f:	0f 44 d8             	cmove  %eax,%ebx
}
  800482:	89 d8                	mov    %ebx,%eax
  800484:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800487:	5b                   	pop    %ebx
  800488:	5e                   	pop    %esi
  800489:	5f                   	pop    %edi
  80048a:	5d                   	pop    %ebp
  80048b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800492:	50                   	push   %eax
  800493:	ff 36                	pushl  (%esi)
  800495:	e8 4e ff ff ff       	call   8003e8 <dev_lookup>
  80049a:	89 c3                	mov    %eax,%ebx
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	78 1a                	js     8004bd <fd_close+0x7b>
		if (dev->dev_close)
  8004a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004ae:	85 c0                	test   %eax,%eax
  8004b0:	74 0b                	je     8004bd <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004b2:	83 ec 0c             	sub    $0xc,%esp
  8004b5:	56                   	push   %esi
  8004b6:	ff d0                	call   *%eax
  8004b8:	89 c3                	mov    %eax,%ebx
  8004ba:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	56                   	push   %esi
  8004c1:	6a 00                	push   $0x0
  8004c3:	e8 58 fd ff ff       	call   800220 <sys_page_unmap>
	return r;
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb b5                	jmp    800482 <fd_close+0x40>

008004cd <close>:

int
close(int fdnum)
{
  8004cd:	f3 0f 1e fb          	endbr32 
  8004d1:	55                   	push   %ebp
  8004d2:	89 e5                	mov    %esp,%ebp
  8004d4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004da:	50                   	push   %eax
  8004db:	ff 75 08             	pushl  0x8(%ebp)
  8004de:	e8 b1 fe ff ff       	call   800394 <fd_lookup>
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	85 c0                	test   %eax,%eax
  8004e8:	79 02                	jns    8004ec <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    
		return fd_close(fd, 1);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	6a 01                	push   $0x1
  8004f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8004f4:	e8 49 ff ff ff       	call   800442 <fd_close>
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb ec                	jmp    8004ea <close+0x1d>

008004fe <close_all>:

void
close_all(void)
{
  8004fe:	f3 0f 1e fb          	endbr32 
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	53                   	push   %ebx
  800506:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800509:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80050e:	83 ec 0c             	sub    $0xc,%esp
  800511:	53                   	push   %ebx
  800512:	e8 b6 ff ff ff       	call   8004cd <close>
	for (i = 0; i < MAXFD; i++)
  800517:	83 c3 01             	add    $0x1,%ebx
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	83 fb 20             	cmp    $0x20,%ebx
  800520:	75 ec                	jne    80050e <close_all+0x10>
}
  800522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800525:	c9                   	leave  
  800526:	c3                   	ret    

00800527 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800527:	f3 0f 1e fb          	endbr32 
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	57                   	push   %edi
  80052f:	56                   	push   %esi
  800530:	53                   	push   %ebx
  800531:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800534:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800537:	50                   	push   %eax
  800538:	ff 75 08             	pushl  0x8(%ebp)
  80053b:	e8 54 fe ff ff       	call   800394 <fd_lookup>
  800540:	89 c3                	mov    %eax,%ebx
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 c0                	test   %eax,%eax
  800547:	0f 88 81 00 00 00    	js     8005ce <dup+0xa7>
		return r;
	close(newfdnum);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	e8 75 ff ff ff       	call   8004cd <close>

	newfd = INDEX2FD(newfdnum);
  800558:	8b 75 0c             	mov    0xc(%ebp),%esi
  80055b:	c1 e6 0c             	shl    $0xc,%esi
  80055e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800564:	83 c4 04             	add    $0x4,%esp
  800567:	ff 75 e4             	pushl  -0x1c(%ebp)
  80056a:	e8 b0 fd ff ff       	call   80031f <fd2data>
  80056f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 a6 fd ff ff       	call   80031f <fd2data>
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80057e:	89 d8                	mov    %ebx,%eax
  800580:	c1 e8 16             	shr    $0x16,%eax
  800583:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80058a:	a8 01                	test   $0x1,%al
  80058c:	74 11                	je     80059f <dup+0x78>
  80058e:	89 d8                	mov    %ebx,%eax
  800590:	c1 e8 0c             	shr    $0xc,%eax
  800593:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80059a:	f6 c2 01             	test   $0x1,%dl
  80059d:	75 39                	jne    8005d8 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80059f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a2:	89 d0                	mov    %edx,%eax
  8005a4:	c1 e8 0c             	shr    $0xc,%eax
  8005a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ae:	83 ec 0c             	sub    $0xc,%esp
  8005b1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b6:	50                   	push   %eax
  8005b7:	56                   	push   %esi
  8005b8:	6a 00                	push   $0x0
  8005ba:	52                   	push   %edx
  8005bb:	6a 00                	push   $0x0
  8005bd:	e8 34 fc ff ff       	call   8001f6 <sys_page_map>
  8005c2:	89 c3                	mov    %eax,%ebx
  8005c4:	83 c4 20             	add    $0x20,%esp
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	78 31                	js     8005fc <dup+0xd5>
		goto err;

	return newfdnum;
  8005cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005ce:	89 d8                	mov    %ebx,%eax
  8005d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5f                   	pop    %edi
  8005d6:	5d                   	pop    %ebp
  8005d7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e7:	50                   	push   %eax
  8005e8:	57                   	push   %edi
  8005e9:	6a 00                	push   $0x0
  8005eb:	53                   	push   %ebx
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 03 fc ff ff       	call   8001f6 <sys_page_map>
  8005f3:	89 c3                	mov    %eax,%ebx
  8005f5:	83 c4 20             	add    $0x20,%esp
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	79 a3                	jns    80059f <dup+0x78>
	sys_page_unmap(0, newfd);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	56                   	push   %esi
  800600:	6a 00                	push   $0x0
  800602:	e8 19 fc ff ff       	call   800220 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800607:	83 c4 08             	add    $0x8,%esp
  80060a:	57                   	push   %edi
  80060b:	6a 00                	push   $0x0
  80060d:	e8 0e fc ff ff       	call   800220 <sys_page_unmap>
	return r;
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	eb b7                	jmp    8005ce <dup+0xa7>

00800617 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800617:	f3 0f 1e fb          	endbr32 
  80061b:	55                   	push   %ebp
  80061c:	89 e5                	mov    %esp,%ebp
  80061e:	53                   	push   %ebx
  80061f:	83 ec 1c             	sub    $0x1c,%esp
  800622:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800625:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800628:	50                   	push   %eax
  800629:	53                   	push   %ebx
  80062a:	e8 65 fd ff ff       	call   800394 <fd_lookup>
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	85 c0                	test   %eax,%eax
  800634:	78 3f                	js     800675 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80063c:	50                   	push   %eax
  80063d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800640:	ff 30                	pushl  (%eax)
  800642:	e8 a1 fd ff ff       	call   8003e8 <dev_lookup>
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	85 c0                	test   %eax,%eax
  80064c:	78 27                	js     800675 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80064e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800651:	8b 42 08             	mov    0x8(%edx),%eax
  800654:	83 e0 03             	and    $0x3,%eax
  800657:	83 f8 01             	cmp    $0x1,%eax
  80065a:	74 1e                	je     80067a <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80065c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80065f:	8b 40 08             	mov    0x8(%eax),%eax
  800662:	85 c0                	test   %eax,%eax
  800664:	74 35                	je     80069b <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800666:	83 ec 04             	sub    $0x4,%esp
  800669:	ff 75 10             	pushl  0x10(%ebp)
  80066c:	ff 75 0c             	pushl  0xc(%ebp)
  80066f:	52                   	push   %edx
  800670:	ff d0                	call   *%eax
  800672:	83 c4 10             	add    $0x10,%esp
}
  800675:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800678:	c9                   	leave  
  800679:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 5d 1e 80 00       	push   $0x801e5d
  80068c:	e8 aa 0a 00 00       	call   80113b <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800699:	eb da                	jmp    800675 <read+0x5e>
		return -E_NOT_SUPP;
  80069b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006a0:	eb d3                	jmp    800675 <read+0x5e>

008006a2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006a2:	f3 0f 1e fb          	endbr32 
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
  8006a9:	57                   	push   %edi
  8006aa:	56                   	push   %esi
  8006ab:	53                   	push   %ebx
  8006ac:	83 ec 0c             	sub    $0xc,%esp
  8006af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ba:	eb 02                	jmp    8006be <readn+0x1c>
  8006bc:	01 c3                	add    %eax,%ebx
  8006be:	39 f3                	cmp    %esi,%ebx
  8006c0:	73 21                	jae    8006e3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c2:	83 ec 04             	sub    $0x4,%esp
  8006c5:	89 f0                	mov    %esi,%eax
  8006c7:	29 d8                	sub    %ebx,%eax
  8006c9:	50                   	push   %eax
  8006ca:	89 d8                	mov    %ebx,%eax
  8006cc:	03 45 0c             	add    0xc(%ebp),%eax
  8006cf:	50                   	push   %eax
  8006d0:	57                   	push   %edi
  8006d1:	e8 41 ff ff ff       	call   800617 <read>
		if (m < 0)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	78 04                	js     8006e1 <readn+0x3f>
			return m;
		if (m == 0)
  8006dd:	75 dd                	jne    8006bc <readn+0x1a>
  8006df:	eb 02                	jmp    8006e3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006e3:	89 d8                	mov    %ebx,%eax
  8006e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e8:	5b                   	pop    %ebx
  8006e9:	5e                   	pop    %esi
  8006ea:	5f                   	pop    %edi
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006ed:	f3 0f 1e fb          	endbr32 
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	53                   	push   %ebx
  8006f5:	83 ec 1c             	sub    $0x1c,%esp
  8006f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	53                   	push   %ebx
  800700:	e8 8f fc ff ff       	call   800394 <fd_lookup>
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	85 c0                	test   %eax,%eax
  80070a:	78 3a                	js     800746 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800716:	ff 30                	pushl  (%eax)
  800718:	e8 cb fc ff ff       	call   8003e8 <dev_lookup>
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	85 c0                	test   %eax,%eax
  800722:	78 22                	js     800746 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800724:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800727:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80072b:	74 1e                	je     80074b <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80072d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800730:	8b 52 0c             	mov    0xc(%edx),%edx
  800733:	85 d2                	test   %edx,%edx
  800735:	74 35                	je     80076c <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800737:	83 ec 04             	sub    $0x4,%esp
  80073a:	ff 75 10             	pushl  0x10(%ebp)
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	50                   	push   %eax
  800741:	ff d2                	call   *%edx
  800743:	83 c4 10             	add    $0x10,%esp
}
  800746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800749:	c9                   	leave  
  80074a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 79 1e 80 00       	push   $0x801e79
  80075d:	e8 d9 09 00 00       	call   80113b <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076a:	eb da                	jmp    800746 <write+0x59>
		return -E_NOT_SUPP;
  80076c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800771:	eb d3                	jmp    800746 <write+0x59>

00800773 <seek>:

int
seek(int fdnum, off_t offset)
{
  800773:	f3 0f 1e fb          	endbr32 
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80077d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	ff 75 08             	pushl  0x8(%ebp)
  800784:	e8 0b fc ff ff       	call   800394 <fd_lookup>
  800789:	83 c4 10             	add    $0x10,%esp
  80078c:	85 c0                	test   %eax,%eax
  80078e:	78 0e                	js     80079e <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800790:	8b 55 0c             	mov    0xc(%ebp),%edx
  800793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800796:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800799:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a0:	f3 0f 1e fb          	endbr32 
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	83 ec 1c             	sub    $0x1c,%esp
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	53                   	push   %ebx
  8007b3:	e8 dc fb ff ff       	call   800394 <fd_lookup>
  8007b8:	83 c4 10             	add    $0x10,%esp
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	78 37                	js     8007f6 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c5:	50                   	push   %eax
  8007c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c9:	ff 30                	pushl  (%eax)
  8007cb:	e8 18 fc ff ff       	call   8003e8 <dev_lookup>
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 1f                	js     8007f6 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007de:	74 1b                	je     8007fb <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e3:	8b 52 18             	mov    0x18(%edx),%edx
  8007e6:	85 d2                	test   %edx,%edx
  8007e8:	74 32                	je     80081c <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	ff 75 0c             	pushl  0xc(%ebp)
  8007f0:	50                   	push   %eax
  8007f1:	ff d2                	call   *%edx
  8007f3:	83 c4 10             	add    $0x10,%esp
}
  8007f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007fb:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800800:	8b 40 48             	mov    0x48(%eax),%eax
  800803:	83 ec 04             	sub    $0x4,%esp
  800806:	53                   	push   %ebx
  800807:	50                   	push   %eax
  800808:	68 3c 1e 80 00       	push   $0x801e3c
  80080d:	e8 29 09 00 00       	call   80113b <cprintf>
		return -E_INVAL;
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081a:	eb da                	jmp    8007f6 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80081c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800821:	eb d3                	jmp    8007f6 <ftruncate+0x56>

00800823 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800823:	f3 0f 1e fb          	endbr32 
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	83 ec 1c             	sub    $0x1c,%esp
  80082e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800831:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800834:	50                   	push   %eax
  800835:	ff 75 08             	pushl  0x8(%ebp)
  800838:	e8 57 fb ff ff       	call   800394 <fd_lookup>
  80083d:	83 c4 10             	add    $0x10,%esp
  800840:	85 c0                	test   %eax,%eax
  800842:	78 4b                	js     80088f <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800844:	83 ec 08             	sub    $0x8,%esp
  800847:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084a:	50                   	push   %eax
  80084b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084e:	ff 30                	pushl  (%eax)
  800850:	e8 93 fb ff ff       	call   8003e8 <dev_lookup>
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	85 c0                	test   %eax,%eax
  80085a:	78 33                	js     80088f <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80085c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800863:	74 2f                	je     800894 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800865:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800868:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086f:	00 00 00 
	stat->st_isdir = 0;
  800872:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800879:	00 00 00 
	stat->st_dev = dev;
  80087c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	53                   	push   %ebx
  800886:	ff 75 f0             	pushl  -0x10(%ebp)
  800889:	ff 50 14             	call   *0x14(%eax)
  80088c:	83 c4 10             	add    $0x10,%esp
}
  80088f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800892:	c9                   	leave  
  800893:	c3                   	ret    
		return -E_NOT_SUPP;
  800894:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800899:	eb f4                	jmp    80088f <fstat+0x6c>

0080089b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089b:	f3 0f 1e fb          	endbr32 
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	6a 00                	push   $0x0
  8008a9:	ff 75 08             	pushl  0x8(%ebp)
  8008ac:	e8 fb 01 00 00       	call   800aac <open>
  8008b1:	89 c3                	mov    %eax,%ebx
  8008b3:	83 c4 10             	add    $0x10,%esp
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 1b                	js     8008d5 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	ff 75 0c             	pushl  0xc(%ebp)
  8008c0:	50                   	push   %eax
  8008c1:	e8 5d ff ff ff       	call   800823 <fstat>
  8008c6:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c8:	89 1c 24             	mov    %ebx,(%esp)
  8008cb:	e8 fd fb ff ff       	call   8004cd <close>
	return r;
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	89 f3                	mov    %esi,%ebx
}
  8008d5:	89 d8                	mov    %ebx,%eax
  8008d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	89 c6                	mov    %eax,%esi
  8008e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008ee:	74 27                	je     800917 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f0:	6a 07                	push   $0x7
  8008f2:	68 00 50 80 00       	push   $0x805000
  8008f7:	56                   	push   %esi
  8008f8:	ff 35 00 40 80 00    	pushl  0x804000
  8008fe:	e8 84 11 00 00       	call   801a87 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800903:	83 c4 0c             	add    $0xc,%esp
  800906:	6a 00                	push   $0x0
  800908:	53                   	push   %ebx
  800909:	6a 00                	push   $0x0
  80090b:	e8 09 11 00 00       	call   801a19 <ipc_recv>
}
  800910:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800917:	83 ec 0c             	sub    $0xc,%esp
  80091a:	6a 01                	push   $0x1
  80091c:	e8 cb 11 00 00       	call   801aec <ipc_find_env>
  800921:	a3 00 40 80 00       	mov    %eax,0x804000
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	eb c5                	jmp    8008f0 <fsipc+0x12>

0080092b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80092b:	f3 0f 1e fb          	endbr32 
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 40 0c             	mov    0xc(%eax),%eax
  80093b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800940:	8b 45 0c             	mov    0xc(%ebp),%eax
  800943:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800948:	ba 00 00 00 00       	mov    $0x0,%edx
  80094d:	b8 02 00 00 00       	mov    $0x2,%eax
  800952:	e8 87 ff ff ff       	call   8008de <fsipc>
}
  800957:	c9                   	leave  
  800958:	c3                   	ret    

00800959 <devfile_flush>:
{
  800959:	f3 0f 1e fb          	endbr32 
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 40 0c             	mov    0xc(%eax),%eax
  800969:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 06 00 00 00       	mov    $0x6,%eax
  800978:	e8 61 ff ff ff       	call   8008de <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_stat>:
{
  80097f:	f3 0f 1e fb          	endbr32 
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	83 ec 04             	sub    $0x4,%esp
  80098a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 40 0c             	mov    0xc(%eax),%eax
  800993:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a2:	e8 37 ff ff ff       	call   8008de <fsipc>
  8009a7:	85 c0                	test   %eax,%eax
  8009a9:	78 2c                	js     8009d7 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	68 00 50 80 00       	push   $0x805000
  8009b3:	53                   	push   %ebx
  8009b4:	e8 ec 0c 00 00       	call   8016a5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b9:	a1 80 50 80 00       	mov    0x805080,%eax
  8009be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009cf:	83 c4 10             	add    $0x10,%esp
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <devfile_write>:
{
  8009dc:	f3 0f 1e fb          	endbr32 
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 0c             	sub    $0xc,%esp
  8009e6:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8009ef:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009f5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009fa:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009ff:	0f 47 c2             	cmova  %edx,%eax
  800a02:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a07:	50                   	push   %eax
  800a08:	ff 75 0c             	pushl  0xc(%ebp)
  800a0b:	68 08 50 80 00       	push   $0x805008
  800a10:	e8 48 0e 00 00       	call   80185d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a15:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1a:	b8 04 00 00 00       	mov    $0x4,%eax
  800a1f:	e8 ba fe ff ff       	call   8008de <fsipc>
}
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <devfile_read>:
{
  800a26:	f3 0f 1e fb          	endbr32 
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	8b 40 0c             	mov    0xc(%eax),%eax
  800a38:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a43:	ba 00 00 00 00       	mov    $0x0,%edx
  800a48:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4d:	e8 8c fe ff ff       	call   8008de <fsipc>
  800a52:	89 c3                	mov    %eax,%ebx
  800a54:	85 c0                	test   %eax,%eax
  800a56:	78 1f                	js     800a77 <devfile_read+0x51>
	assert(r <= n);
  800a58:	39 f0                	cmp    %esi,%eax
  800a5a:	77 24                	ja     800a80 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a5c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a61:	7f 33                	jg     800a96 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a63:	83 ec 04             	sub    $0x4,%esp
  800a66:	50                   	push   %eax
  800a67:	68 00 50 80 00       	push   $0x805000
  800a6c:	ff 75 0c             	pushl  0xc(%ebp)
  800a6f:	e8 e9 0d 00 00       	call   80185d <memmove>
	return r;
  800a74:	83 c4 10             	add    $0x10,%esp
}
  800a77:	89 d8                	mov    %ebx,%eax
  800a79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    
	assert(r <= n);
  800a80:	68 a8 1e 80 00       	push   $0x801ea8
  800a85:	68 af 1e 80 00       	push   $0x801eaf
  800a8a:	6a 7c                	push   $0x7c
  800a8c:	68 c4 1e 80 00       	push   $0x801ec4
  800a91:	e8 be 05 00 00       	call   801054 <_panic>
	assert(r <= PGSIZE);
  800a96:	68 cf 1e 80 00       	push   $0x801ecf
  800a9b:	68 af 1e 80 00       	push   $0x801eaf
  800aa0:	6a 7d                	push   $0x7d
  800aa2:	68 c4 1e 80 00       	push   $0x801ec4
  800aa7:	e8 a8 05 00 00       	call   801054 <_panic>

00800aac <open>:
{
  800aac:	f3 0f 1e fb          	endbr32 
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	83 ec 1c             	sub    $0x1c,%esp
  800ab8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800abb:	56                   	push   %esi
  800abc:	e8 a1 0b 00 00       	call   801662 <strlen>
  800ac1:	83 c4 10             	add    $0x10,%esp
  800ac4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac9:	7f 6c                	jg     800b37 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800acb:	83 ec 0c             	sub    $0xc,%esp
  800ace:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad1:	50                   	push   %eax
  800ad2:	e8 67 f8 ff ff       	call   80033e <fd_alloc>
  800ad7:	89 c3                	mov    %eax,%ebx
  800ad9:	83 c4 10             	add    $0x10,%esp
  800adc:	85 c0                	test   %eax,%eax
  800ade:	78 3c                	js     800b1c <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800ae0:	83 ec 08             	sub    $0x8,%esp
  800ae3:	56                   	push   %esi
  800ae4:	68 00 50 80 00       	push   $0x805000
  800ae9:	e8 b7 0b 00 00       	call   8016a5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af9:	b8 01 00 00 00       	mov    $0x1,%eax
  800afe:	e8 db fd ff ff       	call   8008de <fsipc>
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	78 19                	js     800b25 <open+0x79>
	return fd2num(fd);
  800b0c:	83 ec 0c             	sub    $0xc,%esp
  800b0f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b12:	e8 f4 f7 ff ff       	call   80030b <fd2num>
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	83 c4 10             	add    $0x10,%esp
}
  800b1c:	89 d8                	mov    %ebx,%eax
  800b1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    
		fd_close(fd, 0);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	6a 00                	push   $0x0
  800b2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2d:	e8 10 f9 ff ff       	call   800442 <fd_close>
		return r;
  800b32:	83 c4 10             	add    $0x10,%esp
  800b35:	eb e5                	jmp    800b1c <open+0x70>
		return -E_BAD_PATH;
  800b37:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b3c:	eb de                	jmp    800b1c <open+0x70>

00800b3e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3e:	f3 0f 1e fb          	endbr32 
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b52:	e8 87 fd ff ff       	call   8008de <fsipc>
}
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b59:	f3 0f 1e fb          	endbr32 
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	ff 75 08             	pushl  0x8(%ebp)
  800b6b:	e8 af f7 ff ff       	call   80031f <fd2data>
  800b70:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b72:	83 c4 08             	add    $0x8,%esp
  800b75:	68 db 1e 80 00       	push   $0x801edb
  800b7a:	53                   	push   %ebx
  800b7b:	e8 25 0b 00 00       	call   8016a5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b80:	8b 46 04             	mov    0x4(%esi),%eax
  800b83:	2b 06                	sub    (%esi),%eax
  800b85:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b8b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b92:	00 00 00 
	stat->st_dev = &devpipe;
  800b95:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b9c:	30 80 00 
	return 0;
}
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	53                   	push   %ebx
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb9:	53                   	push   %ebx
  800bba:	6a 00                	push   $0x0
  800bbc:	e8 5f f6 ff ff       	call   800220 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc1:	89 1c 24             	mov    %ebx,(%esp)
  800bc4:	e8 56 f7 ff ff       	call   80031f <fd2data>
  800bc9:	83 c4 08             	add    $0x8,%esp
  800bcc:	50                   	push   %eax
  800bcd:	6a 00                	push   $0x0
  800bcf:	e8 4c f6 ff ff       	call   800220 <sys_page_unmap>
}
  800bd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <_pipeisclosed>:
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 1c             	sub    $0x1c,%esp
  800be2:	89 c7                	mov    %eax,%edi
  800be4:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800be6:	a1 04 40 80 00       	mov    0x804004,%eax
  800beb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	57                   	push   %edi
  800bf2:	e8 32 0f 00 00       	call   801b29 <pageref>
  800bf7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bfa:	89 34 24             	mov    %esi,(%esp)
  800bfd:	e8 27 0f 00 00       	call   801b29 <pageref>
		nn = thisenv->env_runs;
  800c02:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c08:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0b:	83 c4 10             	add    $0x10,%esp
  800c0e:	39 cb                	cmp    %ecx,%ebx
  800c10:	74 1b                	je     800c2d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c12:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c15:	75 cf                	jne    800be6 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c17:	8b 42 58             	mov    0x58(%edx),%eax
  800c1a:	6a 01                	push   $0x1
  800c1c:	50                   	push   %eax
  800c1d:	53                   	push   %ebx
  800c1e:	68 e2 1e 80 00       	push   $0x801ee2
  800c23:	e8 13 05 00 00       	call   80113b <cprintf>
  800c28:	83 c4 10             	add    $0x10,%esp
  800c2b:	eb b9                	jmp    800be6 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c2d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c30:	0f 94 c0             	sete   %al
  800c33:	0f b6 c0             	movzbl %al,%eax
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <devpipe_write>:
{
  800c3e:	f3 0f 1e fb          	endbr32 
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 28             	sub    $0x28,%esp
  800c4b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c4e:	56                   	push   %esi
  800c4f:	e8 cb f6 ff ff       	call   80031f <fd2data>
  800c54:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c56:	83 c4 10             	add    $0x10,%esp
  800c59:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c61:	74 4f                	je     800cb2 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c63:	8b 43 04             	mov    0x4(%ebx),%eax
  800c66:	8b 0b                	mov    (%ebx),%ecx
  800c68:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6b:	39 d0                	cmp    %edx,%eax
  800c6d:	72 14                	jb     800c83 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c6f:	89 da                	mov    %ebx,%edx
  800c71:	89 f0                	mov    %esi,%eax
  800c73:	e8 61 ff ff ff       	call   800bd9 <_pipeisclosed>
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	75 3b                	jne    800cb7 <devpipe_write+0x79>
			sys_yield();
  800c7c:	e8 22 f5 ff ff       	call   8001a3 <sys_yield>
  800c81:	eb e0                	jmp    800c63 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8d:	89 c2                	mov    %eax,%edx
  800c8f:	c1 fa 1f             	sar    $0x1f,%edx
  800c92:	89 d1                	mov    %edx,%ecx
  800c94:	c1 e9 1b             	shr    $0x1b,%ecx
  800c97:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9a:	83 e2 1f             	and    $0x1f,%edx
  800c9d:	29 ca                	sub    %ecx,%edx
  800c9f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca7:	83 c0 01             	add    $0x1,%eax
  800caa:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cad:	83 c7 01             	add    $0x1,%edi
  800cb0:	eb ac                	jmp    800c5e <devpipe_write+0x20>
	return i;
  800cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb5:	eb 05                	jmp    800cbc <devpipe_write+0x7e>
				return 0;
  800cb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <devpipe_read>:
{
  800cc4:	f3 0f 1e fb          	endbr32 
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 18             	sub    $0x18,%esp
  800cd1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cd4:	57                   	push   %edi
  800cd5:	e8 45 f6 ff ff       	call   80031f <fd2data>
  800cda:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	be 00 00 00 00       	mov    $0x0,%esi
  800ce4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ce7:	75 14                	jne    800cfd <devpipe_read+0x39>
	return i;
  800ce9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cec:	eb 02                	jmp    800cf0 <devpipe_read+0x2c>
				return i;
  800cee:	89 f0                	mov    %esi,%eax
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    
			sys_yield();
  800cf8:	e8 a6 f4 ff ff       	call   8001a3 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cfd:	8b 03                	mov    (%ebx),%eax
  800cff:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d02:	75 18                	jne    800d1c <devpipe_read+0x58>
			if (i > 0)
  800d04:	85 f6                	test   %esi,%esi
  800d06:	75 e6                	jne    800cee <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d08:	89 da                	mov    %ebx,%edx
  800d0a:	89 f8                	mov    %edi,%eax
  800d0c:	e8 c8 fe ff ff       	call   800bd9 <_pipeisclosed>
  800d11:	85 c0                	test   %eax,%eax
  800d13:	74 e3                	je     800cf8 <devpipe_read+0x34>
				return 0;
  800d15:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1a:	eb d4                	jmp    800cf0 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d1c:	99                   	cltd   
  800d1d:	c1 ea 1b             	shr    $0x1b,%edx
  800d20:	01 d0                	add    %edx,%eax
  800d22:	83 e0 1f             	and    $0x1f,%eax
  800d25:	29 d0                	sub    %edx,%eax
  800d27:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d32:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d35:	83 c6 01             	add    $0x1,%esi
  800d38:	eb aa                	jmp    800ce4 <devpipe_read+0x20>

00800d3a <pipe>:
{
  800d3a:	f3 0f 1e fb          	endbr32 
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d49:	50                   	push   %eax
  800d4a:	e8 ef f5 ff ff       	call   80033e <fd_alloc>
  800d4f:	89 c3                	mov    %eax,%ebx
  800d51:	83 c4 10             	add    $0x10,%esp
  800d54:	85 c0                	test   %eax,%eax
  800d56:	0f 88 23 01 00 00    	js     800e7f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5c:	83 ec 04             	sub    $0x4,%esp
  800d5f:	68 07 04 00 00       	push   $0x407
  800d64:	ff 75 f4             	pushl  -0xc(%ebp)
  800d67:	6a 00                	push   $0x0
  800d69:	e8 60 f4 ff ff       	call   8001ce <sys_page_alloc>
  800d6e:	89 c3                	mov    %eax,%ebx
  800d70:	83 c4 10             	add    $0x10,%esp
  800d73:	85 c0                	test   %eax,%eax
  800d75:	0f 88 04 01 00 00    	js     800e7f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d81:	50                   	push   %eax
  800d82:	e8 b7 f5 ff ff       	call   80033e <fd_alloc>
  800d87:	89 c3                	mov    %eax,%ebx
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	0f 88 db 00 00 00    	js     800e6f <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d94:	83 ec 04             	sub    $0x4,%esp
  800d97:	68 07 04 00 00       	push   $0x407
  800d9c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9f:	6a 00                	push   $0x0
  800da1:	e8 28 f4 ff ff       	call   8001ce <sys_page_alloc>
  800da6:	89 c3                	mov    %eax,%ebx
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	0f 88 bc 00 00 00    	js     800e6f <pipe+0x135>
	va = fd2data(fd0);
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	ff 75 f4             	pushl  -0xc(%ebp)
  800db9:	e8 61 f5 ff ff       	call   80031f <fd2data>
  800dbe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc0:	83 c4 0c             	add    $0xc,%esp
  800dc3:	68 07 04 00 00       	push   $0x407
  800dc8:	50                   	push   %eax
  800dc9:	6a 00                	push   $0x0
  800dcb:	e8 fe f3 ff ff       	call   8001ce <sys_page_alloc>
  800dd0:	89 c3                	mov    %eax,%ebx
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	0f 88 82 00 00 00    	js     800e5f <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddd:	83 ec 0c             	sub    $0xc,%esp
  800de0:	ff 75 f0             	pushl  -0x10(%ebp)
  800de3:	e8 37 f5 ff ff       	call   80031f <fd2data>
  800de8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800def:	50                   	push   %eax
  800df0:	6a 00                	push   $0x0
  800df2:	56                   	push   %esi
  800df3:	6a 00                	push   $0x0
  800df5:	e8 fc f3 ff ff       	call   8001f6 <sys_page_map>
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	83 c4 20             	add    $0x20,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	78 4e                	js     800e51 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e03:	a1 20 30 80 00       	mov    0x803020,%eax
  800e08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e0b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e10:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e17:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e1a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2c:	e8 da f4 ff ff       	call   80030b <fd2num>
  800e31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e34:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e36:	83 c4 04             	add    $0x4,%esp
  800e39:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3c:	e8 ca f4 ff ff       	call   80030b <fd2num>
  800e41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e44:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e47:	83 c4 10             	add    $0x10,%esp
  800e4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4f:	eb 2e                	jmp    800e7f <pipe+0x145>
	sys_page_unmap(0, va);
  800e51:	83 ec 08             	sub    $0x8,%esp
  800e54:	56                   	push   %esi
  800e55:	6a 00                	push   $0x0
  800e57:	e8 c4 f3 ff ff       	call   800220 <sys_page_unmap>
  800e5c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	ff 75 f0             	pushl  -0x10(%ebp)
  800e65:	6a 00                	push   $0x0
  800e67:	e8 b4 f3 ff ff       	call   800220 <sys_page_unmap>
  800e6c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	ff 75 f4             	pushl  -0xc(%ebp)
  800e75:	6a 00                	push   $0x0
  800e77:	e8 a4 f3 ff ff       	call   800220 <sys_page_unmap>
  800e7c:	83 c4 10             	add    $0x10,%esp
}
  800e7f:	89 d8                	mov    %ebx,%eax
  800e81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <pipeisclosed>:
{
  800e88:	f3 0f 1e fb          	endbr32 
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e95:	50                   	push   %eax
  800e96:	ff 75 08             	pushl  0x8(%ebp)
  800e99:	e8 f6 f4 ff ff       	call   800394 <fd_lookup>
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	78 18                	js     800ebd <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ea5:	83 ec 0c             	sub    $0xc,%esp
  800ea8:	ff 75 f4             	pushl  -0xc(%ebp)
  800eab:	e8 6f f4 ff ff       	call   80031f <fd2data>
  800eb0:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb5:	e8 1f fd ff ff       	call   800bd9 <_pipeisclosed>
  800eba:	83 c4 10             	add    $0x10,%esp
}
  800ebd:	c9                   	leave  
  800ebe:	c3                   	ret    

00800ebf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ebf:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800ec3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec8:	c3                   	ret    

00800ec9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec9:	f3 0f 1e fb          	endbr32 
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed3:	68 fa 1e 80 00       	push   $0x801efa
  800ed8:	ff 75 0c             	pushl  0xc(%ebp)
  800edb:	e8 c5 07 00 00       	call   8016a5 <strcpy>
	return 0;
}
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <devcons_write>:
{
  800ee7:	f3 0f 1e fb          	endbr32 
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ef7:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800efc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f02:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f05:	73 31                	jae    800f38 <devcons_write+0x51>
		m = n - tot;
  800f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0a:	29 f3                	sub    %esi,%ebx
  800f0c:	83 fb 7f             	cmp    $0x7f,%ebx
  800f0f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f14:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f17:	83 ec 04             	sub    $0x4,%esp
  800f1a:	53                   	push   %ebx
  800f1b:	89 f0                	mov    %esi,%eax
  800f1d:	03 45 0c             	add    0xc(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	57                   	push   %edi
  800f22:	e8 36 09 00 00       	call   80185d <memmove>
		sys_cputs(buf, m);
  800f27:	83 c4 08             	add    $0x8,%esp
  800f2a:	53                   	push   %ebx
  800f2b:	57                   	push   %edi
  800f2c:	e8 d2 f1 ff ff       	call   800103 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f31:	01 de                	add    %ebx,%esi
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	eb ca                	jmp    800f02 <devcons_write+0x1b>
}
  800f38:	89 f0                	mov    %esi,%eax
  800f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <devcons_read>:
{
  800f42:	f3 0f 1e fb          	endbr32 
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	83 ec 08             	sub    $0x8,%esp
  800f4c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f55:	74 21                	je     800f78 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f57:	e8 d1 f1 ff ff       	call   80012d <sys_cgetc>
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	75 07                	jne    800f67 <devcons_read+0x25>
		sys_yield();
  800f60:	e8 3e f2 ff ff       	call   8001a3 <sys_yield>
  800f65:	eb f0                	jmp    800f57 <devcons_read+0x15>
	if (c < 0)
  800f67:	78 0f                	js     800f78 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f69:	83 f8 04             	cmp    $0x4,%eax
  800f6c:	74 0c                	je     800f7a <devcons_read+0x38>
	*(char*)vbuf = c;
  800f6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f71:	88 02                	mov    %al,(%edx)
	return 1;
  800f73:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    
		return 0;
  800f7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7f:	eb f7                	jmp    800f78 <devcons_read+0x36>

00800f81 <cputchar>:
{
  800f81:	f3 0f 1e fb          	endbr32 
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f91:	6a 01                	push   $0x1
  800f93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f96:	50                   	push   %eax
  800f97:	e8 67 f1 ff ff       	call   800103 <sys_cputs>
}
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <getchar>:
{
  800fa1:	f3 0f 1e fb          	endbr32 
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fab:	6a 01                	push   $0x1
  800fad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb0:	50                   	push   %eax
  800fb1:	6a 00                	push   $0x0
  800fb3:	e8 5f f6 ff ff       	call   800617 <read>
	if (r < 0)
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	78 06                	js     800fc5 <getchar+0x24>
	if (r < 1)
  800fbf:	74 06                	je     800fc7 <getchar+0x26>
	return c;
  800fc1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    
		return -E_EOF;
  800fc7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fcc:	eb f7                	jmp    800fc5 <getchar+0x24>

00800fce <iscons>:
{
  800fce:	f3 0f 1e fb          	endbr32 
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	ff 75 08             	pushl  0x8(%ebp)
  800fdf:	e8 b0 f3 ff ff       	call   800394 <fd_lookup>
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 11                	js     800ffc <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff4:	39 10                	cmp    %edx,(%eax)
  800ff6:	0f 94 c0             	sete   %al
  800ff9:	0f b6 c0             	movzbl %al,%eax
}
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <opencons>:
{
  800ffe:	f3 0f 1e fb          	endbr32 
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801008:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	e8 2d f3 ff ff       	call   80033e <fd_alloc>
  801011:	83 c4 10             	add    $0x10,%esp
  801014:	85 c0                	test   %eax,%eax
  801016:	78 3a                	js     801052 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	68 07 04 00 00       	push   $0x407
  801020:	ff 75 f4             	pushl  -0xc(%ebp)
  801023:	6a 00                	push   $0x0
  801025:	e8 a4 f1 ff ff       	call   8001ce <sys_page_alloc>
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	78 21                	js     801052 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801031:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801034:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80103a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80103c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	50                   	push   %eax
  80104a:	e8 bc f2 ff ff       	call   80030b <fd2num>
  80104f:	83 c4 10             	add    $0x10,%esp
}
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801054:	f3 0f 1e fb          	endbr32 
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80105d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801060:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801066:	e8 10 f1 ff ff       	call   80017b <sys_getenvid>
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	ff 75 0c             	pushl  0xc(%ebp)
  801071:	ff 75 08             	pushl  0x8(%ebp)
  801074:	56                   	push   %esi
  801075:	50                   	push   %eax
  801076:	68 08 1f 80 00       	push   $0x801f08
  80107b:	e8 bb 00 00 00       	call   80113b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801080:	83 c4 18             	add    $0x18,%esp
  801083:	53                   	push   %ebx
  801084:	ff 75 10             	pushl  0x10(%ebp)
  801087:	e8 5a 00 00 00       	call   8010e6 <vcprintf>
	cprintf("\n");
  80108c:	c7 04 24 f3 1e 80 00 	movl   $0x801ef3,(%esp)
  801093:	e8 a3 00 00 00       	call   80113b <cprintf>
  801098:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109b:	cc                   	int3   
  80109c:	eb fd                	jmp    80109b <_panic+0x47>

0080109e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80109e:	f3 0f 1e fb          	endbr32 
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ac:	8b 13                	mov    (%ebx),%edx
  8010ae:	8d 42 01             	lea    0x1(%edx),%eax
  8010b1:	89 03                	mov    %eax,(%ebx)
  8010b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010bf:	74 09                	je     8010ca <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010c1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010ca:	83 ec 08             	sub    $0x8,%esp
  8010cd:	68 ff 00 00 00       	push   $0xff
  8010d2:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d5:	50                   	push   %eax
  8010d6:	e8 28 f0 ff ff       	call   800103 <sys_cputs>
		b->idx = 0;
  8010db:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	eb db                	jmp    8010c1 <putch+0x23>

008010e6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e6:	f3 0f 1e fb          	endbr32 
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010fa:	00 00 00 
	b.cnt = 0;
  8010fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801104:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801107:	ff 75 0c             	pushl  0xc(%ebp)
  80110a:	ff 75 08             	pushl  0x8(%ebp)
  80110d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801113:	50                   	push   %eax
  801114:	68 9e 10 80 00       	push   $0x80109e
  801119:	e8 80 01 00 00       	call   80129e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80111e:	83 c4 08             	add    $0x8,%esp
  801121:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	e8 d0 ef ff ff       	call   800103 <sys_cputs>

	return b.cnt;
}
  801133:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80113b:	f3 0f 1e fb          	endbr32 
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801145:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801148:	50                   	push   %eax
  801149:	ff 75 08             	pushl  0x8(%ebp)
  80114c:	e8 95 ff ff ff       	call   8010e6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
  801159:	83 ec 1c             	sub    $0x1c,%esp
  80115c:	89 c7                	mov    %eax,%edi
  80115e:	89 d6                	mov    %edx,%esi
  801160:	8b 45 08             	mov    0x8(%ebp),%eax
  801163:	8b 55 0c             	mov    0xc(%ebp),%edx
  801166:	89 d1                	mov    %edx,%ecx
  801168:	89 c2                	mov    %eax,%edx
  80116a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80116d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801170:	8b 45 10             	mov    0x10(%ebp),%eax
  801173:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801176:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801179:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801180:	39 c2                	cmp    %eax,%edx
  801182:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801185:	72 3e                	jb     8011c5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801187:	83 ec 0c             	sub    $0xc,%esp
  80118a:	ff 75 18             	pushl  0x18(%ebp)
  80118d:	83 eb 01             	sub    $0x1,%ebx
  801190:	53                   	push   %ebx
  801191:	50                   	push   %eax
  801192:	83 ec 08             	sub    $0x8,%esp
  801195:	ff 75 e4             	pushl  -0x1c(%ebp)
  801198:	ff 75 e0             	pushl  -0x20(%ebp)
  80119b:	ff 75 dc             	pushl  -0x24(%ebp)
  80119e:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a1:	e8 ca 09 00 00       	call   801b70 <__udivdi3>
  8011a6:	83 c4 18             	add    $0x18,%esp
  8011a9:	52                   	push   %edx
  8011aa:	50                   	push   %eax
  8011ab:	89 f2                	mov    %esi,%edx
  8011ad:	89 f8                	mov    %edi,%eax
  8011af:	e8 9f ff ff ff       	call   801153 <printnum>
  8011b4:	83 c4 20             	add    $0x20,%esp
  8011b7:	eb 13                	jmp    8011cc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b9:	83 ec 08             	sub    $0x8,%esp
  8011bc:	56                   	push   %esi
  8011bd:	ff 75 18             	pushl  0x18(%ebp)
  8011c0:	ff d7                	call   *%edi
  8011c2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011c5:	83 eb 01             	sub    $0x1,%ebx
  8011c8:	85 db                	test   %ebx,%ebx
  8011ca:	7f ed                	jg     8011b9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011cc:	83 ec 08             	sub    $0x8,%esp
  8011cf:	56                   	push   %esi
  8011d0:	83 ec 04             	sub    $0x4,%esp
  8011d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8011dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8011df:	e8 9c 0a 00 00       	call   801c80 <__umoddi3>
  8011e4:	83 c4 14             	add    $0x14,%esp
  8011e7:	0f be 80 2b 1f 80 00 	movsbl 0x801f2b(%eax),%eax
  8011ee:	50                   	push   %eax
  8011ef:	ff d7                	call   *%edi
}
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f7:	5b                   	pop    %ebx
  8011f8:	5e                   	pop    %esi
  8011f9:	5f                   	pop    %edi
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8011fc:	83 fa 01             	cmp    $0x1,%edx
  8011ff:	7f 13                	jg     801214 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801201:	85 d2                	test   %edx,%edx
  801203:	74 1c                	je     801221 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801205:	8b 10                	mov    (%eax),%edx
  801207:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120a:	89 08                	mov    %ecx,(%eax)
  80120c:	8b 02                	mov    (%edx),%eax
  80120e:	ba 00 00 00 00       	mov    $0x0,%edx
  801213:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801214:	8b 10                	mov    (%eax),%edx
  801216:	8d 4a 08             	lea    0x8(%edx),%ecx
  801219:	89 08                	mov    %ecx,(%eax)
  80121b:	8b 02                	mov    (%edx),%eax
  80121d:	8b 52 04             	mov    0x4(%edx),%edx
  801220:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801221:	8b 10                	mov    (%eax),%edx
  801223:	8d 4a 04             	lea    0x4(%edx),%ecx
  801226:	89 08                	mov    %ecx,(%eax)
  801228:	8b 02                	mov    (%edx),%eax
  80122a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80122f:	c3                   	ret    

00801230 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801230:	83 fa 01             	cmp    $0x1,%edx
  801233:	7f 0f                	jg     801244 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801235:	85 d2                	test   %edx,%edx
  801237:	74 18                	je     801251 <getint+0x21>
		return va_arg(*ap, long);
  801239:	8b 10                	mov    (%eax),%edx
  80123b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123e:	89 08                	mov    %ecx,(%eax)
  801240:	8b 02                	mov    (%edx),%eax
  801242:	99                   	cltd   
  801243:	c3                   	ret    
		return va_arg(*ap, long long);
  801244:	8b 10                	mov    (%eax),%edx
  801246:	8d 4a 08             	lea    0x8(%edx),%ecx
  801249:	89 08                	mov    %ecx,(%eax)
  80124b:	8b 02                	mov    (%edx),%eax
  80124d:	8b 52 04             	mov    0x4(%edx),%edx
  801250:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801251:	8b 10                	mov    (%eax),%edx
  801253:	8d 4a 04             	lea    0x4(%edx),%ecx
  801256:	89 08                	mov    %ecx,(%eax)
  801258:	8b 02                	mov    (%edx),%eax
  80125a:	99                   	cltd   
}
  80125b:	c3                   	ret    

0080125c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80125c:	f3 0f 1e fb          	endbr32 
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801266:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80126a:	8b 10                	mov    (%eax),%edx
  80126c:	3b 50 04             	cmp    0x4(%eax),%edx
  80126f:	73 0a                	jae    80127b <sprintputch+0x1f>
		*b->buf++ = ch;
  801271:	8d 4a 01             	lea    0x1(%edx),%ecx
  801274:	89 08                	mov    %ecx,(%eax)
  801276:	8b 45 08             	mov    0x8(%ebp),%eax
  801279:	88 02                	mov    %al,(%edx)
}
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <printfmt>:
{
  80127d:	f3 0f 1e fb          	endbr32 
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801287:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80128a:	50                   	push   %eax
  80128b:	ff 75 10             	pushl  0x10(%ebp)
  80128e:	ff 75 0c             	pushl  0xc(%ebp)
  801291:	ff 75 08             	pushl  0x8(%ebp)
  801294:	e8 05 00 00 00       	call   80129e <vprintfmt>
}
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    

0080129e <vprintfmt>:
{
  80129e:	f3 0f 1e fb          	endbr32 
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 2c             	sub    $0x2c,%esp
  8012ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012b4:	e9 86 02 00 00       	jmp    80153f <vprintfmt+0x2a1>
		padc = ' ';
  8012b9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012bd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012c4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012cb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012d2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012d7:	8d 47 01             	lea    0x1(%edi),%eax
  8012da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012dd:	0f b6 17             	movzbl (%edi),%edx
  8012e0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012e3:	3c 55                	cmp    $0x55,%al
  8012e5:	0f 87 df 02 00 00    	ja     8015ca <vprintfmt+0x32c>
  8012eb:	0f b6 c0             	movzbl %al,%eax
  8012ee:	3e ff 24 85 60 20 80 	notrack jmp *0x802060(,%eax,4)
  8012f5:	00 
  8012f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012f9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8012fd:	eb d8                	jmp    8012d7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8012ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801302:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801306:	eb cf                	jmp    8012d7 <vprintfmt+0x39>
  801308:	0f b6 d2             	movzbl %dl,%edx
  80130b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80130e:	b8 00 00 00 00       	mov    $0x0,%eax
  801313:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801316:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801319:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80131d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801320:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801323:	83 f9 09             	cmp    $0x9,%ecx
  801326:	77 52                	ja     80137a <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801328:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80132b:	eb e9                	jmp    801316 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80132d:	8b 45 14             	mov    0x14(%ebp),%eax
  801330:	8d 50 04             	lea    0x4(%eax),%edx
  801333:	89 55 14             	mov    %edx,0x14(%ebp)
  801336:	8b 00                	mov    (%eax),%eax
  801338:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80133b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80133e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801342:	79 93                	jns    8012d7 <vprintfmt+0x39>
				width = precision, precision = -1;
  801344:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801347:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80134a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801351:	eb 84                	jmp    8012d7 <vprintfmt+0x39>
  801353:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801356:	85 c0                	test   %eax,%eax
  801358:	ba 00 00 00 00       	mov    $0x0,%edx
  80135d:	0f 49 d0             	cmovns %eax,%edx
  801360:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801366:	e9 6c ff ff ff       	jmp    8012d7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80136b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80136e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801375:	e9 5d ff ff ff       	jmp    8012d7 <vprintfmt+0x39>
  80137a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80137d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801380:	eb bc                	jmp    80133e <vprintfmt+0xa0>
			lflag++;
  801382:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801388:	e9 4a ff ff ff       	jmp    8012d7 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80138d:	8b 45 14             	mov    0x14(%ebp),%eax
  801390:	8d 50 04             	lea    0x4(%eax),%edx
  801393:	89 55 14             	mov    %edx,0x14(%ebp)
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	56                   	push   %esi
  80139a:	ff 30                	pushl  (%eax)
  80139c:	ff d3                	call   *%ebx
			break;
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	e9 96 01 00 00       	jmp    80153c <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a9:	8d 50 04             	lea    0x4(%eax),%edx
  8013ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8013af:	8b 00                	mov    (%eax),%eax
  8013b1:	99                   	cltd   
  8013b2:	31 d0                	xor    %edx,%eax
  8013b4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013b6:	83 f8 0f             	cmp    $0xf,%eax
  8013b9:	7f 20                	jg     8013db <vprintfmt+0x13d>
  8013bb:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013c2:	85 d2                	test   %edx,%edx
  8013c4:	74 15                	je     8013db <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013c6:	52                   	push   %edx
  8013c7:	68 c1 1e 80 00       	push   $0x801ec1
  8013cc:	56                   	push   %esi
  8013cd:	53                   	push   %ebx
  8013ce:	e8 aa fe ff ff       	call   80127d <printfmt>
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	e9 61 01 00 00       	jmp    80153c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013db:	50                   	push   %eax
  8013dc:	68 43 1f 80 00       	push   $0x801f43
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	e8 95 fe ff ff       	call   80127d <printfmt>
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	e9 4c 01 00 00       	jmp    80153c <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8013f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f3:	8d 50 04             	lea    0x4(%eax),%edx
  8013f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f9:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8013fb:	85 c9                	test   %ecx,%ecx
  8013fd:	b8 3c 1f 80 00       	mov    $0x801f3c,%eax
  801402:	0f 45 c1             	cmovne %ecx,%eax
  801405:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801408:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80140c:	7e 06                	jle    801414 <vprintfmt+0x176>
  80140e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801412:	75 0d                	jne    801421 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801414:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801417:	89 c7                	mov    %eax,%edi
  801419:	03 45 e0             	add    -0x20(%ebp),%eax
  80141c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80141f:	eb 57                	jmp    801478 <vprintfmt+0x1da>
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	ff 75 d8             	pushl  -0x28(%ebp)
  801427:	ff 75 cc             	pushl  -0x34(%ebp)
  80142a:	e8 4f 02 00 00       	call   80167e <strnlen>
  80142f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801432:	29 c2                	sub    %eax,%edx
  801434:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801437:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80143a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80143e:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801441:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801443:	85 db                	test   %ebx,%ebx
  801445:	7e 10                	jle    801457 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	56                   	push   %esi
  80144b:	57                   	push   %edi
  80144c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80144f:	83 eb 01             	sub    $0x1,%ebx
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	eb ec                	jmp    801443 <vprintfmt+0x1a5>
  801457:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80145a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80145d:	85 d2                	test   %edx,%edx
  80145f:	b8 00 00 00 00       	mov    $0x0,%eax
  801464:	0f 49 c2             	cmovns %edx,%eax
  801467:	29 c2                	sub    %eax,%edx
  801469:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80146c:	eb a6                	jmp    801414 <vprintfmt+0x176>
					putch(ch, putdat);
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	56                   	push   %esi
  801472:	52                   	push   %edx
  801473:	ff d3                	call   *%ebx
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80147b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147d:	83 c7 01             	add    $0x1,%edi
  801480:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801484:	0f be d0             	movsbl %al,%edx
  801487:	85 d2                	test   %edx,%edx
  801489:	74 42                	je     8014cd <vprintfmt+0x22f>
  80148b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80148f:	78 06                	js     801497 <vprintfmt+0x1f9>
  801491:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801495:	78 1e                	js     8014b5 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  801497:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80149b:	74 d1                	je     80146e <vprintfmt+0x1d0>
  80149d:	0f be c0             	movsbl %al,%eax
  8014a0:	83 e8 20             	sub    $0x20,%eax
  8014a3:	83 f8 5e             	cmp    $0x5e,%eax
  8014a6:	76 c6                	jbe    80146e <vprintfmt+0x1d0>
					putch('?', putdat);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	56                   	push   %esi
  8014ac:	6a 3f                	push   $0x3f
  8014ae:	ff d3                	call   *%ebx
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	eb c3                	jmp    801478 <vprintfmt+0x1da>
  8014b5:	89 cf                	mov    %ecx,%edi
  8014b7:	eb 0e                	jmp    8014c7 <vprintfmt+0x229>
				putch(' ', putdat);
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	56                   	push   %esi
  8014bd:	6a 20                	push   $0x20
  8014bf:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014c1:	83 ef 01             	sub    $0x1,%edi
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	85 ff                	test   %edi,%edi
  8014c9:	7f ee                	jg     8014b9 <vprintfmt+0x21b>
  8014cb:	eb 6f                	jmp    80153c <vprintfmt+0x29e>
  8014cd:	89 cf                	mov    %ecx,%edi
  8014cf:	eb f6                	jmp    8014c7 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014d1:	89 ca                	mov    %ecx,%edx
  8014d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8014d6:	e8 55 fd ff ff       	call   801230 <getint>
  8014db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014de:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014e1:	85 d2                	test   %edx,%edx
  8014e3:	78 0b                	js     8014f0 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014e5:	89 d1                	mov    %edx,%ecx
  8014e7:	89 c2                	mov    %eax,%edx
			base = 10;
  8014e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ee:	eb 32                	jmp    801522 <vprintfmt+0x284>
				putch('-', putdat);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	56                   	push   %esi
  8014f4:	6a 2d                	push   $0x2d
  8014f6:	ff d3                	call   *%ebx
				num = -(long long) num;
  8014f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014fe:	f7 da                	neg    %edx
  801500:	83 d1 00             	adc    $0x0,%ecx
  801503:	f7 d9                	neg    %ecx
  801505:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801508:	b8 0a 00 00 00       	mov    $0xa,%eax
  80150d:	eb 13                	jmp    801522 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80150f:	89 ca                	mov    %ecx,%edx
  801511:	8d 45 14             	lea    0x14(%ebp),%eax
  801514:	e8 e3 fc ff ff       	call   8011fc <getuint>
  801519:	89 d1                	mov    %edx,%ecx
  80151b:	89 c2                	mov    %eax,%edx
			base = 10;
  80151d:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801522:	83 ec 0c             	sub    $0xc,%esp
  801525:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801529:	57                   	push   %edi
  80152a:	ff 75 e0             	pushl  -0x20(%ebp)
  80152d:	50                   	push   %eax
  80152e:	51                   	push   %ecx
  80152f:	52                   	push   %edx
  801530:	89 f2                	mov    %esi,%edx
  801532:	89 d8                	mov    %ebx,%eax
  801534:	e8 1a fc ff ff       	call   801153 <printnum>
			break;
  801539:	83 c4 20             	add    $0x20,%esp
{
  80153c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80153f:	83 c7 01             	add    $0x1,%edi
  801542:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801546:	83 f8 25             	cmp    $0x25,%eax
  801549:	0f 84 6a fd ff ff    	je     8012b9 <vprintfmt+0x1b>
			if (ch == '\0')
  80154f:	85 c0                	test   %eax,%eax
  801551:	0f 84 93 00 00 00    	je     8015ea <vprintfmt+0x34c>
			putch(ch, putdat);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	56                   	push   %esi
  80155b:	50                   	push   %eax
  80155c:	ff d3                	call   *%ebx
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	eb dc                	jmp    80153f <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801563:	89 ca                	mov    %ecx,%edx
  801565:	8d 45 14             	lea    0x14(%ebp),%eax
  801568:	e8 8f fc ff ff       	call   8011fc <getuint>
  80156d:	89 d1                	mov    %edx,%ecx
  80156f:	89 c2                	mov    %eax,%edx
			base = 8;
  801571:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801576:	eb aa                	jmp    801522 <vprintfmt+0x284>
			putch('0', putdat);
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	56                   	push   %esi
  80157c:	6a 30                	push   $0x30
  80157e:	ff d3                	call   *%ebx
			putch('x', putdat);
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	56                   	push   %esi
  801584:	6a 78                	push   $0x78
  801586:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  801588:	8b 45 14             	mov    0x14(%ebp),%eax
  80158b:	8d 50 04             	lea    0x4(%eax),%edx
  80158e:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801591:	8b 10                	mov    (%eax),%edx
  801593:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801598:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80159b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015a0:	eb 80                	jmp    801522 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015a2:	89 ca                	mov    %ecx,%edx
  8015a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a7:	e8 50 fc ff ff       	call   8011fc <getuint>
  8015ac:	89 d1                	mov    %edx,%ecx
  8015ae:	89 c2                	mov    %eax,%edx
			base = 16;
  8015b0:	b8 10 00 00 00       	mov    $0x10,%eax
  8015b5:	e9 68 ff ff ff       	jmp    801522 <vprintfmt+0x284>
			putch(ch, putdat);
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	56                   	push   %esi
  8015be:	6a 25                	push   $0x25
  8015c0:	ff d3                	call   *%ebx
			break;
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	e9 72 ff ff ff       	jmp    80153c <vprintfmt+0x29e>
			putch('%', putdat);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	56                   	push   %esi
  8015ce:	6a 25                	push   $0x25
  8015d0:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	89 f8                	mov    %edi,%eax
  8015d7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015db:	74 05                	je     8015e2 <vprintfmt+0x344>
  8015dd:	83 e8 01             	sub    $0x1,%eax
  8015e0:	eb f5                	jmp    8015d7 <vprintfmt+0x339>
  8015e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015e5:	e9 52 ff ff ff       	jmp    80153c <vprintfmt+0x29e>
}
  8015ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	5f                   	pop    %edi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015f2:	f3 0f 1e fb          	endbr32 
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	83 ec 18             	sub    $0x18,%esp
  8015fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801602:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801605:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801609:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80160c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801613:	85 c0                	test   %eax,%eax
  801615:	74 26                	je     80163d <vsnprintf+0x4b>
  801617:	85 d2                	test   %edx,%edx
  801619:	7e 22                	jle    80163d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80161b:	ff 75 14             	pushl  0x14(%ebp)
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	68 5c 12 80 00       	push   $0x80125c
  80162a:	e8 6f fc ff ff       	call   80129e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80162f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801632:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801638:	83 c4 10             	add    $0x10,%esp
}
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    
		return -E_INVAL;
  80163d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801642:	eb f7                	jmp    80163b <vsnprintf+0x49>

00801644 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801644:	f3 0f 1e fb          	endbr32 
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80164e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801651:	50                   	push   %eax
  801652:	ff 75 10             	pushl  0x10(%ebp)
  801655:	ff 75 0c             	pushl  0xc(%ebp)
  801658:	ff 75 08             	pushl  0x8(%ebp)
  80165b:	e8 92 ff ff ff       	call   8015f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801662:	f3 0f 1e fb          	endbr32 
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80166c:	b8 00 00 00 00       	mov    $0x0,%eax
  801671:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801675:	74 05                	je     80167c <strlen+0x1a>
		n++;
  801677:	83 c0 01             	add    $0x1,%eax
  80167a:	eb f5                	jmp    801671 <strlen+0xf>
	return n;
}
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80167e:	f3 0f 1e fb          	endbr32 
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801688:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80168b:	b8 00 00 00 00       	mov    $0x0,%eax
  801690:	39 d0                	cmp    %edx,%eax
  801692:	74 0d                	je     8016a1 <strnlen+0x23>
  801694:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801698:	74 05                	je     80169f <strnlen+0x21>
		n++;
  80169a:	83 c0 01             	add    $0x1,%eax
  80169d:	eb f1                	jmp    801690 <strnlen+0x12>
  80169f:	89 c2                	mov    %eax,%edx
	return n;
}
  8016a1:	89 d0                	mov    %edx,%eax
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a5:	f3 0f 1e fb          	endbr32 
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	53                   	push   %ebx
  8016ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016bc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016bf:	83 c0 01             	add    $0x1,%eax
  8016c2:	84 d2                	test   %dl,%dl
  8016c4:	75 f2                	jne    8016b8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016c6:	89 c8                	mov    %ecx,%eax
  8016c8:	5b                   	pop    %ebx
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    

008016cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016cb:	f3 0f 1e fb          	endbr32 
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 10             	sub    $0x10,%esp
  8016d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016d9:	53                   	push   %ebx
  8016da:	e8 83 ff ff ff       	call   801662 <strlen>
  8016df:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016e2:	ff 75 0c             	pushl  0xc(%ebp)
  8016e5:	01 d8                	add    %ebx,%eax
  8016e7:	50                   	push   %eax
  8016e8:	e8 b8 ff ff ff       	call   8016a5 <strcpy>
	return dst;
}
  8016ed:	89 d8                	mov    %ebx,%eax
  8016ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f2:	c9                   	leave  
  8016f3:	c3                   	ret    

008016f4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f4:	f3 0f 1e fb          	endbr32 
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
  8016fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801700:	8b 55 0c             	mov    0xc(%ebp),%edx
  801703:	89 f3                	mov    %esi,%ebx
  801705:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801708:	89 f0                	mov    %esi,%eax
  80170a:	39 d8                	cmp    %ebx,%eax
  80170c:	74 11                	je     80171f <strncpy+0x2b>
		*dst++ = *src;
  80170e:	83 c0 01             	add    $0x1,%eax
  801711:	0f b6 0a             	movzbl (%edx),%ecx
  801714:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801717:	80 f9 01             	cmp    $0x1,%cl
  80171a:	83 da ff             	sbb    $0xffffffff,%edx
  80171d:	eb eb                	jmp    80170a <strncpy+0x16>
	}
	return ret;
}
  80171f:	89 f0                	mov    %esi,%eax
  801721:	5b                   	pop    %ebx
  801722:	5e                   	pop    %esi
  801723:	5d                   	pop    %ebp
  801724:	c3                   	ret    

00801725 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801725:	f3 0f 1e fb          	endbr32 
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	56                   	push   %esi
  80172d:	53                   	push   %ebx
  80172e:	8b 75 08             	mov    0x8(%ebp),%esi
  801731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801734:	8b 55 10             	mov    0x10(%ebp),%edx
  801737:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801739:	85 d2                	test   %edx,%edx
  80173b:	74 21                	je     80175e <strlcpy+0x39>
  80173d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801741:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801743:	39 c2                	cmp    %eax,%edx
  801745:	74 14                	je     80175b <strlcpy+0x36>
  801747:	0f b6 19             	movzbl (%ecx),%ebx
  80174a:	84 db                	test   %bl,%bl
  80174c:	74 0b                	je     801759 <strlcpy+0x34>
			*dst++ = *src++;
  80174e:	83 c1 01             	add    $0x1,%ecx
  801751:	83 c2 01             	add    $0x1,%edx
  801754:	88 5a ff             	mov    %bl,-0x1(%edx)
  801757:	eb ea                	jmp    801743 <strlcpy+0x1e>
  801759:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80175b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80175e:	29 f0                	sub    %esi,%eax
}
  801760:	5b                   	pop    %ebx
  801761:	5e                   	pop    %esi
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801764:	f3 0f 1e fb          	endbr32 
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801771:	0f b6 01             	movzbl (%ecx),%eax
  801774:	84 c0                	test   %al,%al
  801776:	74 0c                	je     801784 <strcmp+0x20>
  801778:	3a 02                	cmp    (%edx),%al
  80177a:	75 08                	jne    801784 <strcmp+0x20>
		p++, q++;
  80177c:	83 c1 01             	add    $0x1,%ecx
  80177f:	83 c2 01             	add    $0x1,%edx
  801782:	eb ed                	jmp    801771 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801784:	0f b6 c0             	movzbl %al,%eax
  801787:	0f b6 12             	movzbl (%edx),%edx
  80178a:	29 d0                	sub    %edx,%eax
}
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80178e:	f3 0f 1e fb          	endbr32 
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	53                   	push   %ebx
  801796:	8b 45 08             	mov    0x8(%ebp),%eax
  801799:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179c:	89 c3                	mov    %eax,%ebx
  80179e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017a1:	eb 06                	jmp    8017a9 <strncmp+0x1b>
		n--, p++, q++;
  8017a3:	83 c0 01             	add    $0x1,%eax
  8017a6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017a9:	39 d8                	cmp    %ebx,%eax
  8017ab:	74 16                	je     8017c3 <strncmp+0x35>
  8017ad:	0f b6 08             	movzbl (%eax),%ecx
  8017b0:	84 c9                	test   %cl,%cl
  8017b2:	74 04                	je     8017b8 <strncmp+0x2a>
  8017b4:	3a 0a                	cmp    (%edx),%cl
  8017b6:	74 eb                	je     8017a3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b8:	0f b6 00             	movzbl (%eax),%eax
  8017bb:	0f b6 12             	movzbl (%edx),%edx
  8017be:	29 d0                	sub    %edx,%eax
}
  8017c0:	5b                   	pop    %ebx
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    
		return 0;
  8017c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c8:	eb f6                	jmp    8017c0 <strncmp+0x32>

008017ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ca:	f3 0f 1e fb          	endbr32 
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017d8:	0f b6 10             	movzbl (%eax),%edx
  8017db:	84 d2                	test   %dl,%dl
  8017dd:	74 09                	je     8017e8 <strchr+0x1e>
		if (*s == c)
  8017df:	38 ca                	cmp    %cl,%dl
  8017e1:	74 0a                	je     8017ed <strchr+0x23>
	for (; *s; s++)
  8017e3:	83 c0 01             	add    $0x1,%eax
  8017e6:	eb f0                	jmp    8017d8 <strchr+0xe>
			return (char *) s;
	return 0;
  8017e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    

008017ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ef:	f3 0f 1e fb          	endbr32 
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801800:	38 ca                	cmp    %cl,%dl
  801802:	74 09                	je     80180d <strfind+0x1e>
  801804:	84 d2                	test   %dl,%dl
  801806:	74 05                	je     80180d <strfind+0x1e>
	for (; *s; s++)
  801808:	83 c0 01             	add    $0x1,%eax
  80180b:	eb f0                	jmp    8017fd <strfind+0xe>
			break;
	return (char *) s;
}
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80180f:	f3 0f 1e fb          	endbr32 
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	57                   	push   %edi
  801817:	56                   	push   %esi
  801818:	53                   	push   %ebx
  801819:	8b 55 08             	mov    0x8(%ebp),%edx
  80181c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80181f:	85 c9                	test   %ecx,%ecx
  801821:	74 33                	je     801856 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801823:	89 d0                	mov    %edx,%eax
  801825:	09 c8                	or     %ecx,%eax
  801827:	a8 03                	test   $0x3,%al
  801829:	75 23                	jne    80184e <memset+0x3f>
		c &= 0xFF;
  80182b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80182f:	89 d8                	mov    %ebx,%eax
  801831:	c1 e0 08             	shl    $0x8,%eax
  801834:	89 df                	mov    %ebx,%edi
  801836:	c1 e7 18             	shl    $0x18,%edi
  801839:	89 de                	mov    %ebx,%esi
  80183b:	c1 e6 10             	shl    $0x10,%esi
  80183e:	09 f7                	or     %esi,%edi
  801840:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801842:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801845:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801847:	89 d7                	mov    %edx,%edi
  801849:	fc                   	cld    
  80184a:	f3 ab                	rep stos %eax,%es:(%edi)
  80184c:	eb 08                	jmp    801856 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80184e:	89 d7                	mov    %edx,%edi
  801850:	8b 45 0c             	mov    0xc(%ebp),%eax
  801853:	fc                   	cld    
  801854:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801856:	89 d0                	mov    %edx,%eax
  801858:	5b                   	pop    %ebx
  801859:	5e                   	pop    %esi
  80185a:	5f                   	pop    %edi
  80185b:	5d                   	pop    %ebp
  80185c:	c3                   	ret    

0080185d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80185d:	f3 0f 1e fb          	endbr32 
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	57                   	push   %edi
  801865:	56                   	push   %esi
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	8b 75 0c             	mov    0xc(%ebp),%esi
  80186c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80186f:	39 c6                	cmp    %eax,%esi
  801871:	73 32                	jae    8018a5 <memmove+0x48>
  801873:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801876:	39 c2                	cmp    %eax,%edx
  801878:	76 2b                	jbe    8018a5 <memmove+0x48>
		s += n;
		d += n;
  80187a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80187d:	89 fe                	mov    %edi,%esi
  80187f:	09 ce                	or     %ecx,%esi
  801881:	09 d6                	or     %edx,%esi
  801883:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801889:	75 0e                	jne    801899 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80188b:	83 ef 04             	sub    $0x4,%edi
  80188e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801891:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801894:	fd                   	std    
  801895:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801897:	eb 09                	jmp    8018a2 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801899:	83 ef 01             	sub    $0x1,%edi
  80189c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80189f:	fd                   	std    
  8018a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018a2:	fc                   	cld    
  8018a3:	eb 1a                	jmp    8018bf <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a5:	89 c2                	mov    %eax,%edx
  8018a7:	09 ca                	or     %ecx,%edx
  8018a9:	09 f2                	or     %esi,%edx
  8018ab:	f6 c2 03             	test   $0x3,%dl
  8018ae:	75 0a                	jne    8018ba <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018b0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018b3:	89 c7                	mov    %eax,%edi
  8018b5:	fc                   	cld    
  8018b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b8:	eb 05                	jmp    8018bf <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018ba:	89 c7                	mov    %eax,%edi
  8018bc:	fc                   	cld    
  8018bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018bf:	5e                   	pop    %esi
  8018c0:	5f                   	pop    %edi
  8018c1:	5d                   	pop    %ebp
  8018c2:	c3                   	ret    

008018c3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018c3:	f3 0f 1e fb          	endbr32 
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018cd:	ff 75 10             	pushl  0x10(%ebp)
  8018d0:	ff 75 0c             	pushl  0xc(%ebp)
  8018d3:	ff 75 08             	pushl  0x8(%ebp)
  8018d6:	e8 82 ff ff ff       	call   80185d <memmove>
}
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018dd:	f3 0f 1e fb          	endbr32 
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	56                   	push   %esi
  8018e5:	53                   	push   %ebx
  8018e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ec:	89 c6                	mov    %eax,%esi
  8018ee:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f1:	39 f0                	cmp    %esi,%eax
  8018f3:	74 1c                	je     801911 <memcmp+0x34>
		if (*s1 != *s2)
  8018f5:	0f b6 08             	movzbl (%eax),%ecx
  8018f8:	0f b6 1a             	movzbl (%edx),%ebx
  8018fb:	38 d9                	cmp    %bl,%cl
  8018fd:	75 08                	jne    801907 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018ff:	83 c0 01             	add    $0x1,%eax
  801902:	83 c2 01             	add    $0x1,%edx
  801905:	eb ea                	jmp    8018f1 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801907:	0f b6 c1             	movzbl %cl,%eax
  80190a:	0f b6 db             	movzbl %bl,%ebx
  80190d:	29 d8                	sub    %ebx,%eax
  80190f:	eb 05                	jmp    801916 <memcmp+0x39>
	}

	return 0;
  801911:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801916:	5b                   	pop    %ebx
  801917:	5e                   	pop    %esi
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80191a:	f3 0f 1e fb          	endbr32 
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
  801924:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801927:	89 c2                	mov    %eax,%edx
  801929:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80192c:	39 d0                	cmp    %edx,%eax
  80192e:	73 09                	jae    801939 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801930:	38 08                	cmp    %cl,(%eax)
  801932:	74 05                	je     801939 <memfind+0x1f>
	for (; s < ends; s++)
  801934:	83 c0 01             	add    $0x1,%eax
  801937:	eb f3                	jmp    80192c <memfind+0x12>
			break;
	return (void *) s;
}
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80193b:	f3 0f 1e fb          	endbr32 
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	57                   	push   %edi
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801948:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194b:	eb 03                	jmp    801950 <strtol+0x15>
		s++;
  80194d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801950:	0f b6 01             	movzbl (%ecx),%eax
  801953:	3c 20                	cmp    $0x20,%al
  801955:	74 f6                	je     80194d <strtol+0x12>
  801957:	3c 09                	cmp    $0x9,%al
  801959:	74 f2                	je     80194d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80195b:	3c 2b                	cmp    $0x2b,%al
  80195d:	74 2a                	je     801989 <strtol+0x4e>
	int neg = 0;
  80195f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801964:	3c 2d                	cmp    $0x2d,%al
  801966:	74 2b                	je     801993 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801968:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80196e:	75 0f                	jne    80197f <strtol+0x44>
  801970:	80 39 30             	cmpb   $0x30,(%ecx)
  801973:	74 28                	je     80199d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801975:	85 db                	test   %ebx,%ebx
  801977:	b8 0a 00 00 00       	mov    $0xa,%eax
  80197c:	0f 44 d8             	cmove  %eax,%ebx
  80197f:	b8 00 00 00 00       	mov    $0x0,%eax
  801984:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801987:	eb 46                	jmp    8019cf <strtol+0x94>
		s++;
  801989:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80198c:	bf 00 00 00 00       	mov    $0x0,%edi
  801991:	eb d5                	jmp    801968 <strtol+0x2d>
		s++, neg = 1;
  801993:	83 c1 01             	add    $0x1,%ecx
  801996:	bf 01 00 00 00       	mov    $0x1,%edi
  80199b:	eb cb                	jmp    801968 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80199d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019a1:	74 0e                	je     8019b1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019a3:	85 db                	test   %ebx,%ebx
  8019a5:	75 d8                	jne    80197f <strtol+0x44>
		s++, base = 8;
  8019a7:	83 c1 01             	add    $0x1,%ecx
  8019aa:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019af:	eb ce                	jmp    80197f <strtol+0x44>
		s += 2, base = 16;
  8019b1:	83 c1 02             	add    $0x2,%ecx
  8019b4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019b9:	eb c4                	jmp    80197f <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019bb:	0f be d2             	movsbl %dl,%edx
  8019be:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019c1:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019c4:	7d 3a                	jge    801a00 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019c6:	83 c1 01             	add    $0x1,%ecx
  8019c9:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019cd:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019cf:	0f b6 11             	movzbl (%ecx),%edx
  8019d2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019d5:	89 f3                	mov    %esi,%ebx
  8019d7:	80 fb 09             	cmp    $0x9,%bl
  8019da:	76 df                	jbe    8019bb <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019dc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019df:	89 f3                	mov    %esi,%ebx
  8019e1:	80 fb 19             	cmp    $0x19,%bl
  8019e4:	77 08                	ja     8019ee <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019e6:	0f be d2             	movsbl %dl,%edx
  8019e9:	83 ea 57             	sub    $0x57,%edx
  8019ec:	eb d3                	jmp    8019c1 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8019ee:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019f1:	89 f3                	mov    %esi,%ebx
  8019f3:	80 fb 19             	cmp    $0x19,%bl
  8019f6:	77 08                	ja     801a00 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019f8:	0f be d2             	movsbl %dl,%edx
  8019fb:	83 ea 37             	sub    $0x37,%edx
  8019fe:	eb c1                	jmp    8019c1 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a04:	74 05                	je     801a0b <strtol+0xd0>
		*endptr = (char *) s;
  801a06:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a09:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a0b:	89 c2                	mov    %eax,%edx
  801a0d:	f7 da                	neg    %edx
  801a0f:	85 ff                	test   %edi,%edi
  801a11:	0f 45 c2             	cmovne %edx,%eax
}
  801a14:	5b                   	pop    %ebx
  801a15:	5e                   	pop    %esi
  801a16:	5f                   	pop    %edi
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    

00801a19 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a19:	f3 0f 1e fb          	endbr32 
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	8b 75 08             	mov    0x8(%ebp),%esi
  801a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a32:	0f 44 c2             	cmove  %edx,%eax
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	50                   	push   %eax
  801a39:	e8 a7 e8 ff ff       	call   8002e5 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 f6                	test   %esi,%esi
  801a43:	74 15                	je     801a5a <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801a45:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4a:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a4d:	74 09                	je     801a58 <ipc_recv+0x3f>
  801a4f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a55:	8b 52 74             	mov    0x74(%edx),%edx
  801a58:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801a5a:	85 db                	test   %ebx,%ebx
  801a5c:	74 15                	je     801a73 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801a5e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a63:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a66:	74 09                	je     801a71 <ipc_recv+0x58>
  801a68:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a6e:	8b 52 78             	mov    0x78(%edx),%edx
  801a71:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801a73:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a76:	74 08                	je     801a80 <ipc_recv+0x67>
  801a78:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a83:	5b                   	pop    %ebx
  801a84:	5e                   	pop    %esi
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a87:	f3 0f 1e fb          	endbr32 
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	57                   	push   %edi
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a97:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a9d:	eb 1f                	jmp    801abe <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801a9f:	6a 00                	push   $0x0
  801aa1:	68 00 00 c0 ee       	push   $0xeec00000
  801aa6:	56                   	push   %esi
  801aa7:	57                   	push   %edi
  801aa8:	e8 0f e8 ff ff       	call   8002bc <sys_ipc_try_send>
  801aad:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	74 30                	je     801ae4 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801ab4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab7:	75 19                	jne    801ad2 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801ab9:	e8 e5 e6 ff ff       	call   8001a3 <sys_yield>
		if (pg != NULL) {
  801abe:	85 db                	test   %ebx,%ebx
  801ac0:	74 dd                	je     801a9f <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801ac2:	ff 75 14             	pushl  0x14(%ebp)
  801ac5:	53                   	push   %ebx
  801ac6:	56                   	push   %esi
  801ac7:	57                   	push   %edi
  801ac8:	e8 ef e7 ff ff       	call   8002bc <sys_ipc_try_send>
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	eb de                	jmp    801ab0 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801ad2:	50                   	push   %eax
  801ad3:	68 1f 22 80 00       	push   $0x80221f
  801ad8:	6a 3e                	push   $0x3e
  801ada:	68 2c 22 80 00       	push   $0x80222c
  801adf:	e8 70 f5 ff ff       	call   801054 <_panic>
	}
}
  801ae4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae7:	5b                   	pop    %ebx
  801ae8:	5e                   	pop    %esi
  801ae9:	5f                   	pop    %edi
  801aea:	5d                   	pop    %ebp
  801aeb:	c3                   	ret    

00801aec <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aec:	f3 0f 1e fb          	endbr32 
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801afb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801afe:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b04:	8b 52 50             	mov    0x50(%edx),%edx
  801b07:	39 ca                	cmp    %ecx,%edx
  801b09:	74 11                	je     801b1c <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b0b:	83 c0 01             	add    $0x1,%eax
  801b0e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b13:	75 e6                	jne    801afb <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1a:	eb 0b                	jmp    801b27 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b1c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b24:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b29:	f3 0f 1e fb          	endbr32 
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b33:	89 c2                	mov    %eax,%edx
  801b35:	c1 ea 16             	shr    $0x16,%edx
  801b38:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b3f:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b44:	f6 c1 01             	test   $0x1,%cl
  801b47:	74 1c                	je     801b65 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b49:	c1 e8 0c             	shr    $0xc,%eax
  801b4c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b53:	a8 01                	test   $0x1,%al
  801b55:	74 0e                	je     801b65 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b57:	c1 e8 0c             	shr    $0xc,%eax
  801b5a:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b61:	ef 
  801b62:	0f b7 d2             	movzwl %dx,%edx
}
  801b65:	89 d0                	mov    %edx,%eax
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    
  801b69:	66 90                	xchg   %ax,%ax
  801b6b:	66 90                	xchg   %ax,%ax
  801b6d:	66 90                	xchg   %ax,%ax
  801b6f:	90                   	nop

00801b70 <__udivdi3>:
  801b70:	f3 0f 1e fb          	endbr32 
  801b74:	55                   	push   %ebp
  801b75:	57                   	push   %edi
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	83 ec 1c             	sub    $0x1c,%esp
  801b7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b83:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b8b:	85 d2                	test   %edx,%edx
  801b8d:	75 19                	jne    801ba8 <__udivdi3+0x38>
  801b8f:	39 f3                	cmp    %esi,%ebx
  801b91:	76 4d                	jbe    801be0 <__udivdi3+0x70>
  801b93:	31 ff                	xor    %edi,%edi
  801b95:	89 e8                	mov    %ebp,%eax
  801b97:	89 f2                	mov    %esi,%edx
  801b99:	f7 f3                	div    %ebx
  801b9b:	89 fa                	mov    %edi,%edx
  801b9d:	83 c4 1c             	add    $0x1c,%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    
  801ba5:	8d 76 00             	lea    0x0(%esi),%esi
  801ba8:	39 f2                	cmp    %esi,%edx
  801baa:	76 14                	jbe    801bc0 <__udivdi3+0x50>
  801bac:	31 ff                	xor    %edi,%edi
  801bae:	31 c0                	xor    %eax,%eax
  801bb0:	89 fa                	mov    %edi,%edx
  801bb2:	83 c4 1c             	add    $0x1c,%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5f                   	pop    %edi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    
  801bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc0:	0f bd fa             	bsr    %edx,%edi
  801bc3:	83 f7 1f             	xor    $0x1f,%edi
  801bc6:	75 48                	jne    801c10 <__udivdi3+0xa0>
  801bc8:	39 f2                	cmp    %esi,%edx
  801bca:	72 06                	jb     801bd2 <__udivdi3+0x62>
  801bcc:	31 c0                	xor    %eax,%eax
  801bce:	39 eb                	cmp    %ebp,%ebx
  801bd0:	77 de                	ja     801bb0 <__udivdi3+0x40>
  801bd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd7:	eb d7                	jmp    801bb0 <__udivdi3+0x40>
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 d9                	mov    %ebx,%ecx
  801be2:	85 db                	test   %ebx,%ebx
  801be4:	75 0b                	jne    801bf1 <__udivdi3+0x81>
  801be6:	b8 01 00 00 00       	mov    $0x1,%eax
  801beb:	31 d2                	xor    %edx,%edx
  801bed:	f7 f3                	div    %ebx
  801bef:	89 c1                	mov    %eax,%ecx
  801bf1:	31 d2                	xor    %edx,%edx
  801bf3:	89 f0                	mov    %esi,%eax
  801bf5:	f7 f1                	div    %ecx
  801bf7:	89 c6                	mov    %eax,%esi
  801bf9:	89 e8                	mov    %ebp,%eax
  801bfb:	89 f7                	mov    %esi,%edi
  801bfd:	f7 f1                	div    %ecx
  801bff:	89 fa                	mov    %edi,%edx
  801c01:	83 c4 1c             	add    $0x1c,%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5f                   	pop    %edi
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	89 f9                	mov    %edi,%ecx
  801c12:	b8 20 00 00 00       	mov    $0x20,%eax
  801c17:	29 f8                	sub    %edi,%eax
  801c19:	d3 e2                	shl    %cl,%edx
  801c1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c1f:	89 c1                	mov    %eax,%ecx
  801c21:	89 da                	mov    %ebx,%edx
  801c23:	d3 ea                	shr    %cl,%edx
  801c25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c29:	09 d1                	or     %edx,%ecx
  801c2b:	89 f2                	mov    %esi,%edx
  801c2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e3                	shl    %cl,%ebx
  801c35:	89 c1                	mov    %eax,%ecx
  801c37:	d3 ea                	shr    %cl,%edx
  801c39:	89 f9                	mov    %edi,%ecx
  801c3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c3f:	89 eb                	mov    %ebp,%ebx
  801c41:	d3 e6                	shl    %cl,%esi
  801c43:	89 c1                	mov    %eax,%ecx
  801c45:	d3 eb                	shr    %cl,%ebx
  801c47:	09 de                	or     %ebx,%esi
  801c49:	89 f0                	mov    %esi,%eax
  801c4b:	f7 74 24 08          	divl   0x8(%esp)
  801c4f:	89 d6                	mov    %edx,%esi
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	f7 64 24 0c          	mull   0xc(%esp)
  801c57:	39 d6                	cmp    %edx,%esi
  801c59:	72 15                	jb     801c70 <__udivdi3+0x100>
  801c5b:	89 f9                	mov    %edi,%ecx
  801c5d:	d3 e5                	shl    %cl,%ebp
  801c5f:	39 c5                	cmp    %eax,%ebp
  801c61:	73 04                	jae    801c67 <__udivdi3+0xf7>
  801c63:	39 d6                	cmp    %edx,%esi
  801c65:	74 09                	je     801c70 <__udivdi3+0x100>
  801c67:	89 d8                	mov    %ebx,%eax
  801c69:	31 ff                	xor    %edi,%edi
  801c6b:	e9 40 ff ff ff       	jmp    801bb0 <__udivdi3+0x40>
  801c70:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c73:	31 ff                	xor    %edi,%edi
  801c75:	e9 36 ff ff ff       	jmp    801bb0 <__udivdi3+0x40>
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__umoddi3>:
  801c80:	f3 0f 1e fb          	endbr32 
  801c84:	55                   	push   %ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 1c             	sub    $0x1c,%esp
  801c8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c8f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c93:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c97:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	75 19                	jne    801cb8 <__umoddi3+0x38>
  801c9f:	39 df                	cmp    %ebx,%edi
  801ca1:	76 5d                	jbe    801d00 <__umoddi3+0x80>
  801ca3:	89 f0                	mov    %esi,%eax
  801ca5:	89 da                	mov    %ebx,%edx
  801ca7:	f7 f7                	div    %edi
  801ca9:	89 d0                	mov    %edx,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	83 c4 1c             	add    $0x1c,%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	39 d8                	cmp    %ebx,%eax
  801cbc:	76 12                	jbe    801cd0 <__umoddi3+0x50>
  801cbe:	89 f0                	mov    %esi,%eax
  801cc0:	89 da                	mov    %ebx,%edx
  801cc2:	83 c4 1c             	add    $0x1c,%esp
  801cc5:	5b                   	pop    %ebx
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    
  801cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd0:	0f bd e8             	bsr    %eax,%ebp
  801cd3:	83 f5 1f             	xor    $0x1f,%ebp
  801cd6:	75 50                	jne    801d28 <__umoddi3+0xa8>
  801cd8:	39 d8                	cmp    %ebx,%eax
  801cda:	0f 82 e0 00 00 00    	jb     801dc0 <__umoddi3+0x140>
  801ce0:	89 d9                	mov    %ebx,%ecx
  801ce2:	39 f7                	cmp    %esi,%edi
  801ce4:	0f 86 d6 00 00 00    	jbe    801dc0 <__umoddi3+0x140>
  801cea:	89 d0                	mov    %edx,%eax
  801cec:	89 ca                	mov    %ecx,%edx
  801cee:	83 c4 1c             	add    $0x1c,%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5f                   	pop    %edi
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    
  801cf6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cfd:	8d 76 00             	lea    0x0(%esi),%esi
  801d00:	89 fd                	mov    %edi,%ebp
  801d02:	85 ff                	test   %edi,%edi
  801d04:	75 0b                	jne    801d11 <__umoddi3+0x91>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f7                	div    %edi
  801d0f:	89 c5                	mov    %eax,%ebp
  801d11:	89 d8                	mov    %ebx,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f5                	div    %ebp
  801d17:	89 f0                	mov    %esi,%eax
  801d19:	f7 f5                	div    %ebp
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	eb 8c                	jmp    801cad <__umoddi3+0x2d>
  801d21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d2f:	29 ea                	sub    %ebp,%edx
  801d31:	d3 e0                	shl    %cl,%eax
  801d33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d37:	89 d1                	mov    %edx,%ecx
  801d39:	89 f8                	mov    %edi,%eax
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d45:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d49:	09 c1                	or     %eax,%ecx
  801d4b:	89 d8                	mov    %ebx,%eax
  801d4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d51:	89 e9                	mov    %ebp,%ecx
  801d53:	d3 e7                	shl    %cl,%edi
  801d55:	89 d1                	mov    %edx,%ecx
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d5f:	d3 e3                	shl    %cl,%ebx
  801d61:	89 c7                	mov    %eax,%edi
  801d63:	89 d1                	mov    %edx,%ecx
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	89 fa                	mov    %edi,%edx
  801d6d:	d3 e6                	shl    %cl,%esi
  801d6f:	09 d8                	or     %ebx,%eax
  801d71:	f7 74 24 08          	divl   0x8(%esp)
  801d75:	89 d1                	mov    %edx,%ecx
  801d77:	89 f3                	mov    %esi,%ebx
  801d79:	f7 64 24 0c          	mull   0xc(%esp)
  801d7d:	89 c6                	mov    %eax,%esi
  801d7f:	89 d7                	mov    %edx,%edi
  801d81:	39 d1                	cmp    %edx,%ecx
  801d83:	72 06                	jb     801d8b <__umoddi3+0x10b>
  801d85:	75 10                	jne    801d97 <__umoddi3+0x117>
  801d87:	39 c3                	cmp    %eax,%ebx
  801d89:	73 0c                	jae    801d97 <__umoddi3+0x117>
  801d8b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801d8f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d93:	89 d7                	mov    %edx,%edi
  801d95:	89 c6                	mov    %eax,%esi
  801d97:	89 ca                	mov    %ecx,%edx
  801d99:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d9e:	29 f3                	sub    %esi,%ebx
  801da0:	19 fa                	sbb    %edi,%edx
  801da2:	89 d0                	mov    %edx,%eax
  801da4:	d3 e0                	shl    %cl,%eax
  801da6:	89 e9                	mov    %ebp,%ecx
  801da8:	d3 eb                	shr    %cl,%ebx
  801daa:	d3 ea                	shr    %cl,%edx
  801dac:	09 d8                	or     %ebx,%eax
  801dae:	83 c4 1c             	add    $0x1c,%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5f                   	pop    %edi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    
  801db6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	29 fe                	sub    %edi,%esi
  801dc2:	19 c3                	sbb    %eax,%ebx
  801dc4:	89 f2                	mov    %esi,%edx
  801dc6:	89 d9                	mov    %ebx,%ecx
  801dc8:	e9 1d ff ff ff       	jmp    801cea <__umoddi3+0x6a>
