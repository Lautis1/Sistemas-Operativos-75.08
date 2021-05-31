
obj/user/badsegment.debug:     formato del fichero elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	f3 0f 1e fb          	endbr32 
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80004d:	e8 19 01 00 00       	call   80016b <sys_getenvid>
	if (id >= 0)
  800052:	85 c0                	test   %eax,%eax
  800054:	78 12                	js     800068 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800056:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800063:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800068:	85 db                	test   %ebx,%ebx
  80006a:	7e 07                	jle    800073 <libmain+0x35>
		binaryname = argv[0];
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800073:	83 ec 08             	sub    $0x8,%esp
  800076:	56                   	push   %esi
  800077:	53                   	push   %ebx
  800078:	e8 b6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007d:	e8 0a 00 00 00       	call   80008c <exit>
}
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800088:	5b                   	pop    %ebx
  800089:	5e                   	pop    %esi
  80008a:	5d                   	pop    %ebp
  80008b:	c3                   	ret    

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	f3 0f 1e fb          	endbr32 
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 53 04 00 00       	call   8004ee <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 a0 00 00 00       	call   800145 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 1c             	sub    $0x1c,%esp
  8000b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b9:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c4:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cd:	74 04                	je     8000d3 <syscall+0x29>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f 08                	jg     8000db <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	50                   	push   %eax
  8000df:	ff 75 e0             	pushl  -0x20(%ebp)
  8000e2:	68 ca 1d 80 00       	push   $0x801dca
  8000e7:	6a 23                	push   $0x23
  8000e9:	68 e7 1d 80 00       	push   $0x801de7
  8000ee:	e8 51 0f 00 00       	call   801044 <_panic>

008000f3 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000f3:	f3 0f 1e fb          	endbr32 
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000fd:	6a 00                	push   $0x0
  8000ff:	6a 00                	push   $0x0
  800101:	6a 00                	push   $0x0
  800103:	ff 75 0c             	pushl  0xc(%ebp)
  800106:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800109:	ba 00 00 00 00       	mov    $0x0,%edx
  80010e:	b8 00 00 00 00       	mov    $0x0,%eax
  800113:	e8 92 ff ff ff       	call   8000aa <syscall>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    

0080011d <sys_cgetc>:

int
sys_cgetc(void)
{
  80011d:	f3 0f 1e fb          	endbr32 
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800127:	6a 00                	push   $0x0
  800129:	6a 00                	push   $0x0
  80012b:	6a 00                	push   $0x0
  80012d:	6a 00                	push   $0x0
  80012f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 01 00 00 00       	mov    $0x1,%eax
  80013e:	e8 67 ff ff ff       	call   8000aa <syscall>
}
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800145:	f3 0f 1e fb          	endbr32 
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014f:	6a 00                	push   $0x0
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	6a 00                	push   $0x0
  800157:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015a:	ba 01 00 00 00       	mov    $0x1,%edx
  80015f:	b8 03 00 00 00       	mov    $0x3,%eax
  800164:	e8 41 ff ff ff       	call   8000aa <syscall>
}
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016b:	f3 0f 1e fb          	endbr32 
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800175:	6a 00                	push   $0x0
  800177:	6a 00                	push   $0x0
  800179:	6a 00                	push   $0x0
  80017b:	6a 00                	push   $0x0
  80017d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800182:	ba 00 00 00 00       	mov    $0x0,%edx
  800187:	b8 02 00 00 00       	mov    $0x2,%eax
  80018c:	e8 19 ff ff ff       	call   8000aa <syscall>
}
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <sys_yield>:

void
sys_yield(void)
{
  800193:	f3 0f 1e fb          	endbr32 
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80019d:	6a 00                	push   $0x0
  80019f:	6a 00                	push   $0x0
  8001a1:	6a 00                	push   $0x0
  8001a3:	6a 00                	push   $0x0
  8001a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8001af:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b4:	e8 f1 fe ff ff       	call   8000aa <syscall>
}
  8001b9:	83 c4 10             	add    $0x10,%esp
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001be:	f3 0f 1e fb          	endbr32 
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001c8:	6a 00                	push   $0x0
  8001ca:	6a 00                	push   $0x0
  8001cc:	ff 75 10             	pushl  0x10(%ebp)
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001da:	b8 04 00 00 00       	mov    $0x4,%eax
  8001df:	e8 c6 fe ff ff       	call   8000aa <syscall>
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e6:	f3 0f 1e fb          	endbr32 
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001f0:	ff 75 18             	pushl  0x18(%ebp)
  8001f3:	ff 75 14             	pushl  0x14(%ebp)
  8001f6:	ff 75 10             	pushl  0x10(%ebp)
  8001f9:	ff 75 0c             	pushl  0xc(%ebp)
  8001fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ff:	ba 01 00 00 00       	mov    $0x1,%edx
  800204:	b8 05 00 00 00       	mov    $0x5,%eax
  800209:	e8 9c fe ff ff       	call   8000aa <syscall>
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800210:	f3 0f 1e fb          	endbr32 
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80021a:	6a 00                	push   $0x0
  80021c:	6a 00                	push   $0x0
  80021e:	6a 00                	push   $0x0
  800220:	ff 75 0c             	pushl  0xc(%ebp)
  800223:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800226:	ba 01 00 00 00       	mov    $0x1,%edx
  80022b:	b8 06 00 00 00       	mov    $0x6,%eax
  800230:	e8 75 fe ff ff       	call   8000aa <syscall>
}
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	f3 0f 1e fb          	endbr32 
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800241:	6a 00                	push   $0x0
  800243:	6a 00                	push   $0x0
  800245:	6a 00                	push   $0x0
  800247:	ff 75 0c             	pushl  0xc(%ebp)
  80024a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024d:	ba 01 00 00 00       	mov    $0x1,%edx
  800252:	b8 08 00 00 00       	mov    $0x8,%eax
  800257:	e8 4e fe ff ff       	call   8000aa <syscall>
}
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	f3 0f 1e fb          	endbr32 
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800268:	6a 00                	push   $0x0
  80026a:	6a 00                	push   $0x0
  80026c:	6a 00                	push   $0x0
  80026e:	ff 75 0c             	pushl  0xc(%ebp)
  800271:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800274:	ba 01 00 00 00       	mov    $0x1,%edx
  800279:	b8 09 00 00 00       	mov    $0x9,%eax
  80027e:	e8 27 fe ff ff       	call   8000aa <syscall>
}
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800285:	f3 0f 1e fb          	endbr32 
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80028f:	6a 00                	push   $0x0
  800291:	6a 00                	push   $0x0
  800293:	6a 00                	push   $0x0
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029b:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a5:	e8 00 fe ff ff       	call   8000aa <syscall>
}
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ac:	f3 0f 1e fb          	endbr32 
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002b6:	6a 00                	push   $0x0
  8002b8:	ff 75 14             	pushl  0x14(%ebp)
  8002bb:	ff 75 10             	pushl  0x10(%ebp)
  8002be:	ff 75 0c             	pushl  0xc(%ebp)
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ce:	e8 d7 fd ff ff       	call   8000aa <syscall>
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d5:	f3 0f 1e fb          	endbr32 
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002df:	6a 00                	push   $0x0
  8002e1:	6a 00                	push   $0x0
  8002e3:	6a 00                	push   $0x0
  8002e5:	6a 00                	push   $0x0
  8002e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ea:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ef:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002f4:	e8 b1 fd ff ff       	call   8000aa <syscall>
}
  8002f9:	c9                   	leave  
  8002fa:	c3                   	ret    

008002fb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002fb:	f3 0f 1e fb          	endbr32 
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	05 00 00 00 30       	add    $0x30000000,%eax
  80030a:	c1 e8 0c             	shr    $0xc,%eax
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80030f:	f3 0f 1e fb          	endbr32 
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 da ff ff ff       	call   8002fb <fd2num>
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	c1 e0 0c             	shl    $0xc,%eax
  800327:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80032e:	f3 0f 1e fb          	endbr32 
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80033a:	89 c2                	mov    %eax,%edx
  80033c:	c1 ea 16             	shr    $0x16,%edx
  80033f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800346:	f6 c2 01             	test   $0x1,%dl
  800349:	74 2d                	je     800378 <fd_alloc+0x4a>
  80034b:	89 c2                	mov    %eax,%edx
  80034d:	c1 ea 0c             	shr    $0xc,%edx
  800350:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800357:	f6 c2 01             	test   $0x1,%dl
  80035a:	74 1c                	je     800378 <fd_alloc+0x4a>
  80035c:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800361:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800366:	75 d2                	jne    80033a <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800368:	8b 45 08             	mov    0x8(%ebp),%eax
  80036b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800371:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800376:	eb 0a                	jmp    800382 <fd_alloc+0x54>
			*fd_store = fd;
  800378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80037d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800384:	f3 0f 1e fb          	endbr32 
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80038e:	83 f8 1f             	cmp    $0x1f,%eax
  800391:	77 30                	ja     8003c3 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800393:	c1 e0 0c             	shl    $0xc,%eax
  800396:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80039b:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003a1:	f6 c2 01             	test   $0x1,%dl
  8003a4:	74 24                	je     8003ca <fd_lookup+0x46>
  8003a6:	89 c2                	mov    %eax,%edx
  8003a8:	c1 ea 0c             	shr    $0xc,%edx
  8003ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b2:	f6 c2 01             	test   $0x1,%dl
  8003b5:	74 1a                	je     8003d1 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ba:	89 02                	mov    %eax,(%edx)
	return 0;
  8003bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    
		return -E_INVAL;
  8003c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c8:	eb f7                	jmp    8003c1 <fd_lookup+0x3d>
		return -E_INVAL;
  8003ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003cf:	eb f0                	jmp    8003c1 <fd_lookup+0x3d>
  8003d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d6:	eb e9                	jmp    8003c1 <fd_lookup+0x3d>

008003d8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003d8:	f3 0f 1e fb          	endbr32 
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e5:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003ea:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003ef:	39 08                	cmp    %ecx,(%eax)
  8003f1:	74 33                	je     800426 <dev_lookup+0x4e>
  8003f3:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8003f6:	8b 02                	mov    (%edx),%eax
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	75 f3                	jne    8003ef <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003fc:	a1 04 40 80 00       	mov    0x804004,%eax
  800401:	8b 40 48             	mov    0x48(%eax),%eax
  800404:	83 ec 04             	sub    $0x4,%esp
  800407:	51                   	push   %ecx
  800408:	50                   	push   %eax
  800409:	68 f8 1d 80 00       	push   $0x801df8
  80040e:	e8 18 0d 00 00       	call   80112b <cprintf>
	*dev = 0;
  800413:	8b 45 0c             	mov    0xc(%ebp),%eax
  800416:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800424:	c9                   	leave  
  800425:	c3                   	ret    
			*dev = devtab[i];
  800426:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800429:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042b:	b8 00 00 00 00       	mov    $0x0,%eax
  800430:	eb f2                	jmp    800424 <dev_lookup+0x4c>

00800432 <fd_close>:
{
  800432:	f3 0f 1e fb          	endbr32 
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	57                   	push   %edi
  80043a:	56                   	push   %esi
  80043b:	53                   	push   %ebx
  80043c:	83 ec 28             	sub    $0x28,%esp
  80043f:	8b 75 08             	mov    0x8(%ebp),%esi
  800442:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800445:	56                   	push   %esi
  800446:	e8 b0 fe ff ff       	call   8002fb <fd2num>
  80044b:	83 c4 08             	add    $0x8,%esp
  80044e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800451:	52                   	push   %edx
  800452:	50                   	push   %eax
  800453:	e8 2c ff ff ff       	call   800384 <fd_lookup>
  800458:	89 c3                	mov    %eax,%ebx
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	85 c0                	test   %eax,%eax
  80045f:	78 05                	js     800466 <fd_close+0x34>
	    || fd != fd2)
  800461:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800464:	74 16                	je     80047c <fd_close+0x4a>
		return (must_exist ? r : 0);
  800466:	89 f8                	mov    %edi,%eax
  800468:	84 c0                	test   %al,%al
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	0f 44 d8             	cmove  %eax,%ebx
}
  800472:	89 d8                	mov    %ebx,%eax
  800474:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800477:	5b                   	pop    %ebx
  800478:	5e                   	pop    %esi
  800479:	5f                   	pop    %edi
  80047a:	5d                   	pop    %ebp
  80047b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800482:	50                   	push   %eax
  800483:	ff 36                	pushl  (%esi)
  800485:	e8 4e ff ff ff       	call   8003d8 <dev_lookup>
  80048a:	89 c3                	mov    %eax,%ebx
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	85 c0                	test   %eax,%eax
  800491:	78 1a                	js     8004ad <fd_close+0x7b>
		if (dev->dev_close)
  800493:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800496:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800499:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	74 0b                	je     8004ad <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004a2:	83 ec 0c             	sub    $0xc,%esp
  8004a5:	56                   	push   %esi
  8004a6:	ff d0                	call   *%eax
  8004a8:	89 c3                	mov    %eax,%ebx
  8004aa:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	56                   	push   %esi
  8004b1:	6a 00                	push   $0x0
  8004b3:	e8 58 fd ff ff       	call   800210 <sys_page_unmap>
	return r;
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb b5                	jmp    800472 <fd_close+0x40>

008004bd <close>:

int
close(int fdnum)
{
  8004bd:	f3 0f 1e fb          	endbr32 
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	ff 75 08             	pushl  0x8(%ebp)
  8004ce:	e8 b1 fe ff ff       	call   800384 <fd_lookup>
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	79 02                	jns    8004dc <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    
		return fd_close(fd, 1);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	6a 01                	push   $0x1
  8004e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8004e4:	e8 49 ff ff ff       	call   800432 <fd_close>
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	eb ec                	jmp    8004da <close+0x1d>

008004ee <close_all>:

void
close_all(void)
{
  8004ee:	f3 0f 1e fb          	endbr32 
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004f9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004fe:	83 ec 0c             	sub    $0xc,%esp
  800501:	53                   	push   %ebx
  800502:	e8 b6 ff ff ff       	call   8004bd <close>
	for (i = 0; i < MAXFD; i++)
  800507:	83 c3 01             	add    $0x1,%ebx
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	83 fb 20             	cmp    $0x20,%ebx
  800510:	75 ec                	jne    8004fe <close_all+0x10>
}
  800512:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800515:	c9                   	leave  
  800516:	c3                   	ret    

00800517 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800517:	f3 0f 1e fb          	endbr32 
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	57                   	push   %edi
  80051f:	56                   	push   %esi
  800520:	53                   	push   %ebx
  800521:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800524:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800527:	50                   	push   %eax
  800528:	ff 75 08             	pushl  0x8(%ebp)
  80052b:	e8 54 fe ff ff       	call   800384 <fd_lookup>
  800530:	89 c3                	mov    %eax,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	85 c0                	test   %eax,%eax
  800537:	0f 88 81 00 00 00    	js     8005be <dup+0xa7>
		return r;
	close(newfdnum);
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	e8 75 ff ff ff       	call   8004bd <close>

	newfd = INDEX2FD(newfdnum);
  800548:	8b 75 0c             	mov    0xc(%ebp),%esi
  80054b:	c1 e6 0c             	shl    $0xc,%esi
  80054e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800554:	83 c4 04             	add    $0x4,%esp
  800557:	ff 75 e4             	pushl  -0x1c(%ebp)
  80055a:	e8 b0 fd ff ff       	call   80030f <fd2data>
  80055f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800561:	89 34 24             	mov    %esi,(%esp)
  800564:	e8 a6 fd ff ff       	call   80030f <fd2data>
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80056e:	89 d8                	mov    %ebx,%eax
  800570:	c1 e8 16             	shr    $0x16,%eax
  800573:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80057a:	a8 01                	test   $0x1,%al
  80057c:	74 11                	je     80058f <dup+0x78>
  80057e:	89 d8                	mov    %ebx,%eax
  800580:	c1 e8 0c             	shr    $0xc,%eax
  800583:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058a:	f6 c2 01             	test   $0x1,%dl
  80058d:	75 39                	jne    8005c8 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80058f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800592:	89 d0                	mov    %edx,%eax
  800594:	c1 e8 0c             	shr    $0xc,%eax
  800597:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80059e:	83 ec 0c             	sub    $0xc,%esp
  8005a1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a6:	50                   	push   %eax
  8005a7:	56                   	push   %esi
  8005a8:	6a 00                	push   $0x0
  8005aa:	52                   	push   %edx
  8005ab:	6a 00                	push   $0x0
  8005ad:	e8 34 fc ff ff       	call   8001e6 <sys_page_map>
  8005b2:	89 c3                	mov    %eax,%ebx
  8005b4:	83 c4 20             	add    $0x20,%esp
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	78 31                	js     8005ec <dup+0xd5>
		goto err;

	return newfdnum;
  8005bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005be:	89 d8                	mov    %ebx,%eax
  8005c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c3:	5b                   	pop    %ebx
  8005c4:	5e                   	pop    %esi
  8005c5:	5f                   	pop    %edi
  8005c6:	5d                   	pop    %ebp
  8005c7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d7:	50                   	push   %eax
  8005d8:	57                   	push   %edi
  8005d9:	6a 00                	push   $0x0
  8005db:	53                   	push   %ebx
  8005dc:	6a 00                	push   $0x0
  8005de:	e8 03 fc ff ff       	call   8001e6 <sys_page_map>
  8005e3:	89 c3                	mov    %eax,%ebx
  8005e5:	83 c4 20             	add    $0x20,%esp
  8005e8:	85 c0                	test   %eax,%eax
  8005ea:	79 a3                	jns    80058f <dup+0x78>
	sys_page_unmap(0, newfd);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	56                   	push   %esi
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 19 fc ff ff       	call   800210 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005f7:	83 c4 08             	add    $0x8,%esp
  8005fa:	57                   	push   %edi
  8005fb:	6a 00                	push   $0x0
  8005fd:	e8 0e fc ff ff       	call   800210 <sys_page_unmap>
	return r;
  800602:	83 c4 10             	add    $0x10,%esp
  800605:	eb b7                	jmp    8005be <dup+0xa7>

00800607 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800607:	f3 0f 1e fb          	endbr32 
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	53                   	push   %ebx
  80060f:	83 ec 1c             	sub    $0x1c,%esp
  800612:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800615:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800618:	50                   	push   %eax
  800619:	53                   	push   %ebx
  80061a:	e8 65 fd ff ff       	call   800384 <fd_lookup>
  80061f:	83 c4 10             	add    $0x10,%esp
  800622:	85 c0                	test   %eax,%eax
  800624:	78 3f                	js     800665 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80062c:	50                   	push   %eax
  80062d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800630:	ff 30                	pushl  (%eax)
  800632:	e8 a1 fd ff ff       	call   8003d8 <dev_lookup>
  800637:	83 c4 10             	add    $0x10,%esp
  80063a:	85 c0                	test   %eax,%eax
  80063c:	78 27                	js     800665 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80063e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800641:	8b 42 08             	mov    0x8(%edx),%eax
  800644:	83 e0 03             	and    $0x3,%eax
  800647:	83 f8 01             	cmp    $0x1,%eax
  80064a:	74 1e                	je     80066a <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80064c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80064f:	8b 40 08             	mov    0x8(%eax),%eax
  800652:	85 c0                	test   %eax,%eax
  800654:	74 35                	je     80068b <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800656:	83 ec 04             	sub    $0x4,%esp
  800659:	ff 75 10             	pushl  0x10(%ebp)
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	52                   	push   %edx
  800660:	ff d0                	call   *%eax
  800662:	83 c4 10             	add    $0x10,%esp
}
  800665:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800668:	c9                   	leave  
  800669:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 04 40 80 00       	mov    0x804004,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 39 1e 80 00       	push   $0x801e39
  80067c:	e8 aa 0a 00 00       	call   80112b <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800689:	eb da                	jmp    800665 <read+0x5e>
		return -E_NOT_SUPP;
  80068b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800690:	eb d3                	jmp    800665 <read+0x5e>

00800692 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800692:	f3 0f 1e fb          	endbr32 
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	57                   	push   %edi
  80069a:	56                   	push   %esi
  80069b:	53                   	push   %ebx
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006aa:	eb 02                	jmp    8006ae <readn+0x1c>
  8006ac:	01 c3                	add    %eax,%ebx
  8006ae:	39 f3                	cmp    %esi,%ebx
  8006b0:	73 21                	jae    8006d3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006b2:	83 ec 04             	sub    $0x4,%esp
  8006b5:	89 f0                	mov    %esi,%eax
  8006b7:	29 d8                	sub    %ebx,%eax
  8006b9:	50                   	push   %eax
  8006ba:	89 d8                	mov    %ebx,%eax
  8006bc:	03 45 0c             	add    0xc(%ebp),%eax
  8006bf:	50                   	push   %eax
  8006c0:	57                   	push   %edi
  8006c1:	e8 41 ff ff ff       	call   800607 <read>
		if (m < 0)
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	78 04                	js     8006d1 <readn+0x3f>
			return m;
		if (m == 0)
  8006cd:	75 dd                	jne    8006ac <readn+0x1a>
  8006cf:	eb 02                	jmp    8006d3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006d3:	89 d8                	mov    %ebx,%eax
  8006d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d8:	5b                   	pop    %ebx
  8006d9:	5e                   	pop    %esi
  8006da:	5f                   	pop    %edi
  8006db:	5d                   	pop    %ebp
  8006dc:	c3                   	ret    

008006dd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006dd:	f3 0f 1e fb          	endbr32 
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 1c             	sub    $0x1c,%esp
  8006e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ee:	50                   	push   %eax
  8006ef:	53                   	push   %ebx
  8006f0:	e8 8f fc ff ff       	call   800384 <fd_lookup>
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	78 3a                	js     800736 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800706:	ff 30                	pushl  (%eax)
  800708:	e8 cb fc ff ff       	call   8003d8 <dev_lookup>
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	85 c0                	test   %eax,%eax
  800712:	78 22                	js     800736 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800714:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800717:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80071b:	74 1e                	je     80073b <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80071d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800720:	8b 52 0c             	mov    0xc(%edx),%edx
  800723:	85 d2                	test   %edx,%edx
  800725:	74 35                	je     80075c <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800727:	83 ec 04             	sub    $0x4,%esp
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	50                   	push   %eax
  800731:	ff d2                	call   *%edx
  800733:	83 c4 10             	add    $0x10,%esp
}
  800736:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800739:	c9                   	leave  
  80073a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 04 40 80 00       	mov    0x804004,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 55 1e 80 00       	push   $0x801e55
  80074d:	e8 d9 09 00 00       	call   80112b <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075a:	eb da                	jmp    800736 <write+0x59>
		return -E_NOT_SUPP;
  80075c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800761:	eb d3                	jmp    800736 <write+0x59>

00800763 <seek>:

int
seek(int fdnum, off_t offset)
{
  800763:	f3 0f 1e fb          	endbr32 
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80076d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800770:	50                   	push   %eax
  800771:	ff 75 08             	pushl  0x8(%ebp)
  800774:	e8 0b fc ff ff       	call   800384 <fd_lookup>
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	85 c0                	test   %eax,%eax
  80077e:	78 0e                	js     80078e <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
  800783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800786:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800789:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800790:	f3 0f 1e fb          	endbr32 
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	83 ec 1c             	sub    $0x1c,%esp
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80079e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a1:	50                   	push   %eax
  8007a2:	53                   	push   %ebx
  8007a3:	e8 dc fb ff ff       	call   800384 <fd_lookup>
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 37                	js     8007e6 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b5:	50                   	push   %eax
  8007b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b9:	ff 30                	pushl  (%eax)
  8007bb:	e8 18 fc ff ff       	call   8003d8 <dev_lookup>
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	78 1f                	js     8007e6 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ce:	74 1b                	je     8007eb <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d3:	8b 52 18             	mov    0x18(%edx),%edx
  8007d6:	85 d2                	test   %edx,%edx
  8007d8:	74 32                	je     80080c <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	ff 75 0c             	pushl  0xc(%ebp)
  8007e0:	50                   	push   %eax
  8007e1:	ff d2                	call   *%edx
  8007e3:	83 c4 10             	add    $0x10,%esp
}
  8007e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007eb:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f0:	8b 40 48             	mov    0x48(%eax),%eax
  8007f3:	83 ec 04             	sub    $0x4,%esp
  8007f6:	53                   	push   %ebx
  8007f7:	50                   	push   %eax
  8007f8:	68 18 1e 80 00       	push   $0x801e18
  8007fd:	e8 29 09 00 00       	call   80112b <cprintf>
		return -E_INVAL;
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080a:	eb da                	jmp    8007e6 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80080c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800811:	eb d3                	jmp    8007e6 <ftruncate+0x56>

00800813 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800813:	f3 0f 1e fb          	endbr32 
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	83 ec 1c             	sub    $0x1c,%esp
  80081e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800821:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	ff 75 08             	pushl  0x8(%ebp)
  800828:	e8 57 fb ff ff       	call   800384 <fd_lookup>
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	85 c0                	test   %eax,%eax
  800832:	78 4b                	js     80087f <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083a:	50                   	push   %eax
  80083b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083e:	ff 30                	pushl  (%eax)
  800840:	e8 93 fb ff ff       	call   8003d8 <dev_lookup>
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	85 c0                	test   %eax,%eax
  80084a:	78 33                	js     80087f <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80084c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800853:	74 2f                	je     800884 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800855:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800858:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085f:	00 00 00 
	stat->st_isdir = 0;
  800862:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800869:	00 00 00 
	stat->st_dev = dev;
  80086c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	ff 75 f0             	pushl  -0x10(%ebp)
  800879:	ff 50 14             	call   *0x14(%eax)
  80087c:	83 c4 10             	add    $0x10,%esp
}
  80087f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800882:	c9                   	leave  
  800883:	c3                   	ret    
		return -E_NOT_SUPP;
  800884:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800889:	eb f4                	jmp    80087f <fstat+0x6c>

0080088b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088b:	f3 0f 1e fb          	endbr32 
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	6a 00                	push   $0x0
  800899:	ff 75 08             	pushl  0x8(%ebp)
  80089c:	e8 fb 01 00 00       	call   800a9c <open>
  8008a1:	89 c3                	mov    %eax,%ebx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	78 1b                	js     8008c5 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008aa:	83 ec 08             	sub    $0x8,%esp
  8008ad:	ff 75 0c             	pushl  0xc(%ebp)
  8008b0:	50                   	push   %eax
  8008b1:	e8 5d ff ff ff       	call   800813 <fstat>
  8008b6:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b8:	89 1c 24             	mov    %ebx,(%esp)
  8008bb:	e8 fd fb ff ff       	call   8004bd <close>
	return r;
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	89 f3                	mov    %esi,%ebx
}
  8008c5:	89 d8                	mov    %ebx,%eax
  8008c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	89 c6                	mov    %eax,%esi
  8008d5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008de:	74 27                	je     800907 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008e0:	6a 07                	push   $0x7
  8008e2:	68 00 50 80 00       	push   $0x805000
  8008e7:	56                   	push   %esi
  8008e8:	ff 35 00 40 80 00    	pushl  0x804000
  8008ee:	e8 84 11 00 00       	call   801a77 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008f3:	83 c4 0c             	add    $0xc,%esp
  8008f6:	6a 00                	push   $0x0
  8008f8:	53                   	push   %ebx
  8008f9:	6a 00                	push   $0x0
  8008fb:	e8 09 11 00 00       	call   801a09 <ipc_recv>
}
  800900:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 cb 11 00 00       	call   801adc <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	eb c5                	jmp    8008e0 <fsipc+0x12>

0080091b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80091b:	f3 0f 1e fb          	endbr32 
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 40 0c             	mov    0xc(%eax),%eax
  80092b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800938:	ba 00 00 00 00       	mov    $0x0,%edx
  80093d:	b8 02 00 00 00       	mov    $0x2,%eax
  800942:	e8 87 ff ff ff       	call   8008ce <fsipc>
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <devfile_flush>:
{
  800949:	f3 0f 1e fb          	endbr32 
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	8b 40 0c             	mov    0xc(%eax),%eax
  800959:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 06 00 00 00       	mov    $0x6,%eax
  800968:	e8 61 ff ff ff       	call   8008ce <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_stat>:
{
  80096f:	f3 0f 1e fb          	endbr32 
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	83 ec 04             	sub    $0x4,%esp
  80097a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 40 0c             	mov    0xc(%eax),%eax
  800983:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800988:	ba 00 00 00 00       	mov    $0x0,%edx
  80098d:	b8 05 00 00 00       	mov    $0x5,%eax
  800992:	e8 37 ff ff ff       	call   8008ce <fsipc>
  800997:	85 c0                	test   %eax,%eax
  800999:	78 2c                	js     8009c7 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	68 00 50 80 00       	push   $0x805000
  8009a3:	53                   	push   %ebx
  8009a4:	e8 ec 0c 00 00       	call   801695 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a9:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009bf:	83 c4 10             	add    $0x10,%esp
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <devfile_write>:
{
  8009cc:	f3 0f 1e fb          	endbr32 
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	83 ec 0c             	sub    $0xc,%esp
  8009d6:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8009df:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009e5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009ea:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009ef:	0f 47 c2             	cmova  %edx,%eax
  8009f2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8009f7:	50                   	push   %eax
  8009f8:	ff 75 0c             	pushl  0xc(%ebp)
  8009fb:	68 08 50 80 00       	push   $0x805008
  800a00:	e8 48 0e 00 00       	call   80184d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a05:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0a:	b8 04 00 00 00       	mov    $0x4,%eax
  800a0f:	e8 ba fe ff ff       	call   8008ce <fsipc>
}
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    

00800a16 <devfile_read>:
{
  800a16:	f3 0f 1e fb          	endbr32 
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
  800a1f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	8b 40 0c             	mov    0xc(%eax),%eax
  800a28:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a2d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a33:	ba 00 00 00 00       	mov    $0x0,%edx
  800a38:	b8 03 00 00 00       	mov    $0x3,%eax
  800a3d:	e8 8c fe ff ff       	call   8008ce <fsipc>
  800a42:	89 c3                	mov    %eax,%ebx
  800a44:	85 c0                	test   %eax,%eax
  800a46:	78 1f                	js     800a67 <devfile_read+0x51>
	assert(r <= n);
  800a48:	39 f0                	cmp    %esi,%eax
  800a4a:	77 24                	ja     800a70 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a4c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a51:	7f 33                	jg     800a86 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a53:	83 ec 04             	sub    $0x4,%esp
  800a56:	50                   	push   %eax
  800a57:	68 00 50 80 00       	push   $0x805000
  800a5c:	ff 75 0c             	pushl  0xc(%ebp)
  800a5f:	e8 e9 0d 00 00       	call   80184d <memmove>
	return r;
  800a64:	83 c4 10             	add    $0x10,%esp
}
  800a67:	89 d8                	mov    %ebx,%eax
  800a69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    
	assert(r <= n);
  800a70:	68 84 1e 80 00       	push   $0x801e84
  800a75:	68 8b 1e 80 00       	push   $0x801e8b
  800a7a:	6a 7c                	push   $0x7c
  800a7c:	68 a0 1e 80 00       	push   $0x801ea0
  800a81:	e8 be 05 00 00       	call   801044 <_panic>
	assert(r <= PGSIZE);
  800a86:	68 ab 1e 80 00       	push   $0x801eab
  800a8b:	68 8b 1e 80 00       	push   $0x801e8b
  800a90:	6a 7d                	push   $0x7d
  800a92:	68 a0 1e 80 00       	push   $0x801ea0
  800a97:	e8 a8 05 00 00       	call   801044 <_panic>

00800a9c <open>:
{
  800a9c:	f3 0f 1e fb          	endbr32 
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	83 ec 1c             	sub    $0x1c,%esp
  800aa8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aab:	56                   	push   %esi
  800aac:	e8 a1 0b 00 00       	call   801652 <strlen>
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab9:	7f 6c                	jg     800b27 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800abb:	83 ec 0c             	sub    $0xc,%esp
  800abe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac1:	50                   	push   %eax
  800ac2:	e8 67 f8 ff ff       	call   80032e <fd_alloc>
  800ac7:	89 c3                	mov    %eax,%ebx
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	85 c0                	test   %eax,%eax
  800ace:	78 3c                	js     800b0c <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800ad0:	83 ec 08             	sub    $0x8,%esp
  800ad3:	56                   	push   %esi
  800ad4:	68 00 50 80 00       	push   $0x805000
  800ad9:	e8 b7 0b 00 00       	call   801695 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aee:	e8 db fd ff ff       	call   8008ce <fsipc>
  800af3:	89 c3                	mov    %eax,%ebx
  800af5:	83 c4 10             	add    $0x10,%esp
  800af8:	85 c0                	test   %eax,%eax
  800afa:	78 19                	js     800b15 <open+0x79>
	return fd2num(fd);
  800afc:	83 ec 0c             	sub    $0xc,%esp
  800aff:	ff 75 f4             	pushl  -0xc(%ebp)
  800b02:	e8 f4 f7 ff ff       	call   8002fb <fd2num>
  800b07:	89 c3                	mov    %eax,%ebx
  800b09:	83 c4 10             	add    $0x10,%esp
}
  800b0c:	89 d8                	mov    %ebx,%eax
  800b0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    
		fd_close(fd, 0);
  800b15:	83 ec 08             	sub    $0x8,%esp
  800b18:	6a 00                	push   $0x0
  800b1a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1d:	e8 10 f9 ff ff       	call   800432 <fd_close>
		return r;
  800b22:	83 c4 10             	add    $0x10,%esp
  800b25:	eb e5                	jmp    800b0c <open+0x70>
		return -E_BAD_PATH;
  800b27:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b2c:	eb de                	jmp    800b0c <open+0x70>

00800b2e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b2e:	f3 0f 1e fb          	endbr32 
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b42:	e8 87 fd ff ff       	call   8008ce <fsipc>
}
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b49:	f3 0f 1e fb          	endbr32 
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b55:	83 ec 0c             	sub    $0xc,%esp
  800b58:	ff 75 08             	pushl  0x8(%ebp)
  800b5b:	e8 af f7 ff ff       	call   80030f <fd2data>
  800b60:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b62:	83 c4 08             	add    $0x8,%esp
  800b65:	68 b7 1e 80 00       	push   $0x801eb7
  800b6a:	53                   	push   %ebx
  800b6b:	e8 25 0b 00 00       	call   801695 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b70:	8b 46 04             	mov    0x4(%esi),%eax
  800b73:	2b 06                	sub    (%esi),%eax
  800b75:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b7b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b82:	00 00 00 
	stat->st_dev = &devpipe;
  800b85:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b8c:	30 80 00 
	return 0;
}
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b9b:	f3 0f 1e fb          	endbr32 
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba9:	53                   	push   %ebx
  800baa:	6a 00                	push   $0x0
  800bac:	e8 5f f6 ff ff       	call   800210 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb1:	89 1c 24             	mov    %ebx,(%esp)
  800bb4:	e8 56 f7 ff ff       	call   80030f <fd2data>
  800bb9:	83 c4 08             	add    $0x8,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 00                	push   $0x0
  800bbf:	e8 4c f6 ff ff       	call   800210 <sys_page_unmap>
}
  800bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <_pipeisclosed>:
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 1c             	sub    $0x1c,%esp
  800bd2:	89 c7                	mov    %eax,%edi
  800bd4:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bd6:	a1 04 40 80 00       	mov    0x804004,%eax
  800bdb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	57                   	push   %edi
  800be2:	e8 32 0f 00 00       	call   801b19 <pageref>
  800be7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bea:	89 34 24             	mov    %esi,(%esp)
  800bed:	e8 27 0f 00 00       	call   801b19 <pageref>
		nn = thisenv->env_runs;
  800bf2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bf8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bfb:	83 c4 10             	add    $0x10,%esp
  800bfe:	39 cb                	cmp    %ecx,%ebx
  800c00:	74 1b                	je     800c1d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c02:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c05:	75 cf                	jne    800bd6 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c07:	8b 42 58             	mov    0x58(%edx),%eax
  800c0a:	6a 01                	push   $0x1
  800c0c:	50                   	push   %eax
  800c0d:	53                   	push   %ebx
  800c0e:	68 be 1e 80 00       	push   $0x801ebe
  800c13:	e8 13 05 00 00       	call   80112b <cprintf>
  800c18:	83 c4 10             	add    $0x10,%esp
  800c1b:	eb b9                	jmp    800bd6 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c1d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c20:	0f 94 c0             	sete   %al
  800c23:	0f b6 c0             	movzbl %al,%eax
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <devpipe_write>:
{
  800c2e:	f3 0f 1e fb          	endbr32 
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 28             	sub    $0x28,%esp
  800c3b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c3e:	56                   	push   %esi
  800c3f:	e8 cb f6 ff ff       	call   80030f <fd2data>
  800c44:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c46:	83 c4 10             	add    $0x10,%esp
  800c49:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c51:	74 4f                	je     800ca2 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c53:	8b 43 04             	mov    0x4(%ebx),%eax
  800c56:	8b 0b                	mov    (%ebx),%ecx
  800c58:	8d 51 20             	lea    0x20(%ecx),%edx
  800c5b:	39 d0                	cmp    %edx,%eax
  800c5d:	72 14                	jb     800c73 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c5f:	89 da                	mov    %ebx,%edx
  800c61:	89 f0                	mov    %esi,%eax
  800c63:	e8 61 ff ff ff       	call   800bc9 <_pipeisclosed>
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	75 3b                	jne    800ca7 <devpipe_write+0x79>
			sys_yield();
  800c6c:	e8 22 f5 ff ff       	call   800193 <sys_yield>
  800c71:	eb e0                	jmp    800c53 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c7a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c7d:	89 c2                	mov    %eax,%edx
  800c7f:	c1 fa 1f             	sar    $0x1f,%edx
  800c82:	89 d1                	mov    %edx,%ecx
  800c84:	c1 e9 1b             	shr    $0x1b,%ecx
  800c87:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c8a:	83 e2 1f             	and    $0x1f,%edx
  800c8d:	29 ca                	sub    %ecx,%edx
  800c8f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c93:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c97:	83 c0 01             	add    $0x1,%eax
  800c9a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c9d:	83 c7 01             	add    $0x1,%edi
  800ca0:	eb ac                	jmp    800c4e <devpipe_write+0x20>
	return i;
  800ca2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca5:	eb 05                	jmp    800cac <devpipe_write+0x7e>
				return 0;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <devpipe_read>:
{
  800cb4:	f3 0f 1e fb          	endbr32 
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 18             	sub    $0x18,%esp
  800cc1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cc4:	57                   	push   %edi
  800cc5:	e8 45 f6 ff ff       	call   80030f <fd2data>
  800cca:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ccc:	83 c4 10             	add    $0x10,%esp
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
  800cd4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cd7:	75 14                	jne    800ced <devpipe_read+0x39>
	return i;
  800cd9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdc:	eb 02                	jmp    800ce0 <devpipe_read+0x2c>
				return i;
  800cde:	89 f0                	mov    %esi,%eax
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    
			sys_yield();
  800ce8:	e8 a6 f4 ff ff       	call   800193 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800ced:	8b 03                	mov    (%ebx),%eax
  800cef:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cf2:	75 18                	jne    800d0c <devpipe_read+0x58>
			if (i > 0)
  800cf4:	85 f6                	test   %esi,%esi
  800cf6:	75 e6                	jne    800cde <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800cf8:	89 da                	mov    %ebx,%edx
  800cfa:	89 f8                	mov    %edi,%eax
  800cfc:	e8 c8 fe ff ff       	call   800bc9 <_pipeisclosed>
  800d01:	85 c0                	test   %eax,%eax
  800d03:	74 e3                	je     800ce8 <devpipe_read+0x34>
				return 0;
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0a:	eb d4                	jmp    800ce0 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d0c:	99                   	cltd   
  800d0d:	c1 ea 1b             	shr    $0x1b,%edx
  800d10:	01 d0                	add    %edx,%eax
  800d12:	83 e0 1f             	and    $0x1f,%eax
  800d15:	29 d0                	sub    %edx,%eax
  800d17:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d22:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d25:	83 c6 01             	add    $0x1,%esi
  800d28:	eb aa                	jmp    800cd4 <devpipe_read+0x20>

00800d2a <pipe>:
{
  800d2a:	f3 0f 1e fb          	endbr32 
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d39:	50                   	push   %eax
  800d3a:	e8 ef f5 ff ff       	call   80032e <fd_alloc>
  800d3f:	89 c3                	mov    %eax,%ebx
  800d41:	83 c4 10             	add    $0x10,%esp
  800d44:	85 c0                	test   %eax,%eax
  800d46:	0f 88 23 01 00 00    	js     800e6f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4c:	83 ec 04             	sub    $0x4,%esp
  800d4f:	68 07 04 00 00       	push   $0x407
  800d54:	ff 75 f4             	pushl  -0xc(%ebp)
  800d57:	6a 00                	push   $0x0
  800d59:	e8 60 f4 ff ff       	call   8001be <sys_page_alloc>
  800d5e:	89 c3                	mov    %eax,%ebx
  800d60:	83 c4 10             	add    $0x10,%esp
  800d63:	85 c0                	test   %eax,%eax
  800d65:	0f 88 04 01 00 00    	js     800e6f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d71:	50                   	push   %eax
  800d72:	e8 b7 f5 ff ff       	call   80032e <fd_alloc>
  800d77:	89 c3                	mov    %eax,%ebx
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	0f 88 db 00 00 00    	js     800e5f <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d84:	83 ec 04             	sub    $0x4,%esp
  800d87:	68 07 04 00 00       	push   $0x407
  800d8c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 28 f4 ff ff       	call   8001be <sys_page_alloc>
  800d96:	89 c3                	mov    %eax,%ebx
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	0f 88 bc 00 00 00    	js     800e5f <pipe+0x135>
	va = fd2data(fd0);
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	ff 75 f4             	pushl  -0xc(%ebp)
  800da9:	e8 61 f5 ff ff       	call   80030f <fd2data>
  800dae:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db0:	83 c4 0c             	add    $0xc,%esp
  800db3:	68 07 04 00 00       	push   $0x407
  800db8:	50                   	push   %eax
  800db9:	6a 00                	push   $0x0
  800dbb:	e8 fe f3 ff ff       	call   8001be <sys_page_alloc>
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	83 c4 10             	add    $0x10,%esp
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	0f 88 82 00 00 00    	js     800e4f <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd3:	e8 37 f5 ff ff       	call   80030f <fd2data>
  800dd8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800ddf:	50                   	push   %eax
  800de0:	6a 00                	push   $0x0
  800de2:	56                   	push   %esi
  800de3:	6a 00                	push   $0x0
  800de5:	e8 fc f3 ff ff       	call   8001e6 <sys_page_map>
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	83 c4 20             	add    $0x20,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	78 4e                	js     800e41 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800df3:	a1 20 30 80 00       	mov    0x803020,%eax
  800df8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dfb:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800dfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e00:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e07:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e0a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1c:	e8 da f4 ff ff       	call   8002fb <fd2num>
  800e21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e26:	83 c4 04             	add    $0x4,%esp
  800e29:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2c:	e8 ca f4 ff ff       	call   8002fb <fd2num>
  800e31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e37:	83 c4 10             	add    $0x10,%esp
  800e3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3f:	eb 2e                	jmp    800e6f <pipe+0x145>
	sys_page_unmap(0, va);
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	56                   	push   %esi
  800e45:	6a 00                	push   $0x0
  800e47:	e8 c4 f3 ff ff       	call   800210 <sys_page_unmap>
  800e4c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	ff 75 f0             	pushl  -0x10(%ebp)
  800e55:	6a 00                	push   $0x0
  800e57:	e8 b4 f3 ff ff       	call   800210 <sys_page_unmap>
  800e5c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	ff 75 f4             	pushl  -0xc(%ebp)
  800e65:	6a 00                	push   $0x0
  800e67:	e8 a4 f3 ff ff       	call   800210 <sys_page_unmap>
  800e6c:	83 c4 10             	add    $0x10,%esp
}
  800e6f:	89 d8                	mov    %ebx,%eax
  800e71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <pipeisclosed>:
{
  800e78:	f3 0f 1e fb          	endbr32 
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e85:	50                   	push   %eax
  800e86:	ff 75 08             	pushl  0x8(%ebp)
  800e89:	e8 f6 f4 ff ff       	call   800384 <fd_lookup>
  800e8e:	83 c4 10             	add    $0x10,%esp
  800e91:	85 c0                	test   %eax,%eax
  800e93:	78 18                	js     800ead <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9b:	e8 6f f4 ff ff       	call   80030f <fd2data>
  800ea0:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea5:	e8 1f fd ff ff       	call   800bc9 <_pipeisclosed>
  800eaa:	83 c4 10             	add    $0x10,%esp
}
  800ead:	c9                   	leave  
  800eae:	c3                   	ret    

00800eaf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eaf:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb8:	c3                   	ret    

00800eb9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb9:	f3 0f 1e fb          	endbr32 
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec3:	68 d6 1e 80 00       	push   $0x801ed6
  800ec8:	ff 75 0c             	pushl  0xc(%ebp)
  800ecb:	e8 c5 07 00 00       	call   801695 <strcpy>
	return 0;
}
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <devcons_write>:
{
  800ed7:	f3 0f 1e fb          	endbr32 
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ee7:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eec:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ef2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef5:	73 31                	jae    800f28 <devcons_write+0x51>
		m = n - tot;
  800ef7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efa:	29 f3                	sub    %esi,%ebx
  800efc:	83 fb 7f             	cmp    $0x7f,%ebx
  800eff:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f04:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	53                   	push   %ebx
  800f0b:	89 f0                	mov    %esi,%eax
  800f0d:	03 45 0c             	add    0xc(%ebp),%eax
  800f10:	50                   	push   %eax
  800f11:	57                   	push   %edi
  800f12:	e8 36 09 00 00       	call   80184d <memmove>
		sys_cputs(buf, m);
  800f17:	83 c4 08             	add    $0x8,%esp
  800f1a:	53                   	push   %ebx
  800f1b:	57                   	push   %edi
  800f1c:	e8 d2 f1 ff ff       	call   8000f3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f21:	01 de                	add    %ebx,%esi
  800f23:	83 c4 10             	add    $0x10,%esp
  800f26:	eb ca                	jmp    800ef2 <devcons_write+0x1b>
}
  800f28:	89 f0                	mov    %esi,%eax
  800f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <devcons_read>:
{
  800f32:	f3 0f 1e fb          	endbr32 
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 08             	sub    $0x8,%esp
  800f3c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f45:	74 21                	je     800f68 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f47:	e8 d1 f1 ff ff       	call   80011d <sys_cgetc>
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	75 07                	jne    800f57 <devcons_read+0x25>
		sys_yield();
  800f50:	e8 3e f2 ff ff       	call   800193 <sys_yield>
  800f55:	eb f0                	jmp    800f47 <devcons_read+0x15>
	if (c < 0)
  800f57:	78 0f                	js     800f68 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f59:	83 f8 04             	cmp    $0x4,%eax
  800f5c:	74 0c                	je     800f6a <devcons_read+0x38>
	*(char*)vbuf = c;
  800f5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f61:	88 02                	mov    %al,(%edx)
	return 1;
  800f63:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f68:	c9                   	leave  
  800f69:	c3                   	ret    
		return 0;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6f:	eb f7                	jmp    800f68 <devcons_read+0x36>

00800f71 <cputchar>:
{
  800f71:	f3 0f 1e fb          	endbr32 
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f81:	6a 01                	push   $0x1
  800f83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f86:	50                   	push   %eax
  800f87:	e8 67 f1 ff ff       	call   8000f3 <sys_cputs>
}
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	c9                   	leave  
  800f90:	c3                   	ret    

00800f91 <getchar>:
{
  800f91:	f3 0f 1e fb          	endbr32 
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f9b:	6a 01                	push   $0x1
  800f9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa0:	50                   	push   %eax
  800fa1:	6a 00                	push   $0x0
  800fa3:	e8 5f f6 ff ff       	call   800607 <read>
	if (r < 0)
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	78 06                	js     800fb5 <getchar+0x24>
	if (r < 1)
  800faf:	74 06                	je     800fb7 <getchar+0x26>
	return c;
  800fb1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    
		return -E_EOF;
  800fb7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fbc:	eb f7                	jmp    800fb5 <getchar+0x24>

00800fbe <iscons>:
{
  800fbe:	f3 0f 1e fb          	endbr32 
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	ff 75 08             	pushl  0x8(%ebp)
  800fcf:	e8 b0 f3 ff ff       	call   800384 <fd_lookup>
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 11                	js     800fec <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fde:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe4:	39 10                	cmp    %edx,(%eax)
  800fe6:	0f 94 c0             	sete   %al
  800fe9:	0f b6 c0             	movzbl %al,%eax
}
  800fec:	c9                   	leave  
  800fed:	c3                   	ret    

00800fee <opencons>:
{
  800fee:	f3 0f 1e fb          	endbr32 
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800ff8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	e8 2d f3 ff ff       	call   80032e <fd_alloc>
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	78 3a                	js     801042 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801008:	83 ec 04             	sub    $0x4,%esp
  80100b:	68 07 04 00 00       	push   $0x407
  801010:	ff 75 f4             	pushl  -0xc(%ebp)
  801013:	6a 00                	push   $0x0
  801015:	e8 a4 f1 ff ff       	call   8001be <sys_page_alloc>
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	78 21                	js     801042 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801021:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801024:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80102a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80102c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801036:	83 ec 0c             	sub    $0xc,%esp
  801039:	50                   	push   %eax
  80103a:	e8 bc f2 ff ff       	call   8002fb <fd2num>
  80103f:	83 c4 10             	add    $0x10,%esp
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801044:	f3 0f 1e fb          	endbr32 
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	56                   	push   %esi
  80104c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80104d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801050:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801056:	e8 10 f1 ff ff       	call   80016b <sys_getenvid>
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	ff 75 0c             	pushl  0xc(%ebp)
  801061:	ff 75 08             	pushl  0x8(%ebp)
  801064:	56                   	push   %esi
  801065:	50                   	push   %eax
  801066:	68 e4 1e 80 00       	push   $0x801ee4
  80106b:	e8 bb 00 00 00       	call   80112b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801070:	83 c4 18             	add    $0x18,%esp
  801073:	53                   	push   %ebx
  801074:	ff 75 10             	pushl  0x10(%ebp)
  801077:	e8 5a 00 00 00       	call   8010d6 <vcprintf>
	cprintf("\n");
  80107c:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  801083:	e8 a3 00 00 00       	call   80112b <cprintf>
  801088:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80108b:	cc                   	int3   
  80108c:	eb fd                	jmp    80108b <_panic+0x47>

0080108e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80108e:	f3 0f 1e fb          	endbr32 
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	53                   	push   %ebx
  801096:	83 ec 04             	sub    $0x4,%esp
  801099:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80109c:	8b 13                	mov    (%ebx),%edx
  80109e:	8d 42 01             	lea    0x1(%edx),%eax
  8010a1:	89 03                	mov    %eax,(%ebx)
  8010a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010af:	74 09                	je     8010ba <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	68 ff 00 00 00       	push   $0xff
  8010c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c5:	50                   	push   %eax
  8010c6:	e8 28 f0 ff ff       	call   8000f3 <sys_cputs>
		b->idx = 0;
  8010cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	eb db                	jmp    8010b1 <putch+0x23>

008010d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010d6:	f3 0f 1e fb          	endbr32 
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ea:	00 00 00 
	b.cnt = 0;
  8010ed:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010f4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f7:	ff 75 0c             	pushl  0xc(%ebp)
  8010fa:	ff 75 08             	pushl  0x8(%ebp)
  8010fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801103:	50                   	push   %eax
  801104:	68 8e 10 80 00       	push   $0x80108e
  801109:	e8 80 01 00 00       	call   80128e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80110e:	83 c4 08             	add    $0x8,%esp
  801111:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801117:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80111d:	50                   	push   %eax
  80111e:	e8 d0 ef ff ff       	call   8000f3 <sys_cputs>

	return b.cnt;
}
  801123:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80112b:	f3 0f 1e fb          	endbr32 
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801135:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801138:	50                   	push   %eax
  801139:	ff 75 08             	pushl  0x8(%ebp)
  80113c:	e8 95 ff ff ff       	call   8010d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801141:	c9                   	leave  
  801142:	c3                   	ret    

00801143 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 1c             	sub    $0x1c,%esp
  80114c:	89 c7                	mov    %eax,%edi
  80114e:	89 d6                	mov    %edx,%esi
  801150:	8b 45 08             	mov    0x8(%ebp),%eax
  801153:	8b 55 0c             	mov    0xc(%ebp),%edx
  801156:	89 d1                	mov    %edx,%ecx
  801158:	89 c2                	mov    %eax,%edx
  80115a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80115d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801160:	8b 45 10             	mov    0x10(%ebp),%eax
  801163:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801166:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801169:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801170:	39 c2                	cmp    %eax,%edx
  801172:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801175:	72 3e                	jb     8011b5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801177:	83 ec 0c             	sub    $0xc,%esp
  80117a:	ff 75 18             	pushl  0x18(%ebp)
  80117d:	83 eb 01             	sub    $0x1,%ebx
  801180:	53                   	push   %ebx
  801181:	50                   	push   %eax
  801182:	83 ec 08             	sub    $0x8,%esp
  801185:	ff 75 e4             	pushl  -0x1c(%ebp)
  801188:	ff 75 e0             	pushl  -0x20(%ebp)
  80118b:	ff 75 dc             	pushl  -0x24(%ebp)
  80118e:	ff 75 d8             	pushl  -0x28(%ebp)
  801191:	e8 ca 09 00 00       	call   801b60 <__udivdi3>
  801196:	83 c4 18             	add    $0x18,%esp
  801199:	52                   	push   %edx
  80119a:	50                   	push   %eax
  80119b:	89 f2                	mov    %esi,%edx
  80119d:	89 f8                	mov    %edi,%eax
  80119f:	e8 9f ff ff ff       	call   801143 <printnum>
  8011a4:	83 c4 20             	add    $0x20,%esp
  8011a7:	eb 13                	jmp    8011bc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	56                   	push   %esi
  8011ad:	ff 75 18             	pushl  0x18(%ebp)
  8011b0:	ff d7                	call   *%edi
  8011b2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011b5:	83 eb 01             	sub    $0x1,%ebx
  8011b8:	85 db                	test   %ebx,%ebx
  8011ba:	7f ed                	jg     8011a9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011bc:	83 ec 08             	sub    $0x8,%esp
  8011bf:	56                   	push   %esi
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8011cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8011cf:	e8 9c 0a 00 00       	call   801c70 <__umoddi3>
  8011d4:	83 c4 14             	add    $0x14,%esp
  8011d7:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  8011de:	50                   	push   %eax
  8011df:	ff d7                	call   *%edi
}
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5f                   	pop    %edi
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8011ec:	83 fa 01             	cmp    $0x1,%edx
  8011ef:	7f 13                	jg     801204 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8011f1:	85 d2                	test   %edx,%edx
  8011f3:	74 1c                	je     801211 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8011f5:	8b 10                	mov    (%eax),%edx
  8011f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011fa:	89 08                	mov    %ecx,(%eax)
  8011fc:	8b 02                	mov    (%edx),%eax
  8011fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801203:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801204:	8b 10                	mov    (%eax),%edx
  801206:	8d 4a 08             	lea    0x8(%edx),%ecx
  801209:	89 08                	mov    %ecx,(%eax)
  80120b:	8b 02                	mov    (%edx),%eax
  80120d:	8b 52 04             	mov    0x4(%edx),%edx
  801210:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801211:	8b 10                	mov    (%eax),%edx
  801213:	8d 4a 04             	lea    0x4(%edx),%ecx
  801216:	89 08                	mov    %ecx,(%eax)
  801218:	8b 02                	mov    (%edx),%eax
  80121a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80121f:	c3                   	ret    

00801220 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801220:	83 fa 01             	cmp    $0x1,%edx
  801223:	7f 0f                	jg     801234 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801225:	85 d2                	test   %edx,%edx
  801227:	74 18                	je     801241 <getint+0x21>
		return va_arg(*ap, long);
  801229:	8b 10                	mov    (%eax),%edx
  80122b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80122e:	89 08                	mov    %ecx,(%eax)
  801230:	8b 02                	mov    (%edx),%eax
  801232:	99                   	cltd   
  801233:	c3                   	ret    
		return va_arg(*ap, long long);
  801234:	8b 10                	mov    (%eax),%edx
  801236:	8d 4a 08             	lea    0x8(%edx),%ecx
  801239:	89 08                	mov    %ecx,(%eax)
  80123b:	8b 02                	mov    (%edx),%eax
  80123d:	8b 52 04             	mov    0x4(%edx),%edx
  801240:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801241:	8b 10                	mov    (%eax),%edx
  801243:	8d 4a 04             	lea    0x4(%edx),%ecx
  801246:	89 08                	mov    %ecx,(%eax)
  801248:	8b 02                	mov    (%edx),%eax
  80124a:	99                   	cltd   
}
  80124b:	c3                   	ret    

0080124c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80124c:	f3 0f 1e fb          	endbr32 
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80125a:	8b 10                	mov    (%eax),%edx
  80125c:	3b 50 04             	cmp    0x4(%eax),%edx
  80125f:	73 0a                	jae    80126b <sprintputch+0x1f>
		*b->buf++ = ch;
  801261:	8d 4a 01             	lea    0x1(%edx),%ecx
  801264:	89 08                	mov    %ecx,(%eax)
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
  801269:	88 02                	mov    %al,(%edx)
}
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <printfmt>:
{
  80126d:	f3 0f 1e fb          	endbr32 
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801277:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80127a:	50                   	push   %eax
  80127b:	ff 75 10             	pushl  0x10(%ebp)
  80127e:	ff 75 0c             	pushl  0xc(%ebp)
  801281:	ff 75 08             	pushl  0x8(%ebp)
  801284:	e8 05 00 00 00       	call   80128e <vprintfmt>
}
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	c9                   	leave  
  80128d:	c3                   	ret    

0080128e <vprintfmt>:
{
  80128e:	f3 0f 1e fb          	endbr32 
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 2c             	sub    $0x2c,%esp
  80129b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80129e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012a1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a4:	e9 86 02 00 00       	jmp    80152f <vprintfmt+0x2a1>
		padc = ' ';
  8012a9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012ad:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012b4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012bb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012c2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012c7:	8d 47 01             	lea    0x1(%edi),%eax
  8012ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012cd:	0f b6 17             	movzbl (%edi),%edx
  8012d0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012d3:	3c 55                	cmp    $0x55,%al
  8012d5:	0f 87 df 02 00 00    	ja     8015ba <vprintfmt+0x32c>
  8012db:	0f b6 c0             	movzbl %al,%eax
  8012de:	3e ff 24 85 40 20 80 	notrack jmp *0x802040(,%eax,4)
  8012e5:	00 
  8012e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012e9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8012ed:	eb d8                	jmp    8012c7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8012ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f2:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8012f6:	eb cf                	jmp    8012c7 <vprintfmt+0x39>
  8012f8:	0f b6 d2             	movzbl %dl,%edx
  8012fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801306:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801309:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80130d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801310:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801313:	83 f9 09             	cmp    $0x9,%ecx
  801316:	77 52                	ja     80136a <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801318:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80131b:	eb e9                	jmp    801306 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80131d:	8b 45 14             	mov    0x14(%ebp),%eax
  801320:	8d 50 04             	lea    0x4(%eax),%edx
  801323:	89 55 14             	mov    %edx,0x14(%ebp)
  801326:	8b 00                	mov    (%eax),%eax
  801328:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80132b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80132e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801332:	79 93                	jns    8012c7 <vprintfmt+0x39>
				width = precision, precision = -1;
  801334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801337:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801341:	eb 84                	jmp    8012c7 <vprintfmt+0x39>
  801343:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801346:	85 c0                	test   %eax,%eax
  801348:	ba 00 00 00 00       	mov    $0x0,%edx
  80134d:	0f 49 d0             	cmovns %eax,%edx
  801350:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801356:	e9 6c ff ff ff       	jmp    8012c7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80135b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80135e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801365:	e9 5d ff ff ff       	jmp    8012c7 <vprintfmt+0x39>
  80136a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80136d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801370:	eb bc                	jmp    80132e <vprintfmt+0xa0>
			lflag++;
  801372:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801378:	e9 4a ff ff ff       	jmp    8012c7 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80137d:	8b 45 14             	mov    0x14(%ebp),%eax
  801380:	8d 50 04             	lea    0x4(%eax),%edx
  801383:	89 55 14             	mov    %edx,0x14(%ebp)
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	56                   	push   %esi
  80138a:	ff 30                	pushl  (%eax)
  80138c:	ff d3                	call   *%ebx
			break;
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	e9 96 01 00 00       	jmp    80152c <vprintfmt+0x29e>
			err = va_arg(ap, int);
  801396:	8b 45 14             	mov    0x14(%ebp),%eax
  801399:	8d 50 04             	lea    0x4(%eax),%edx
  80139c:	89 55 14             	mov    %edx,0x14(%ebp)
  80139f:	8b 00                	mov    (%eax),%eax
  8013a1:	99                   	cltd   
  8013a2:	31 d0                	xor    %edx,%eax
  8013a4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a6:	83 f8 0f             	cmp    $0xf,%eax
  8013a9:	7f 20                	jg     8013cb <vprintfmt+0x13d>
  8013ab:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8013b2:	85 d2                	test   %edx,%edx
  8013b4:	74 15                	je     8013cb <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013b6:	52                   	push   %edx
  8013b7:	68 9d 1e 80 00       	push   $0x801e9d
  8013bc:	56                   	push   %esi
  8013bd:	53                   	push   %ebx
  8013be:	e8 aa fe ff ff       	call   80126d <printfmt>
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	e9 61 01 00 00       	jmp    80152c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013cb:	50                   	push   %eax
  8013cc:	68 1f 1f 80 00       	push   $0x801f1f
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
  8013d3:	e8 95 fe ff ff       	call   80126d <printfmt>
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	e9 4c 01 00 00       	jmp    80152c <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8013e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e3:	8d 50 04             	lea    0x4(%eax),%edx
  8013e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e9:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8013eb:	85 c9                	test   %ecx,%ecx
  8013ed:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  8013f2:	0f 45 c1             	cmovne %ecx,%eax
  8013f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8013f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013fc:	7e 06                	jle    801404 <vprintfmt+0x176>
  8013fe:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801402:	75 0d                	jne    801411 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801404:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801407:	89 c7                	mov    %eax,%edi
  801409:	03 45 e0             	add    -0x20(%ebp),%eax
  80140c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80140f:	eb 57                	jmp    801468 <vprintfmt+0x1da>
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	ff 75 d8             	pushl  -0x28(%ebp)
  801417:	ff 75 cc             	pushl  -0x34(%ebp)
  80141a:	e8 4f 02 00 00       	call   80166e <strnlen>
  80141f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801422:	29 c2                	sub    %eax,%edx
  801424:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801427:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80142a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80142e:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801431:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801433:	85 db                	test   %ebx,%ebx
  801435:	7e 10                	jle    801447 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	56                   	push   %esi
  80143b:	57                   	push   %edi
  80143c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80143f:	83 eb 01             	sub    $0x1,%ebx
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	eb ec                	jmp    801433 <vprintfmt+0x1a5>
  801447:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80144a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80144d:	85 d2                	test   %edx,%edx
  80144f:	b8 00 00 00 00       	mov    $0x0,%eax
  801454:	0f 49 c2             	cmovns %edx,%eax
  801457:	29 c2                	sub    %eax,%edx
  801459:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80145c:	eb a6                	jmp    801404 <vprintfmt+0x176>
					putch(ch, putdat);
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	56                   	push   %esi
  801462:	52                   	push   %edx
  801463:	ff d3                	call   *%ebx
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80146b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80146d:	83 c7 01             	add    $0x1,%edi
  801470:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801474:	0f be d0             	movsbl %al,%edx
  801477:	85 d2                	test   %edx,%edx
  801479:	74 42                	je     8014bd <vprintfmt+0x22f>
  80147b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80147f:	78 06                	js     801487 <vprintfmt+0x1f9>
  801481:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801485:	78 1e                	js     8014a5 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  801487:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80148b:	74 d1                	je     80145e <vprintfmt+0x1d0>
  80148d:	0f be c0             	movsbl %al,%eax
  801490:	83 e8 20             	sub    $0x20,%eax
  801493:	83 f8 5e             	cmp    $0x5e,%eax
  801496:	76 c6                	jbe    80145e <vprintfmt+0x1d0>
					putch('?', putdat);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	56                   	push   %esi
  80149c:	6a 3f                	push   $0x3f
  80149e:	ff d3                	call   *%ebx
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	eb c3                	jmp    801468 <vprintfmt+0x1da>
  8014a5:	89 cf                	mov    %ecx,%edi
  8014a7:	eb 0e                	jmp    8014b7 <vprintfmt+0x229>
				putch(' ', putdat);
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	56                   	push   %esi
  8014ad:	6a 20                	push   $0x20
  8014af:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014b1:	83 ef 01             	sub    $0x1,%edi
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	85 ff                	test   %edi,%edi
  8014b9:	7f ee                	jg     8014a9 <vprintfmt+0x21b>
  8014bb:	eb 6f                	jmp    80152c <vprintfmt+0x29e>
  8014bd:	89 cf                	mov    %ecx,%edi
  8014bf:	eb f6                	jmp    8014b7 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014c1:	89 ca                	mov    %ecx,%edx
  8014c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8014c6:	e8 55 fd ff ff       	call   801220 <getint>
  8014cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014d1:	85 d2                	test   %edx,%edx
  8014d3:	78 0b                	js     8014e0 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014d5:	89 d1                	mov    %edx,%ecx
  8014d7:	89 c2                	mov    %eax,%edx
			base = 10;
  8014d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014de:	eb 32                	jmp    801512 <vprintfmt+0x284>
				putch('-', putdat);
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	56                   	push   %esi
  8014e4:	6a 2d                	push   $0x2d
  8014e6:	ff d3                	call   *%ebx
				num = -(long long) num;
  8014e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014ee:	f7 da                	neg    %edx
  8014f0:	83 d1 00             	adc    $0x0,%ecx
  8014f3:	f7 d9                	neg    %ecx
  8014f5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014fd:	eb 13                	jmp    801512 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8014ff:	89 ca                	mov    %ecx,%edx
  801501:	8d 45 14             	lea    0x14(%ebp),%eax
  801504:	e8 e3 fc ff ff       	call   8011ec <getuint>
  801509:	89 d1                	mov    %edx,%ecx
  80150b:	89 c2                	mov    %eax,%edx
			base = 10;
  80150d:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801512:	83 ec 0c             	sub    $0xc,%esp
  801515:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801519:	57                   	push   %edi
  80151a:	ff 75 e0             	pushl  -0x20(%ebp)
  80151d:	50                   	push   %eax
  80151e:	51                   	push   %ecx
  80151f:	52                   	push   %edx
  801520:	89 f2                	mov    %esi,%edx
  801522:	89 d8                	mov    %ebx,%eax
  801524:	e8 1a fc ff ff       	call   801143 <printnum>
			break;
  801529:	83 c4 20             	add    $0x20,%esp
{
  80152c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80152f:	83 c7 01             	add    $0x1,%edi
  801532:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801536:	83 f8 25             	cmp    $0x25,%eax
  801539:	0f 84 6a fd ff ff    	je     8012a9 <vprintfmt+0x1b>
			if (ch == '\0')
  80153f:	85 c0                	test   %eax,%eax
  801541:	0f 84 93 00 00 00    	je     8015da <vprintfmt+0x34c>
			putch(ch, putdat);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	56                   	push   %esi
  80154b:	50                   	push   %eax
  80154c:	ff d3                	call   *%ebx
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	eb dc                	jmp    80152f <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801553:	89 ca                	mov    %ecx,%edx
  801555:	8d 45 14             	lea    0x14(%ebp),%eax
  801558:	e8 8f fc ff ff       	call   8011ec <getuint>
  80155d:	89 d1                	mov    %edx,%ecx
  80155f:	89 c2                	mov    %eax,%edx
			base = 8;
  801561:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801566:	eb aa                	jmp    801512 <vprintfmt+0x284>
			putch('0', putdat);
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	56                   	push   %esi
  80156c:	6a 30                	push   $0x30
  80156e:	ff d3                	call   *%ebx
			putch('x', putdat);
  801570:	83 c4 08             	add    $0x8,%esp
  801573:	56                   	push   %esi
  801574:	6a 78                	push   $0x78
  801576:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  801578:	8b 45 14             	mov    0x14(%ebp),%eax
  80157b:	8d 50 04             	lea    0x4(%eax),%edx
  80157e:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801581:	8b 10                	mov    (%eax),%edx
  801583:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801588:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80158b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801590:	eb 80                	jmp    801512 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801592:	89 ca                	mov    %ecx,%edx
  801594:	8d 45 14             	lea    0x14(%ebp),%eax
  801597:	e8 50 fc ff ff       	call   8011ec <getuint>
  80159c:	89 d1                	mov    %edx,%ecx
  80159e:	89 c2                	mov    %eax,%edx
			base = 16;
  8015a0:	b8 10 00 00 00       	mov    $0x10,%eax
  8015a5:	e9 68 ff ff ff       	jmp    801512 <vprintfmt+0x284>
			putch(ch, putdat);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	56                   	push   %esi
  8015ae:	6a 25                	push   $0x25
  8015b0:	ff d3                	call   *%ebx
			break;
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	e9 72 ff ff ff       	jmp    80152c <vprintfmt+0x29e>
			putch('%', putdat);
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	56                   	push   %esi
  8015be:	6a 25                	push   $0x25
  8015c0:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	89 f8                	mov    %edi,%eax
  8015c7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015cb:	74 05                	je     8015d2 <vprintfmt+0x344>
  8015cd:	83 e8 01             	sub    $0x1,%eax
  8015d0:	eb f5                	jmp    8015c7 <vprintfmt+0x339>
  8015d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015d5:	e9 52 ff ff ff       	jmp    80152c <vprintfmt+0x29e>
}
  8015da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5e                   	pop    %esi
  8015df:	5f                   	pop    %edi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015e2:	f3 0f 1e fb          	endbr32 
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	83 ec 18             	sub    $0x18,%esp
  8015ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801603:	85 c0                	test   %eax,%eax
  801605:	74 26                	je     80162d <vsnprintf+0x4b>
  801607:	85 d2                	test   %edx,%edx
  801609:	7e 22                	jle    80162d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80160b:	ff 75 14             	pushl  0x14(%ebp)
  80160e:	ff 75 10             	pushl  0x10(%ebp)
  801611:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	68 4c 12 80 00       	push   $0x80124c
  80161a:	e8 6f fc ff ff       	call   80128e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80161f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801622:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801625:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801628:	83 c4 10             	add    $0x10,%esp
}
  80162b:	c9                   	leave  
  80162c:	c3                   	ret    
		return -E_INVAL;
  80162d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801632:	eb f7                	jmp    80162b <vsnprintf+0x49>

00801634 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801634:	f3 0f 1e fb          	endbr32 
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80163e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801641:	50                   	push   %eax
  801642:	ff 75 10             	pushl  0x10(%ebp)
  801645:	ff 75 0c             	pushl  0xc(%ebp)
  801648:	ff 75 08             	pushl  0x8(%ebp)
  80164b:	e8 92 ff ff ff       	call   8015e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801650:	c9                   	leave  
  801651:	c3                   	ret    

00801652 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801652:	f3 0f 1e fb          	endbr32 
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80165c:	b8 00 00 00 00       	mov    $0x0,%eax
  801661:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801665:	74 05                	je     80166c <strlen+0x1a>
		n++;
  801667:	83 c0 01             	add    $0x1,%eax
  80166a:	eb f5                	jmp    801661 <strlen+0xf>
	return n;
}
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80166e:	f3 0f 1e fb          	endbr32 
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801678:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80167b:	b8 00 00 00 00       	mov    $0x0,%eax
  801680:	39 d0                	cmp    %edx,%eax
  801682:	74 0d                	je     801691 <strnlen+0x23>
  801684:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801688:	74 05                	je     80168f <strnlen+0x21>
		n++;
  80168a:	83 c0 01             	add    $0x1,%eax
  80168d:	eb f1                	jmp    801680 <strnlen+0x12>
  80168f:	89 c2                	mov    %eax,%edx
	return n;
}
  801691:	89 d0                	mov    %edx,%eax
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801695:	f3 0f 1e fb          	endbr32 
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	53                   	push   %ebx
  80169d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016ac:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016af:	83 c0 01             	add    $0x1,%eax
  8016b2:	84 d2                	test   %dl,%dl
  8016b4:	75 f2                	jne    8016a8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016b6:	89 c8                	mov    %ecx,%eax
  8016b8:	5b                   	pop    %ebx
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016bb:	f3 0f 1e fb          	endbr32 
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 10             	sub    $0x10,%esp
  8016c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016c9:	53                   	push   %ebx
  8016ca:	e8 83 ff ff ff       	call   801652 <strlen>
  8016cf:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016d2:	ff 75 0c             	pushl  0xc(%ebp)
  8016d5:	01 d8                	add    %ebx,%eax
  8016d7:	50                   	push   %eax
  8016d8:	e8 b8 ff ff ff       	call   801695 <strcpy>
	return dst;
}
  8016dd:	89 d8                	mov    %ebx,%eax
  8016df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e2:	c9                   	leave  
  8016e3:	c3                   	ret    

008016e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e4:	f3 0f 1e fb          	endbr32 
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f3:	89 f3                	mov    %esi,%ebx
  8016f5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f8:	89 f0                	mov    %esi,%eax
  8016fa:	39 d8                	cmp    %ebx,%eax
  8016fc:	74 11                	je     80170f <strncpy+0x2b>
		*dst++ = *src;
  8016fe:	83 c0 01             	add    $0x1,%eax
  801701:	0f b6 0a             	movzbl (%edx),%ecx
  801704:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801707:	80 f9 01             	cmp    $0x1,%cl
  80170a:	83 da ff             	sbb    $0xffffffff,%edx
  80170d:	eb eb                	jmp    8016fa <strncpy+0x16>
	}
	return ret;
}
  80170f:	89 f0                	mov    %esi,%eax
  801711:	5b                   	pop    %ebx
  801712:	5e                   	pop    %esi
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801715:	f3 0f 1e fb          	endbr32 
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	56                   	push   %esi
  80171d:	53                   	push   %ebx
  80171e:	8b 75 08             	mov    0x8(%ebp),%esi
  801721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801724:	8b 55 10             	mov    0x10(%ebp),%edx
  801727:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801729:	85 d2                	test   %edx,%edx
  80172b:	74 21                	je     80174e <strlcpy+0x39>
  80172d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801731:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801733:	39 c2                	cmp    %eax,%edx
  801735:	74 14                	je     80174b <strlcpy+0x36>
  801737:	0f b6 19             	movzbl (%ecx),%ebx
  80173a:	84 db                	test   %bl,%bl
  80173c:	74 0b                	je     801749 <strlcpy+0x34>
			*dst++ = *src++;
  80173e:	83 c1 01             	add    $0x1,%ecx
  801741:	83 c2 01             	add    $0x1,%edx
  801744:	88 5a ff             	mov    %bl,-0x1(%edx)
  801747:	eb ea                	jmp    801733 <strlcpy+0x1e>
  801749:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80174b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80174e:	29 f0                	sub    %esi,%eax
}
  801750:	5b                   	pop    %ebx
  801751:	5e                   	pop    %esi
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801754:	f3 0f 1e fb          	endbr32 
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801761:	0f b6 01             	movzbl (%ecx),%eax
  801764:	84 c0                	test   %al,%al
  801766:	74 0c                	je     801774 <strcmp+0x20>
  801768:	3a 02                	cmp    (%edx),%al
  80176a:	75 08                	jne    801774 <strcmp+0x20>
		p++, q++;
  80176c:	83 c1 01             	add    $0x1,%ecx
  80176f:	83 c2 01             	add    $0x1,%edx
  801772:	eb ed                	jmp    801761 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801774:	0f b6 c0             	movzbl %al,%eax
  801777:	0f b6 12             	movzbl (%edx),%edx
  80177a:	29 d0                	sub    %edx,%eax
}
  80177c:	5d                   	pop    %ebp
  80177d:	c3                   	ret    

0080177e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80177e:	f3 0f 1e fb          	endbr32 
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	53                   	push   %ebx
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178c:	89 c3                	mov    %eax,%ebx
  80178e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801791:	eb 06                	jmp    801799 <strncmp+0x1b>
		n--, p++, q++;
  801793:	83 c0 01             	add    $0x1,%eax
  801796:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801799:	39 d8                	cmp    %ebx,%eax
  80179b:	74 16                	je     8017b3 <strncmp+0x35>
  80179d:	0f b6 08             	movzbl (%eax),%ecx
  8017a0:	84 c9                	test   %cl,%cl
  8017a2:	74 04                	je     8017a8 <strncmp+0x2a>
  8017a4:	3a 0a                	cmp    (%edx),%cl
  8017a6:	74 eb                	je     801793 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a8:	0f b6 00             	movzbl (%eax),%eax
  8017ab:	0f b6 12             	movzbl (%edx),%edx
  8017ae:	29 d0                	sub    %edx,%eax
}
  8017b0:	5b                   	pop    %ebx
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    
		return 0;
  8017b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b8:	eb f6                	jmp    8017b0 <strncmp+0x32>

008017ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ba:	f3 0f 1e fb          	endbr32 
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c8:	0f b6 10             	movzbl (%eax),%edx
  8017cb:	84 d2                	test   %dl,%dl
  8017cd:	74 09                	je     8017d8 <strchr+0x1e>
		if (*s == c)
  8017cf:	38 ca                	cmp    %cl,%dl
  8017d1:	74 0a                	je     8017dd <strchr+0x23>
	for (; *s; s++)
  8017d3:	83 c0 01             	add    $0x1,%eax
  8017d6:	eb f0                	jmp    8017c8 <strchr+0xe>
			return (char *) s;
	return 0;
  8017d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017dd:	5d                   	pop    %ebp
  8017de:	c3                   	ret    

008017df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017df:	f3 0f 1e fb          	endbr32 
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f0:	38 ca                	cmp    %cl,%dl
  8017f2:	74 09                	je     8017fd <strfind+0x1e>
  8017f4:	84 d2                	test   %dl,%dl
  8017f6:	74 05                	je     8017fd <strfind+0x1e>
	for (; *s; s++)
  8017f8:	83 c0 01             	add    $0x1,%eax
  8017fb:	eb f0                	jmp    8017ed <strfind+0xe>
			break;
	return (char *) s;
}
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017ff:	f3 0f 1e fb          	endbr32 
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	57                   	push   %edi
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	8b 55 08             	mov    0x8(%ebp),%edx
  80180c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80180f:	85 c9                	test   %ecx,%ecx
  801811:	74 33                	je     801846 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801813:	89 d0                	mov    %edx,%eax
  801815:	09 c8                	or     %ecx,%eax
  801817:	a8 03                	test   $0x3,%al
  801819:	75 23                	jne    80183e <memset+0x3f>
		c &= 0xFF;
  80181b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181f:	89 d8                	mov    %ebx,%eax
  801821:	c1 e0 08             	shl    $0x8,%eax
  801824:	89 df                	mov    %ebx,%edi
  801826:	c1 e7 18             	shl    $0x18,%edi
  801829:	89 de                	mov    %ebx,%esi
  80182b:	c1 e6 10             	shl    $0x10,%esi
  80182e:	09 f7                	or     %esi,%edi
  801830:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801832:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801835:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801837:	89 d7                	mov    %edx,%edi
  801839:	fc                   	cld    
  80183a:	f3 ab                	rep stos %eax,%es:(%edi)
  80183c:	eb 08                	jmp    801846 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80183e:	89 d7                	mov    %edx,%edi
  801840:	8b 45 0c             	mov    0xc(%ebp),%eax
  801843:	fc                   	cld    
  801844:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801846:	89 d0                	mov    %edx,%eax
  801848:	5b                   	pop    %ebx
  801849:	5e                   	pop    %esi
  80184a:	5f                   	pop    %edi
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    

0080184d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80184d:	f3 0f 1e fb          	endbr32 
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	57                   	push   %edi
  801855:	56                   	push   %esi
  801856:	8b 45 08             	mov    0x8(%ebp),%eax
  801859:	8b 75 0c             	mov    0xc(%ebp),%esi
  80185c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80185f:	39 c6                	cmp    %eax,%esi
  801861:	73 32                	jae    801895 <memmove+0x48>
  801863:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801866:	39 c2                	cmp    %eax,%edx
  801868:	76 2b                	jbe    801895 <memmove+0x48>
		s += n;
		d += n;
  80186a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186d:	89 fe                	mov    %edi,%esi
  80186f:	09 ce                	or     %ecx,%esi
  801871:	09 d6                	or     %edx,%esi
  801873:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801879:	75 0e                	jne    801889 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80187b:	83 ef 04             	sub    $0x4,%edi
  80187e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801881:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801884:	fd                   	std    
  801885:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801887:	eb 09                	jmp    801892 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801889:	83 ef 01             	sub    $0x1,%edi
  80188c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80188f:	fd                   	std    
  801890:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801892:	fc                   	cld    
  801893:	eb 1a                	jmp    8018af <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801895:	89 c2                	mov    %eax,%edx
  801897:	09 ca                	or     %ecx,%edx
  801899:	09 f2                	or     %esi,%edx
  80189b:	f6 c2 03             	test   $0x3,%dl
  80189e:	75 0a                	jne    8018aa <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018a0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018a3:	89 c7                	mov    %eax,%edi
  8018a5:	fc                   	cld    
  8018a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a8:	eb 05                	jmp    8018af <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018aa:	89 c7                	mov    %eax,%edi
  8018ac:	fc                   	cld    
  8018ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018af:	5e                   	pop    %esi
  8018b0:	5f                   	pop    %edi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b3:	f3 0f 1e fb          	endbr32 
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018bd:	ff 75 10             	pushl  0x10(%ebp)
  8018c0:	ff 75 0c             	pushl  0xc(%ebp)
  8018c3:	ff 75 08             	pushl  0x8(%ebp)
  8018c6:	e8 82 ff ff ff       	call   80184d <memmove>
}
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    

008018cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018cd:	f3 0f 1e fb          	endbr32 
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018dc:	89 c6                	mov    %eax,%esi
  8018de:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e1:	39 f0                	cmp    %esi,%eax
  8018e3:	74 1c                	je     801901 <memcmp+0x34>
		if (*s1 != *s2)
  8018e5:	0f b6 08             	movzbl (%eax),%ecx
  8018e8:	0f b6 1a             	movzbl (%edx),%ebx
  8018eb:	38 d9                	cmp    %bl,%cl
  8018ed:	75 08                	jne    8018f7 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018ef:	83 c0 01             	add    $0x1,%eax
  8018f2:	83 c2 01             	add    $0x1,%edx
  8018f5:	eb ea                	jmp    8018e1 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8018f7:	0f b6 c1             	movzbl %cl,%eax
  8018fa:	0f b6 db             	movzbl %bl,%ebx
  8018fd:	29 d8                	sub    %ebx,%eax
  8018ff:	eb 05                	jmp    801906 <memcmp+0x39>
	}

	return 0;
  801901:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80190a:	f3 0f 1e fb          	endbr32 
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801917:	89 c2                	mov    %eax,%edx
  801919:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80191c:	39 d0                	cmp    %edx,%eax
  80191e:	73 09                	jae    801929 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801920:	38 08                	cmp    %cl,(%eax)
  801922:	74 05                	je     801929 <memfind+0x1f>
	for (; s < ends; s++)
  801924:	83 c0 01             	add    $0x1,%eax
  801927:	eb f3                	jmp    80191c <memfind+0x12>
			break;
	return (void *) s;
}
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80192b:	f3 0f 1e fb          	endbr32 
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	57                   	push   %edi
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
  801935:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801938:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80193b:	eb 03                	jmp    801940 <strtol+0x15>
		s++;
  80193d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801940:	0f b6 01             	movzbl (%ecx),%eax
  801943:	3c 20                	cmp    $0x20,%al
  801945:	74 f6                	je     80193d <strtol+0x12>
  801947:	3c 09                	cmp    $0x9,%al
  801949:	74 f2                	je     80193d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80194b:	3c 2b                	cmp    $0x2b,%al
  80194d:	74 2a                	je     801979 <strtol+0x4e>
	int neg = 0;
  80194f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801954:	3c 2d                	cmp    $0x2d,%al
  801956:	74 2b                	je     801983 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801958:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80195e:	75 0f                	jne    80196f <strtol+0x44>
  801960:	80 39 30             	cmpb   $0x30,(%ecx)
  801963:	74 28                	je     80198d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801965:	85 db                	test   %ebx,%ebx
  801967:	b8 0a 00 00 00       	mov    $0xa,%eax
  80196c:	0f 44 d8             	cmove  %eax,%ebx
  80196f:	b8 00 00 00 00       	mov    $0x0,%eax
  801974:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801977:	eb 46                	jmp    8019bf <strtol+0x94>
		s++;
  801979:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80197c:	bf 00 00 00 00       	mov    $0x0,%edi
  801981:	eb d5                	jmp    801958 <strtol+0x2d>
		s++, neg = 1;
  801983:	83 c1 01             	add    $0x1,%ecx
  801986:	bf 01 00 00 00       	mov    $0x1,%edi
  80198b:	eb cb                	jmp    801958 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801991:	74 0e                	je     8019a1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801993:	85 db                	test   %ebx,%ebx
  801995:	75 d8                	jne    80196f <strtol+0x44>
		s++, base = 8;
  801997:	83 c1 01             	add    $0x1,%ecx
  80199a:	bb 08 00 00 00       	mov    $0x8,%ebx
  80199f:	eb ce                	jmp    80196f <strtol+0x44>
		s += 2, base = 16;
  8019a1:	83 c1 02             	add    $0x2,%ecx
  8019a4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a9:	eb c4                	jmp    80196f <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019ab:	0f be d2             	movsbl %dl,%edx
  8019ae:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019b1:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019b4:	7d 3a                	jge    8019f0 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019b6:	83 c1 01             	add    $0x1,%ecx
  8019b9:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019bd:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019bf:	0f b6 11             	movzbl (%ecx),%edx
  8019c2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c5:	89 f3                	mov    %esi,%ebx
  8019c7:	80 fb 09             	cmp    $0x9,%bl
  8019ca:	76 df                	jbe    8019ab <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019cc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019cf:	89 f3                	mov    %esi,%ebx
  8019d1:	80 fb 19             	cmp    $0x19,%bl
  8019d4:	77 08                	ja     8019de <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019d6:	0f be d2             	movsbl %dl,%edx
  8019d9:	83 ea 57             	sub    $0x57,%edx
  8019dc:	eb d3                	jmp    8019b1 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8019de:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e1:	89 f3                	mov    %esi,%ebx
  8019e3:	80 fb 19             	cmp    $0x19,%bl
  8019e6:	77 08                	ja     8019f0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019e8:	0f be d2             	movsbl %dl,%edx
  8019eb:	83 ea 37             	sub    $0x37,%edx
  8019ee:	eb c1                	jmp    8019b1 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f4:	74 05                	je     8019fb <strtol+0xd0>
		*endptr = (char *) s;
  8019f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019f9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019fb:	89 c2                	mov    %eax,%edx
  8019fd:	f7 da                	neg    %edx
  8019ff:	85 ff                	test   %edi,%edi
  801a01:	0f 45 c2             	cmovne %edx,%eax
}
  801a04:	5b                   	pop    %ebx
  801a05:	5e                   	pop    %esi
  801a06:	5f                   	pop    %edi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a09:	f3 0f 1e fb          	endbr32 
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	8b 75 08             	mov    0x8(%ebp),%esi
  801a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a22:	0f 44 c2             	cmove  %edx,%eax
  801a25:	83 ec 0c             	sub    $0xc,%esp
  801a28:	50                   	push   %eax
  801a29:	e8 a7 e8 ff ff       	call   8002d5 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	85 f6                	test   %esi,%esi
  801a33:	74 15                	je     801a4a <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801a35:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3a:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a3d:	74 09                	je     801a48 <ipc_recv+0x3f>
  801a3f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a45:	8b 52 74             	mov    0x74(%edx),%edx
  801a48:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801a4a:	85 db                	test   %ebx,%ebx
  801a4c:	74 15                	je     801a63 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801a4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a53:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a56:	74 09                	je     801a61 <ipc_recv+0x58>
  801a58:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a5e:	8b 52 78             	mov    0x78(%edx),%edx
  801a61:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801a63:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a66:	74 08                	je     801a70 <ipc_recv+0x67>
  801a68:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a73:	5b                   	pop    %ebx
  801a74:	5e                   	pop    %esi
  801a75:	5d                   	pop    %ebp
  801a76:	c3                   	ret    

00801a77 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a77:	f3 0f 1e fb          	endbr32 
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	57                   	push   %edi
  801a7f:	56                   	push   %esi
  801a80:	53                   	push   %ebx
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a87:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a8d:	eb 1f                	jmp    801aae <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801a8f:	6a 00                	push   $0x0
  801a91:	68 00 00 c0 ee       	push   $0xeec00000
  801a96:	56                   	push   %esi
  801a97:	57                   	push   %edi
  801a98:	e8 0f e8 ff ff       	call   8002ac <sys_ipc_try_send>
  801a9d:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	74 30                	je     801ad4 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801aa4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa7:	75 19                	jne    801ac2 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801aa9:	e8 e5 e6 ff ff       	call   800193 <sys_yield>
		if (pg != NULL) {
  801aae:	85 db                	test   %ebx,%ebx
  801ab0:	74 dd                	je     801a8f <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801ab2:	ff 75 14             	pushl  0x14(%ebp)
  801ab5:	53                   	push   %ebx
  801ab6:	56                   	push   %esi
  801ab7:	57                   	push   %edi
  801ab8:	e8 ef e7 ff ff       	call   8002ac <sys_ipc_try_send>
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	eb de                	jmp    801aa0 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801ac2:	50                   	push   %eax
  801ac3:	68 ff 21 80 00       	push   $0x8021ff
  801ac8:	6a 3e                	push   $0x3e
  801aca:	68 0c 22 80 00       	push   $0x80220c
  801acf:	e8 70 f5 ff ff       	call   801044 <_panic>
	}
}
  801ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5f                   	pop    %edi
  801ada:	5d                   	pop    %ebp
  801adb:	c3                   	ret    

00801adc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801adc:	f3 0f 1e fb          	endbr32 
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ae6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aeb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aee:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af4:	8b 52 50             	mov    0x50(%edx),%edx
  801af7:	39 ca                	cmp    %ecx,%edx
  801af9:	74 11                	je     801b0c <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801afb:	83 c0 01             	add    $0x1,%eax
  801afe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b03:	75 e6                	jne    801aeb <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b05:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0a:	eb 0b                	jmp    801b17 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b0c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b0f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b14:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b19:	f3 0f 1e fb          	endbr32 
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b23:	89 c2                	mov    %eax,%edx
  801b25:	c1 ea 16             	shr    $0x16,%edx
  801b28:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b2f:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b34:	f6 c1 01             	test   $0x1,%cl
  801b37:	74 1c                	je     801b55 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b39:	c1 e8 0c             	shr    $0xc,%eax
  801b3c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b43:	a8 01                	test   $0x1,%al
  801b45:	74 0e                	je     801b55 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b47:	c1 e8 0c             	shr    $0xc,%eax
  801b4a:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b51:	ef 
  801b52:	0f b7 d2             	movzwl %dx,%edx
}
  801b55:	89 d0                	mov    %edx,%eax
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    
  801b59:	66 90                	xchg   %ax,%ax
  801b5b:	66 90                	xchg   %ax,%ax
  801b5d:	66 90                	xchg   %ax,%ax
  801b5f:	90                   	nop

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
