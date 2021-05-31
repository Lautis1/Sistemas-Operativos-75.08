
obj/user/faultnostack.debug:     formato del fichero elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003d:	68 15 03 80 00       	push   $0x800315
  800042:	6a 00                	push   $0x0
  800044:	e8 56 02 00 00       	call   80029f <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800049:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800050:	00 00 00 
}
  800053:	83 c4 10             	add    $0x10,%esp
  800056:	c9                   	leave  
  800057:	c3                   	ret    

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	f3 0f 1e fb          	endbr32 
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800067:	e8 19 01 00 00       	call   800185 <sys_getenvid>
	if (id >= 0)
  80006c:	85 c0                	test   %eax,%eax
  80006e:	78 12                	js     800082 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x35>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	f3 0f 1e fb          	endbr32 
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b0:	e8 7b 04 00 00       	call   800530 <close_all>
	sys_env_destroy(0);
  8000b5:	83 ec 0c             	sub    $0xc,%esp
  8000b8:	6a 00                	push   $0x0
  8000ba:	e8 a0 00 00 00       	call   80015f <sys_env_destroy>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
  8000ca:	83 ec 1c             	sub    $0x1c,%esp
  8000cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000d3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000db:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000de:	8b 75 14             	mov    0x14(%ebp),%esi
  8000e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000e7:	74 04                	je     8000ed <syscall+0x29>
  8000e9:	85 c0                	test   %eax,%eax
  8000eb:	7f 08                	jg     8000f5 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000fc:	68 6a 1e 80 00       	push   $0x801e6a
  800101:	6a 23                	push   $0x23
  800103:	68 87 1e 80 00       	push   $0x801e87
  800108:	e8 79 0f 00 00       	call   801086 <_panic>

0080010d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80010d:	f3 0f 1e fb          	endbr32 
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800117:	6a 00                	push   $0x0
  800119:	6a 00                	push   $0x0
  80011b:	6a 00                	push   $0x0
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 00 00 00 00       	mov    $0x0,%eax
  80012d:	e8 92 ff ff ff       	call   8000c4 <syscall>
}
  800132:	83 c4 10             	add    $0x10,%esp
  800135:	c9                   	leave  
  800136:	c3                   	ret    

00800137 <sys_cgetc>:

int
sys_cgetc(void)
{
  800137:	f3 0f 1e fb          	endbr32 
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800141:	6a 00                	push   $0x0
  800143:	6a 00                	push   $0x0
  800145:	6a 00                	push   $0x0
  800147:	6a 00                	push   $0x0
  800149:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014e:	ba 00 00 00 00       	mov    $0x0,%edx
  800153:	b8 01 00 00 00       	mov    $0x1,%eax
  800158:	e8 67 ff ff ff       	call   8000c4 <syscall>
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80015f:	f3 0f 1e fb          	endbr32 
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800169:	6a 00                	push   $0x0
  80016b:	6a 00                	push   $0x0
  80016d:	6a 00                	push   $0x0
  80016f:	6a 00                	push   $0x0
  800171:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800174:	ba 01 00 00 00       	mov    $0x1,%edx
  800179:	b8 03 00 00 00       	mov    $0x3,%eax
  80017e:	e8 41 ff ff ff       	call   8000c4 <syscall>
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800185:	f3 0f 1e fb          	endbr32 
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80018f:	6a 00                	push   $0x0
  800191:	6a 00                	push   $0x0
  800193:	6a 00                	push   $0x0
  800195:	6a 00                	push   $0x0
  800197:	b9 00 00 00 00       	mov    $0x0,%ecx
  80019c:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a1:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a6:	e8 19 ff ff ff       	call   8000c4 <syscall>
}
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <sys_yield>:

void
sys_yield(void)
{
  8001ad:	f3 0f 1e fb          	endbr32 
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001b7:	6a 00                	push   $0x0
  8001b9:	6a 00                	push   $0x0
  8001bb:	6a 00                	push   $0x0
  8001bd:	6a 00                	push   $0x0
  8001bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ce:	e8 f1 fe ff ff       	call   8000c4 <syscall>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d8:	f3 0f 1e fb          	endbr32 
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001e2:	6a 00                	push   $0x0
  8001e4:	6a 00                	push   $0x0
  8001e6:	ff 75 10             	pushl  0x10(%ebp)
  8001e9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ef:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f9:	e8 c6 fe ff ff       	call   8000c4 <syscall>
}
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800200:	f3 0f 1e fb          	endbr32 
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80020a:	ff 75 18             	pushl  0x18(%ebp)
  80020d:	ff 75 14             	pushl  0x14(%ebp)
  800210:	ff 75 10             	pushl  0x10(%ebp)
  800213:	ff 75 0c             	pushl  0xc(%ebp)
  800216:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800219:	ba 01 00 00 00       	mov    $0x1,%edx
  80021e:	b8 05 00 00 00       	mov    $0x5,%eax
  800223:	e8 9c fe ff ff       	call   8000c4 <syscall>
}
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022a:	f3 0f 1e fb          	endbr32 
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800234:	6a 00                	push   $0x0
  800236:	6a 00                	push   $0x0
  800238:	6a 00                	push   $0x0
  80023a:	ff 75 0c             	pushl  0xc(%ebp)
  80023d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800240:	ba 01 00 00 00       	mov    $0x1,%edx
  800245:	b8 06 00 00 00       	mov    $0x6,%eax
  80024a:	e8 75 fe ff ff       	call   8000c4 <syscall>
}
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800251:	f3 0f 1e fb          	endbr32 
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80025b:	6a 00                	push   $0x0
  80025d:	6a 00                	push   $0x0
  80025f:	6a 00                	push   $0x0
  800261:	ff 75 0c             	pushl  0xc(%ebp)
  800264:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800267:	ba 01 00 00 00       	mov    $0x1,%edx
  80026c:	b8 08 00 00 00       	mov    $0x8,%eax
  800271:	e8 4e fe ff ff       	call   8000c4 <syscall>
}
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800278:	f3 0f 1e fb          	endbr32 
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800282:	6a 00                	push   $0x0
  800284:	6a 00                	push   $0x0
  800286:	6a 00                	push   $0x0
  800288:	ff 75 0c             	pushl  0xc(%ebp)
  80028b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028e:	ba 01 00 00 00       	mov    $0x1,%edx
  800293:	b8 09 00 00 00       	mov    $0x9,%eax
  800298:	e8 27 fe ff ff       	call   8000c4 <syscall>
}
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029f:	f3 0f 1e fb          	endbr32 
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8002a9:	6a 00                	push   $0x0
  8002ab:	6a 00                	push   $0x0
  8002ad:	6a 00                	push   $0x0
  8002af:	ff 75 0c             	pushl  0xc(%ebp)
  8002b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b5:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bf:	e8 00 fe ff ff       	call   8000c4 <syscall>
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c6:	f3 0f 1e fb          	endbr32 
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002d0:	6a 00                	push   $0x0
  8002d2:	ff 75 14             	pushl  0x14(%ebp)
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e8:	e8 d7 fd ff ff       	call   8000c4 <syscall>
}
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ef:	f3 0f 1e fb          	endbr32 
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002f9:	6a 00                	push   $0x0
  8002fb:	6a 00                	push   $0x0
  8002fd:	6a 00                	push   $0x0
  8002ff:	6a 00                	push   $0x0
  800301:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800304:	ba 01 00 00 00       	mov    $0x1,%edx
  800309:	b8 0d 00 00 00       	mov    $0xd,%eax
  80030e:	e8 b1 fd ff ff       	call   8000c4 <syscall>
}
  800313:	c9                   	leave  
  800314:	c3                   	ret    

00800315 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800315:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800316:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80031b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  800320:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  800324:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800328:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  80032b:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  80032d:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800331:	83 c4 08             	add    $0x8,%esp
	popal
  800334:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800335:	83 c4 04             	add    $0x4,%esp
	popfl
  800338:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  800339:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80033c:	c3                   	ret    

0080033d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80033d:	f3 0f 1e fb          	endbr32 
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	05 00 00 00 30       	add    $0x30000000,%eax
  80034c:	c1 e8 0c             	shr    $0xc,%eax
}
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800351:	f3 0f 1e fb          	endbr32 
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 da ff ff ff       	call   80033d <fd2num>
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c1 e0 0c             	shl    $0xc,%eax
  800369:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800370:	f3 0f 1e fb          	endbr32 
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037c:	89 c2                	mov    %eax,%edx
  80037e:	c1 ea 16             	shr    $0x16,%edx
  800381:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800388:	f6 c2 01             	test   $0x1,%dl
  80038b:	74 2d                	je     8003ba <fd_alloc+0x4a>
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 0c             	shr    $0xc,%edx
  800392:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 1c                	je     8003ba <fd_alloc+0x4a>
  80039e:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003a3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a8:	75 d2                	jne    80037c <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003b3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003b8:	eb 0a                	jmp    8003c4 <fd_alloc+0x54>
			*fd_store = fd;
  8003ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c6:	f3 0f 1e fb          	endbr32 
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 30                	ja     800405 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003e3:	f6 c2 01             	test   $0x1,%dl
  8003e6:	74 24                	je     80040c <fd_lookup+0x46>
  8003e8:	89 c2                	mov    %eax,%edx
  8003ea:	c1 ea 0c             	shr    $0xc,%edx
  8003ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f4:	f6 c2 01             	test   $0x1,%dl
  8003f7:	74 1a                	je     800413 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fc:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800403:	5d                   	pop    %ebp
  800404:	c3                   	ret    
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb f7                	jmp    800403 <fd_lookup+0x3d>
		return -E_INVAL;
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800411:	eb f0                	jmp    800403 <fd_lookup+0x3d>
  800413:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800418:	eb e9                	jmp    800403 <fd_lookup+0x3d>

0080041a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041a:	f3 0f 1e fb          	endbr32 
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800427:	ba 14 1f 80 00       	mov    $0x801f14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042c:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800431:	39 08                	cmp    %ecx,(%eax)
  800433:	74 33                	je     800468 <dev_lookup+0x4e>
  800435:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800438:	8b 02                	mov    (%edx),%eax
  80043a:	85 c0                	test   %eax,%eax
  80043c:	75 f3                	jne    800431 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043e:	a1 04 40 80 00       	mov    0x804004,%eax
  800443:	8b 40 48             	mov    0x48(%eax),%eax
  800446:	83 ec 04             	sub    $0x4,%esp
  800449:	51                   	push   %ecx
  80044a:	50                   	push   %eax
  80044b:	68 98 1e 80 00       	push   $0x801e98
  800450:	e8 18 0d 00 00       	call   80116d <cprintf>
	*dev = 0;
  800455:	8b 45 0c             	mov    0xc(%ebp),%eax
  800458:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800466:	c9                   	leave  
  800467:	c3                   	ret    
			*dev = devtab[i];
  800468:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	eb f2                	jmp    800466 <dev_lookup+0x4c>

00800474 <fd_close>:
{
  800474:	f3 0f 1e fb          	endbr32 
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	57                   	push   %edi
  80047c:	56                   	push   %esi
  80047d:	53                   	push   %ebx
  80047e:	83 ec 28             	sub    $0x28,%esp
  800481:	8b 75 08             	mov    0x8(%ebp),%esi
  800484:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800487:	56                   	push   %esi
  800488:	e8 b0 fe ff ff       	call   80033d <fd2num>
  80048d:	83 c4 08             	add    $0x8,%esp
  800490:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800493:	52                   	push   %edx
  800494:	50                   	push   %eax
  800495:	e8 2c ff ff ff       	call   8003c6 <fd_lookup>
  80049a:	89 c3                	mov    %eax,%ebx
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	78 05                	js     8004a8 <fd_close+0x34>
	    || fd != fd2)
  8004a3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004a6:	74 16                	je     8004be <fd_close+0x4a>
		return (must_exist ? r : 0);
  8004a8:	89 f8                	mov    %edi,%eax
  8004aa:	84 c0                	test   %al,%al
  8004ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b1:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b4:	89 d8                	mov    %ebx,%eax
  8004b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c4:	50                   	push   %eax
  8004c5:	ff 36                	pushl  (%esi)
  8004c7:	e8 4e ff ff ff       	call   80041a <dev_lookup>
  8004cc:	89 c3                	mov    %eax,%ebx
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	78 1a                	js     8004ef <fd_close+0x7b>
		if (dev->dev_close)
  8004d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d8:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004db:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	74 0b                	je     8004ef <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004e4:	83 ec 0c             	sub    $0xc,%esp
  8004e7:	56                   	push   %esi
  8004e8:	ff d0                	call   *%eax
  8004ea:	89 c3                	mov    %eax,%ebx
  8004ec:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	6a 00                	push   $0x0
  8004f5:	e8 30 fd ff ff       	call   80022a <sys_page_unmap>
	return r;
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	eb b5                	jmp    8004b4 <fd_close+0x40>

008004ff <close>:

int
close(int fdnum)
{
  8004ff:	f3 0f 1e fb          	endbr32 
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800509:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050c:	50                   	push   %eax
  80050d:	ff 75 08             	pushl  0x8(%ebp)
  800510:	e8 b1 fe ff ff       	call   8003c6 <fd_lookup>
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	85 c0                	test   %eax,%eax
  80051a:	79 02                	jns    80051e <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80051c:	c9                   	leave  
  80051d:	c3                   	ret    
		return fd_close(fd, 1);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	6a 01                	push   $0x1
  800523:	ff 75 f4             	pushl  -0xc(%ebp)
  800526:	e8 49 ff ff ff       	call   800474 <fd_close>
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	eb ec                	jmp    80051c <close+0x1d>

00800530 <close_all>:

void
close_all(void)
{
  800530:	f3 0f 1e fb          	endbr32 
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	53                   	push   %ebx
  800538:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800540:	83 ec 0c             	sub    $0xc,%esp
  800543:	53                   	push   %ebx
  800544:	e8 b6 ff ff ff       	call   8004ff <close>
	for (i = 0; i < MAXFD; i++)
  800549:	83 c3 01             	add    $0x1,%ebx
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	83 fb 20             	cmp    $0x20,%ebx
  800552:	75 ec                	jne    800540 <close_all+0x10>
}
  800554:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800557:	c9                   	leave  
  800558:	c3                   	ret    

00800559 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800559:	f3 0f 1e fb          	endbr32 
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	57                   	push   %edi
  800561:	56                   	push   %esi
  800562:	53                   	push   %ebx
  800563:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800566:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800569:	50                   	push   %eax
  80056a:	ff 75 08             	pushl  0x8(%ebp)
  80056d:	e8 54 fe ff ff       	call   8003c6 <fd_lookup>
  800572:	89 c3                	mov    %eax,%ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	85 c0                	test   %eax,%eax
  800579:	0f 88 81 00 00 00    	js     800600 <dup+0xa7>
		return r;
	close(newfdnum);
  80057f:	83 ec 0c             	sub    $0xc,%esp
  800582:	ff 75 0c             	pushl  0xc(%ebp)
  800585:	e8 75 ff ff ff       	call   8004ff <close>

	newfd = INDEX2FD(newfdnum);
  80058a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80058d:	c1 e6 0c             	shl    $0xc,%esi
  800590:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800596:	83 c4 04             	add    $0x4,%esp
  800599:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059c:	e8 b0 fd ff ff       	call   800351 <fd2data>
  8005a1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005a3:	89 34 24             	mov    %esi,(%esp)
  8005a6:	e8 a6 fd ff ff       	call   800351 <fd2data>
  8005ab:	83 c4 10             	add    $0x10,%esp
  8005ae:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b0:	89 d8                	mov    %ebx,%eax
  8005b2:	c1 e8 16             	shr    $0x16,%eax
  8005b5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005bc:	a8 01                	test   $0x1,%al
  8005be:	74 11                	je     8005d1 <dup+0x78>
  8005c0:	89 d8                	mov    %ebx,%eax
  8005c2:	c1 e8 0c             	shr    $0xc,%eax
  8005c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005cc:	f6 c2 01             	test   $0x1,%dl
  8005cf:	75 39                	jne    80060a <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d4:	89 d0                	mov    %edx,%eax
  8005d6:	c1 e8 0c             	shr    $0xc,%eax
  8005d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e8:	50                   	push   %eax
  8005e9:	56                   	push   %esi
  8005ea:	6a 00                	push   $0x0
  8005ec:	52                   	push   %edx
  8005ed:	6a 00                	push   $0x0
  8005ef:	e8 0c fc ff ff       	call   800200 <sys_page_map>
  8005f4:	89 c3                	mov    %eax,%ebx
  8005f6:	83 c4 20             	add    $0x20,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	78 31                	js     80062e <dup+0xd5>
		goto err;

	return newfdnum;
  8005fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800600:	89 d8                	mov    %ebx,%eax
  800602:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800605:	5b                   	pop    %ebx
  800606:	5e                   	pop    %esi
  800607:	5f                   	pop    %edi
  800608:	5d                   	pop    %ebp
  800609:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80060a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	25 07 0e 00 00       	and    $0xe07,%eax
  800619:	50                   	push   %eax
  80061a:	57                   	push   %edi
  80061b:	6a 00                	push   $0x0
  80061d:	53                   	push   %ebx
  80061e:	6a 00                	push   $0x0
  800620:	e8 db fb ff ff       	call   800200 <sys_page_map>
  800625:	89 c3                	mov    %eax,%ebx
  800627:	83 c4 20             	add    $0x20,%esp
  80062a:	85 c0                	test   %eax,%eax
  80062c:	79 a3                	jns    8005d1 <dup+0x78>
	sys_page_unmap(0, newfd);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	56                   	push   %esi
  800632:	6a 00                	push   $0x0
  800634:	e8 f1 fb ff ff       	call   80022a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800639:	83 c4 08             	add    $0x8,%esp
  80063c:	57                   	push   %edi
  80063d:	6a 00                	push   $0x0
  80063f:	e8 e6 fb ff ff       	call   80022a <sys_page_unmap>
	return r;
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	eb b7                	jmp    800600 <dup+0xa7>

00800649 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800649:	f3 0f 1e fb          	endbr32 
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
  800650:	53                   	push   %ebx
  800651:	83 ec 1c             	sub    $0x1c,%esp
  800654:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800657:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	53                   	push   %ebx
  80065c:	e8 65 fd ff ff       	call   8003c6 <fd_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 3f                	js     8006a7 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80066e:	50                   	push   %eax
  80066f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800672:	ff 30                	pushl  (%eax)
  800674:	e8 a1 fd ff ff       	call   80041a <dev_lookup>
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	85 c0                	test   %eax,%eax
  80067e:	78 27                	js     8006a7 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800680:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800683:	8b 42 08             	mov    0x8(%edx),%eax
  800686:	83 e0 03             	and    $0x3,%eax
  800689:	83 f8 01             	cmp    $0x1,%eax
  80068c:	74 1e                	je     8006ac <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800691:	8b 40 08             	mov    0x8(%eax),%eax
  800694:	85 c0                	test   %eax,%eax
  800696:	74 35                	je     8006cd <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800698:	83 ec 04             	sub    $0x4,%esp
  80069b:	ff 75 10             	pushl  0x10(%ebp)
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	52                   	push   %edx
  8006a2:	ff d0                	call   *%eax
  8006a4:	83 c4 10             	add    $0x10,%esp
}
  8006a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006aa:	c9                   	leave  
  8006ab:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8006b1:	8b 40 48             	mov    0x48(%eax),%eax
  8006b4:	83 ec 04             	sub    $0x4,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	50                   	push   %eax
  8006b9:	68 d9 1e 80 00       	push   $0x801ed9
  8006be:	e8 aa 0a 00 00       	call   80116d <cprintf>
		return -E_INVAL;
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006cb:	eb da                	jmp    8006a7 <read+0x5e>
		return -E_NOT_SUPP;
  8006cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006d2:	eb d3                	jmp    8006a7 <read+0x5e>

008006d4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d4:	f3 0f 1e fb          	endbr32 
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	57                   	push   %edi
  8006dc:	56                   	push   %esi
  8006dd:	53                   	push   %ebx
  8006de:	83 ec 0c             	sub    $0xc,%esp
  8006e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ec:	eb 02                	jmp    8006f0 <readn+0x1c>
  8006ee:	01 c3                	add    %eax,%ebx
  8006f0:	39 f3                	cmp    %esi,%ebx
  8006f2:	73 21                	jae    800715 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f4:	83 ec 04             	sub    $0x4,%esp
  8006f7:	89 f0                	mov    %esi,%eax
  8006f9:	29 d8                	sub    %ebx,%eax
  8006fb:	50                   	push   %eax
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	03 45 0c             	add    0xc(%ebp),%eax
  800701:	50                   	push   %eax
  800702:	57                   	push   %edi
  800703:	e8 41 ff ff ff       	call   800649 <read>
		if (m < 0)
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	85 c0                	test   %eax,%eax
  80070d:	78 04                	js     800713 <readn+0x3f>
			return m;
		if (m == 0)
  80070f:	75 dd                	jne    8006ee <readn+0x1a>
  800711:	eb 02                	jmp    800715 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800713:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800715:	89 d8                	mov    %ebx,%eax
  800717:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071a:	5b                   	pop    %ebx
  80071b:	5e                   	pop    %esi
  80071c:	5f                   	pop    %edi
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071f:	f3 0f 1e fb          	endbr32 
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	53                   	push   %ebx
  800727:	83 ec 1c             	sub    $0x1c,%esp
  80072a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	53                   	push   %ebx
  800732:	e8 8f fc ff ff       	call   8003c6 <fd_lookup>
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	85 c0                	test   %eax,%eax
  80073c:	78 3a                	js     800778 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800744:	50                   	push   %eax
  800745:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800748:	ff 30                	pushl  (%eax)
  80074a:	e8 cb fc ff ff       	call   80041a <dev_lookup>
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	85 c0                	test   %eax,%eax
  800754:	78 22                	js     800778 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800756:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800759:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80075d:	74 1e                	je     80077d <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800762:	8b 52 0c             	mov    0xc(%edx),%edx
  800765:	85 d2                	test   %edx,%edx
  800767:	74 35                	je     80079e <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800769:	83 ec 04             	sub    $0x4,%esp
  80076c:	ff 75 10             	pushl  0x10(%ebp)
  80076f:	ff 75 0c             	pushl  0xc(%ebp)
  800772:	50                   	push   %eax
  800773:	ff d2                	call   *%edx
  800775:	83 c4 10             	add    $0x10,%esp
}
  800778:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80077d:	a1 04 40 80 00       	mov    0x804004,%eax
  800782:	8b 40 48             	mov    0x48(%eax),%eax
  800785:	83 ec 04             	sub    $0x4,%esp
  800788:	53                   	push   %ebx
  800789:	50                   	push   %eax
  80078a:	68 f5 1e 80 00       	push   $0x801ef5
  80078f:	e8 d9 09 00 00       	call   80116d <cprintf>
		return -E_INVAL;
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079c:	eb da                	jmp    800778 <write+0x59>
		return -E_NOT_SUPP;
  80079e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007a3:	eb d3                	jmp    800778 <write+0x59>

008007a5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a5:	f3 0f 1e fb          	endbr32 
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b2:	50                   	push   %eax
  8007b3:	ff 75 08             	pushl  0x8(%ebp)
  8007b6:	e8 0b fc ff ff       	call   8003c6 <fd_lookup>
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	78 0e                	js     8007d0 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d2:	f3 0f 1e fb          	endbr32 
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	83 ec 1c             	sub    $0x1c,%esp
  8007dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e3:	50                   	push   %eax
  8007e4:	53                   	push   %ebx
  8007e5:	e8 dc fb ff ff       	call   8003c6 <fd_lookup>
  8007ea:	83 c4 10             	add    $0x10,%esp
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	78 37                	js     800828 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f7:	50                   	push   %eax
  8007f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fb:	ff 30                	pushl  (%eax)
  8007fd:	e8 18 fc ff ff       	call   80041a <dev_lookup>
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	85 c0                	test   %eax,%eax
  800807:	78 1f                	js     800828 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800810:	74 1b                	je     80082d <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800812:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800815:	8b 52 18             	mov    0x18(%edx),%edx
  800818:	85 d2                	test   %edx,%edx
  80081a:	74 32                	je     80084e <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	50                   	push   %eax
  800823:	ff d2                	call   *%edx
  800825:	83 c4 10             	add    $0x10,%esp
}
  800828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80082d:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800832:	8b 40 48             	mov    0x48(%eax),%eax
  800835:	83 ec 04             	sub    $0x4,%esp
  800838:	53                   	push   %ebx
  800839:	50                   	push   %eax
  80083a:	68 b8 1e 80 00       	push   $0x801eb8
  80083f:	e8 29 09 00 00       	call   80116d <cprintf>
		return -E_INVAL;
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084c:	eb da                	jmp    800828 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80084e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800853:	eb d3                	jmp    800828 <ftruncate+0x56>

00800855 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800855:	f3 0f 1e fb          	endbr32 
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	83 ec 1c             	sub    $0x1c,%esp
  800860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800863:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800866:	50                   	push   %eax
  800867:	ff 75 08             	pushl  0x8(%ebp)
  80086a:	e8 57 fb ff ff       	call   8003c6 <fd_lookup>
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	85 c0                	test   %eax,%eax
  800874:	78 4b                	js     8008c1 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087c:	50                   	push   %eax
  80087d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800880:	ff 30                	pushl  (%eax)
  800882:	e8 93 fb ff ff       	call   80041a <dev_lookup>
  800887:	83 c4 10             	add    $0x10,%esp
  80088a:	85 c0                	test   %eax,%eax
  80088c:	78 33                	js     8008c1 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80088e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800891:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800895:	74 2f                	je     8008c6 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800897:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80089a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a1:	00 00 00 
	stat->st_isdir = 0;
  8008a4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ab:	00 00 00 
	stat->st_dev = dev;
  8008ae:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8008bb:	ff 50 14             	call   *0x14(%eax)
  8008be:	83 c4 10             	add    $0x10,%esp
}
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    
		return -E_NOT_SUPP;
  8008c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008cb:	eb f4                	jmp    8008c1 <fstat+0x6c>

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	f3 0f 1e fb          	endbr32 
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	56                   	push   %esi
  8008d5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	6a 00                	push   $0x0
  8008db:	ff 75 08             	pushl  0x8(%ebp)
  8008de:	e8 fb 01 00 00       	call   800ade <open>
  8008e3:	89 c3                	mov    %eax,%ebx
  8008e5:	83 c4 10             	add    $0x10,%esp
  8008e8:	85 c0                	test   %eax,%eax
  8008ea:	78 1b                	js     800907 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	ff 75 0c             	pushl  0xc(%ebp)
  8008f2:	50                   	push   %eax
  8008f3:	e8 5d ff ff ff       	call   800855 <fstat>
  8008f8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008fa:	89 1c 24             	mov    %ebx,(%esp)
  8008fd:	e8 fd fb ff ff       	call   8004ff <close>
	return r;
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	89 f3                	mov    %esi,%ebx
}
  800907:	89 d8                	mov    %ebx,%eax
  800909:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090c:	5b                   	pop    %ebx
  80090d:	5e                   	pop    %esi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	89 c6                	mov    %eax,%esi
  800917:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800919:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800920:	74 27                	je     800949 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800922:	6a 07                	push   $0x7
  800924:	68 00 50 80 00       	push   $0x805000
  800929:	56                   	push   %esi
  80092a:	ff 35 00 40 80 00    	pushl  0x804000
  800930:	e8 df 11 00 00       	call   801b14 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800935:	83 c4 0c             	add    $0xc,%esp
  800938:	6a 00                	push   $0x0
  80093a:	53                   	push   %ebx
  80093b:	6a 00                	push   $0x0
  80093d:	e8 64 11 00 00       	call   801aa6 <ipc_recv>
}
  800942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800949:	83 ec 0c             	sub    $0xc,%esp
  80094c:	6a 01                	push   $0x1
  80094e:	e8 26 12 00 00       	call   801b79 <ipc_find_env>
  800953:	a3 00 40 80 00       	mov    %eax,0x804000
  800958:	83 c4 10             	add    $0x10,%esp
  80095b:	eb c5                	jmp    800922 <fsipc+0x12>

0080095d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80095d:	f3 0f 1e fb          	endbr32 
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 40 0c             	mov    0xc(%eax),%eax
  80096d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800972:	8b 45 0c             	mov    0xc(%ebp),%eax
  800975:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80097a:	ba 00 00 00 00       	mov    $0x0,%edx
  80097f:	b8 02 00 00 00       	mov    $0x2,%eax
  800984:	e8 87 ff ff ff       	call   800910 <fsipc>
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <devfile_flush>:
{
  80098b:	f3 0f 1e fb          	endbr32 
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 40 0c             	mov    0xc(%eax),%eax
  80099b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8009aa:	e8 61 ff ff ff       	call   800910 <fsipc>
}
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <devfile_stat>:
{
  8009b1:	f3 0f 1e fb          	endbr32 
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	53                   	push   %ebx
  8009b9:	83 ec 04             	sub    $0x4,%esp
  8009bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d4:	e8 37 ff ff ff       	call   800910 <fsipc>
  8009d9:	85 c0                	test   %eax,%eax
  8009db:	78 2c                	js     800a09 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009dd:	83 ec 08             	sub    $0x8,%esp
  8009e0:	68 00 50 80 00       	push   $0x805000
  8009e5:	53                   	push   %ebx
  8009e6:	e8 ec 0c 00 00       	call   8016d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009eb:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a01:	83 c4 10             	add    $0x10,%esp
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <devfile_write>:
{
  800a0e:	f3 0f 1e fb          	endbr32 
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	83 ec 0c             	sub    $0xc,%esp
  800a18:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1e:	8b 52 0c             	mov    0xc(%edx),%edx
  800a21:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a27:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a2c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a31:	0f 47 c2             	cmova  %edx,%eax
  800a34:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a39:	50                   	push   %eax
  800a3a:	ff 75 0c             	pushl  0xc(%ebp)
  800a3d:	68 08 50 80 00       	push   $0x805008
  800a42:	e8 48 0e 00 00       	call   80188f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a47:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a51:	e8 ba fe ff ff       	call   800910 <fsipc>
}
  800a56:	c9                   	leave  
  800a57:	c3                   	ret    

00800a58 <devfile_read>:
{
  800a58:	f3 0f 1e fb          	endbr32 
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a6f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a75:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7f:	e8 8c fe ff ff       	call   800910 <fsipc>
  800a84:	89 c3                	mov    %eax,%ebx
  800a86:	85 c0                	test   %eax,%eax
  800a88:	78 1f                	js     800aa9 <devfile_read+0x51>
	assert(r <= n);
  800a8a:	39 f0                	cmp    %esi,%eax
  800a8c:	77 24                	ja     800ab2 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a8e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a93:	7f 33                	jg     800ac8 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a95:	83 ec 04             	sub    $0x4,%esp
  800a98:	50                   	push   %eax
  800a99:	68 00 50 80 00       	push   $0x805000
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	e8 e9 0d 00 00       	call   80188f <memmove>
	return r;
  800aa6:	83 c4 10             	add    $0x10,%esp
}
  800aa9:	89 d8                	mov    %ebx,%eax
  800aab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    
	assert(r <= n);
  800ab2:	68 24 1f 80 00       	push   $0x801f24
  800ab7:	68 2b 1f 80 00       	push   $0x801f2b
  800abc:	6a 7c                	push   $0x7c
  800abe:	68 40 1f 80 00       	push   $0x801f40
  800ac3:	e8 be 05 00 00       	call   801086 <_panic>
	assert(r <= PGSIZE);
  800ac8:	68 4b 1f 80 00       	push   $0x801f4b
  800acd:	68 2b 1f 80 00       	push   $0x801f2b
  800ad2:	6a 7d                	push   $0x7d
  800ad4:	68 40 1f 80 00       	push   $0x801f40
  800ad9:	e8 a8 05 00 00       	call   801086 <_panic>

00800ade <open>:
{
  800ade:	f3 0f 1e fb          	endbr32 
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 1c             	sub    $0x1c,%esp
  800aea:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aed:	56                   	push   %esi
  800aee:	e8 a1 0b 00 00       	call   801694 <strlen>
  800af3:	83 c4 10             	add    $0x10,%esp
  800af6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800afb:	7f 6c                	jg     800b69 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b03:	50                   	push   %eax
  800b04:	e8 67 f8 ff ff       	call   800370 <fd_alloc>
  800b09:	89 c3                	mov    %eax,%ebx
  800b0b:	83 c4 10             	add    $0x10,%esp
  800b0e:	85 c0                	test   %eax,%eax
  800b10:	78 3c                	js     800b4e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b12:	83 ec 08             	sub    $0x8,%esp
  800b15:	56                   	push   %esi
  800b16:	68 00 50 80 00       	push   $0x805000
  800b1b:	e8 b7 0b 00 00       	call   8016d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b23:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b2b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b30:	e8 db fd ff ff       	call   800910 <fsipc>
  800b35:	89 c3                	mov    %eax,%ebx
  800b37:	83 c4 10             	add    $0x10,%esp
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	78 19                	js     800b57 <open+0x79>
	return fd2num(fd);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	ff 75 f4             	pushl  -0xc(%ebp)
  800b44:	e8 f4 f7 ff ff       	call   80033d <fd2num>
  800b49:	89 c3                	mov    %eax,%ebx
  800b4b:	83 c4 10             	add    $0x10,%esp
}
  800b4e:	89 d8                	mov    %ebx,%eax
  800b50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    
		fd_close(fd, 0);
  800b57:	83 ec 08             	sub    $0x8,%esp
  800b5a:	6a 00                	push   $0x0
  800b5c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5f:	e8 10 f9 ff ff       	call   800474 <fd_close>
		return r;
  800b64:	83 c4 10             	add    $0x10,%esp
  800b67:	eb e5                	jmp    800b4e <open+0x70>
		return -E_BAD_PATH;
  800b69:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b6e:	eb de                	jmp    800b4e <open+0x70>

00800b70 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b70:	f3 0f 1e fb          	endbr32 
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 08 00 00 00       	mov    $0x8,%eax
  800b84:	e8 87 fd ff ff       	call   800910 <fsipc>
}
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b8b:	f3 0f 1e fb          	endbr32 
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	ff 75 08             	pushl  0x8(%ebp)
  800b9d:	e8 af f7 ff ff       	call   800351 <fd2data>
  800ba2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ba4:	83 c4 08             	add    $0x8,%esp
  800ba7:	68 57 1f 80 00       	push   $0x801f57
  800bac:	53                   	push   %ebx
  800bad:	e8 25 0b 00 00       	call   8016d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bb2:	8b 46 04             	mov    0x4(%esi),%eax
  800bb5:	2b 06                	sub    (%esi),%eax
  800bb7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bbd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bc4:	00 00 00 
	stat->st_dev = &devpipe;
  800bc7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bce:	30 80 00 
	return 0;
}
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bdd:	f3 0f 1e fb          	endbr32 
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800beb:	53                   	push   %ebx
  800bec:	6a 00                	push   $0x0
  800bee:	e8 37 f6 ff ff       	call   80022a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bf3:	89 1c 24             	mov    %ebx,(%esp)
  800bf6:	e8 56 f7 ff ff       	call   800351 <fd2data>
  800bfb:	83 c4 08             	add    $0x8,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 00                	push   $0x0
  800c01:	e8 24 f6 ff ff       	call   80022a <sys_page_unmap>
}
  800c06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    

00800c0b <_pipeisclosed>:
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 1c             	sub    $0x1c,%esp
  800c14:	89 c7                	mov    %eax,%edi
  800c16:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c18:	a1 04 40 80 00       	mov    0x804004,%eax
  800c1d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	57                   	push   %edi
  800c24:	e8 8d 0f 00 00       	call   801bb6 <pageref>
  800c29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c2c:	89 34 24             	mov    %esi,(%esp)
  800c2f:	e8 82 0f 00 00       	call   801bb6 <pageref>
		nn = thisenv->env_runs;
  800c34:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c3a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c3d:	83 c4 10             	add    $0x10,%esp
  800c40:	39 cb                	cmp    %ecx,%ebx
  800c42:	74 1b                	je     800c5f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c44:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c47:	75 cf                	jne    800c18 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c49:	8b 42 58             	mov    0x58(%edx),%eax
  800c4c:	6a 01                	push   $0x1
  800c4e:	50                   	push   %eax
  800c4f:	53                   	push   %ebx
  800c50:	68 5e 1f 80 00       	push   $0x801f5e
  800c55:	e8 13 05 00 00       	call   80116d <cprintf>
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	eb b9                	jmp    800c18 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c5f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c62:	0f 94 c0             	sete   %al
  800c65:	0f b6 c0             	movzbl %al,%eax
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <devpipe_write>:
{
  800c70:	f3 0f 1e fb          	endbr32 
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 28             	sub    $0x28,%esp
  800c7d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c80:	56                   	push   %esi
  800c81:	e8 cb f6 ff ff       	call   800351 <fd2data>
  800c86:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c88:	83 c4 10             	add    $0x10,%esp
  800c8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c90:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c93:	74 4f                	je     800ce4 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c95:	8b 43 04             	mov    0x4(%ebx),%eax
  800c98:	8b 0b                	mov    (%ebx),%ecx
  800c9a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c9d:	39 d0                	cmp    %edx,%eax
  800c9f:	72 14                	jb     800cb5 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800ca1:	89 da                	mov    %ebx,%edx
  800ca3:	89 f0                	mov    %esi,%eax
  800ca5:	e8 61 ff ff ff       	call   800c0b <_pipeisclosed>
  800caa:	85 c0                	test   %eax,%eax
  800cac:	75 3b                	jne    800ce9 <devpipe_write+0x79>
			sys_yield();
  800cae:	e8 fa f4 ff ff       	call   8001ad <sys_yield>
  800cb3:	eb e0                	jmp    800c95 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cbc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cbf:	89 c2                	mov    %eax,%edx
  800cc1:	c1 fa 1f             	sar    $0x1f,%edx
  800cc4:	89 d1                	mov    %edx,%ecx
  800cc6:	c1 e9 1b             	shr    $0x1b,%ecx
  800cc9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ccc:	83 e2 1f             	and    $0x1f,%edx
  800ccf:	29 ca                	sub    %ecx,%edx
  800cd1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cd5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cd9:	83 c0 01             	add    $0x1,%eax
  800cdc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cdf:	83 c7 01             	add    $0x1,%edi
  800ce2:	eb ac                	jmp    800c90 <devpipe_write+0x20>
	return i;
  800ce4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce7:	eb 05                	jmp    800cee <devpipe_write+0x7e>
				return 0;
  800ce9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <devpipe_read>:
{
  800cf6:	f3 0f 1e fb          	endbr32 
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 18             	sub    $0x18,%esp
  800d03:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d06:	57                   	push   %edi
  800d07:	e8 45 f6 ff ff       	call   800351 <fd2data>
  800d0c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	be 00 00 00 00       	mov    $0x0,%esi
  800d16:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d19:	75 14                	jne    800d2f <devpipe_read+0x39>
	return i;
  800d1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1e:	eb 02                	jmp    800d22 <devpipe_read+0x2c>
				return i;
  800d20:	89 f0                	mov    %esi,%eax
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    
			sys_yield();
  800d2a:	e8 7e f4 ff ff       	call   8001ad <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d2f:	8b 03                	mov    (%ebx),%eax
  800d31:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d34:	75 18                	jne    800d4e <devpipe_read+0x58>
			if (i > 0)
  800d36:	85 f6                	test   %esi,%esi
  800d38:	75 e6                	jne    800d20 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d3a:	89 da                	mov    %ebx,%edx
  800d3c:	89 f8                	mov    %edi,%eax
  800d3e:	e8 c8 fe ff ff       	call   800c0b <_pipeisclosed>
  800d43:	85 c0                	test   %eax,%eax
  800d45:	74 e3                	je     800d2a <devpipe_read+0x34>
				return 0;
  800d47:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4c:	eb d4                	jmp    800d22 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d4e:	99                   	cltd   
  800d4f:	c1 ea 1b             	shr    $0x1b,%edx
  800d52:	01 d0                	add    %edx,%eax
  800d54:	83 e0 1f             	and    $0x1f,%eax
  800d57:	29 d0                	sub    %edx,%eax
  800d59:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d64:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d67:	83 c6 01             	add    $0x1,%esi
  800d6a:	eb aa                	jmp    800d16 <devpipe_read+0x20>

00800d6c <pipe>:
{
  800d6c:	f3 0f 1e fb          	endbr32 
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d7b:	50                   	push   %eax
  800d7c:	e8 ef f5 ff ff       	call   800370 <fd_alloc>
  800d81:	89 c3                	mov    %eax,%ebx
  800d83:	83 c4 10             	add    $0x10,%esp
  800d86:	85 c0                	test   %eax,%eax
  800d88:	0f 88 23 01 00 00    	js     800eb1 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8e:	83 ec 04             	sub    $0x4,%esp
  800d91:	68 07 04 00 00       	push   $0x407
  800d96:	ff 75 f4             	pushl  -0xc(%ebp)
  800d99:	6a 00                	push   $0x0
  800d9b:	e8 38 f4 ff ff       	call   8001d8 <sys_page_alloc>
  800da0:	89 c3                	mov    %eax,%ebx
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	0f 88 04 01 00 00    	js     800eb1 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db3:	50                   	push   %eax
  800db4:	e8 b7 f5 ff ff       	call   800370 <fd_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 db 00 00 00    	js     800ea1 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc6:	83 ec 04             	sub    $0x4,%esp
  800dc9:	68 07 04 00 00       	push   $0x407
  800dce:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd1:	6a 00                	push   $0x0
  800dd3:	e8 00 f4 ff ff       	call   8001d8 <sys_page_alloc>
  800dd8:	89 c3                	mov    %eax,%ebx
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	0f 88 bc 00 00 00    	js     800ea1 <pipe+0x135>
	va = fd2data(fd0);
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	ff 75 f4             	pushl  -0xc(%ebp)
  800deb:	e8 61 f5 ff ff       	call   800351 <fd2data>
  800df0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 c4 0c             	add    $0xc,%esp
  800df5:	68 07 04 00 00       	push   $0x407
  800dfa:	50                   	push   %eax
  800dfb:	6a 00                	push   $0x0
  800dfd:	e8 d6 f3 ff ff       	call   8001d8 <sys_page_alloc>
  800e02:	89 c3                	mov    %eax,%ebx
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	85 c0                	test   %eax,%eax
  800e09:	0f 88 82 00 00 00    	js     800e91 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	ff 75 f0             	pushl  -0x10(%ebp)
  800e15:	e8 37 f5 ff ff       	call   800351 <fd2data>
  800e1a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e21:	50                   	push   %eax
  800e22:	6a 00                	push   $0x0
  800e24:	56                   	push   %esi
  800e25:	6a 00                	push   $0x0
  800e27:	e8 d4 f3 ff ff       	call   800200 <sys_page_map>
  800e2c:	89 c3                	mov    %eax,%ebx
  800e2e:	83 c4 20             	add    $0x20,%esp
  800e31:	85 c0                	test   %eax,%eax
  800e33:	78 4e                	js     800e83 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e35:	a1 20 30 80 00       	mov    0x803020,%eax
  800e3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e3d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e42:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e49:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e4c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e51:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5e:	e8 da f4 ff ff       	call   80033d <fd2num>
  800e63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e66:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e68:	83 c4 04             	add    $0x4,%esp
  800e6b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6e:	e8 ca f4 ff ff       	call   80033d <fd2num>
  800e73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e76:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e81:	eb 2e                	jmp    800eb1 <pipe+0x145>
	sys_page_unmap(0, va);
  800e83:	83 ec 08             	sub    $0x8,%esp
  800e86:	56                   	push   %esi
  800e87:	6a 00                	push   $0x0
  800e89:	e8 9c f3 ff ff       	call   80022a <sys_page_unmap>
  800e8e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	ff 75 f0             	pushl  -0x10(%ebp)
  800e97:	6a 00                	push   $0x0
  800e99:	e8 8c f3 ff ff       	call   80022a <sys_page_unmap>
  800e9e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ea1:	83 ec 08             	sub    $0x8,%esp
  800ea4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea7:	6a 00                	push   $0x0
  800ea9:	e8 7c f3 ff ff       	call   80022a <sys_page_unmap>
  800eae:	83 c4 10             	add    $0x10,%esp
}
  800eb1:	89 d8                	mov    %ebx,%eax
  800eb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb6:	5b                   	pop    %ebx
  800eb7:	5e                   	pop    %esi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <pipeisclosed>:
{
  800eba:	f3 0f 1e fb          	endbr32 
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec7:	50                   	push   %eax
  800ec8:	ff 75 08             	pushl  0x8(%ebp)
  800ecb:	e8 f6 f4 ff ff       	call   8003c6 <fd_lookup>
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	78 18                	js     800eef <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ed7:	83 ec 0c             	sub    $0xc,%esp
  800eda:	ff 75 f4             	pushl  -0xc(%ebp)
  800edd:	e8 6f f4 ff ff       	call   800351 <fd2data>
  800ee2:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee7:	e8 1f fd ff ff       	call   800c0b <_pipeisclosed>
  800eec:	83 c4 10             	add    $0x10,%esp
}
  800eef:	c9                   	leave  
  800ef0:	c3                   	ret    

00800ef1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ef1:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  800efa:	c3                   	ret    

00800efb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800efb:	f3 0f 1e fb          	endbr32 
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f05:	68 76 1f 80 00       	push   $0x801f76
  800f0a:	ff 75 0c             	pushl  0xc(%ebp)
  800f0d:	e8 c5 07 00 00       	call   8016d7 <strcpy>
	return 0;
}
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    

00800f19 <devcons_write>:
{
  800f19:	f3 0f 1e fb          	endbr32 
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	57                   	push   %edi
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f29:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f2e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f34:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f37:	73 31                	jae    800f6a <devcons_write+0x51>
		m = n - tot;
  800f39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3c:	29 f3                	sub    %esi,%ebx
  800f3e:	83 fb 7f             	cmp    $0x7f,%ebx
  800f41:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f46:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f49:	83 ec 04             	sub    $0x4,%esp
  800f4c:	53                   	push   %ebx
  800f4d:	89 f0                	mov    %esi,%eax
  800f4f:	03 45 0c             	add    0xc(%ebp),%eax
  800f52:	50                   	push   %eax
  800f53:	57                   	push   %edi
  800f54:	e8 36 09 00 00       	call   80188f <memmove>
		sys_cputs(buf, m);
  800f59:	83 c4 08             	add    $0x8,%esp
  800f5c:	53                   	push   %ebx
  800f5d:	57                   	push   %edi
  800f5e:	e8 aa f1 ff ff       	call   80010d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f63:	01 de                	add    %ebx,%esi
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	eb ca                	jmp    800f34 <devcons_write+0x1b>
}
  800f6a:	89 f0                	mov    %esi,%eax
  800f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <devcons_read>:
{
  800f74:	f3 0f 1e fb          	endbr32 
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f87:	74 21                	je     800faa <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f89:	e8 a9 f1 ff ff       	call   800137 <sys_cgetc>
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	75 07                	jne    800f99 <devcons_read+0x25>
		sys_yield();
  800f92:	e8 16 f2 ff ff       	call   8001ad <sys_yield>
  800f97:	eb f0                	jmp    800f89 <devcons_read+0x15>
	if (c < 0)
  800f99:	78 0f                	js     800faa <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f9b:	83 f8 04             	cmp    $0x4,%eax
  800f9e:	74 0c                	je     800fac <devcons_read+0x38>
	*(char*)vbuf = c;
  800fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa3:	88 02                	mov    %al,(%edx)
	return 1;
  800fa5:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    
		return 0;
  800fac:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb1:	eb f7                	jmp    800faa <devcons_read+0x36>

00800fb3 <cputchar>:
{
  800fb3:	f3 0f 1e fb          	endbr32 
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc0:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fc3:	6a 01                	push   $0x1
  800fc5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	e8 3f f1 ff ff       	call   80010d <sys_cputs>
}
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <getchar>:
{
  800fd3:	f3 0f 1e fb          	endbr32 
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fdd:	6a 01                	push   $0x1
  800fdf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe2:	50                   	push   %eax
  800fe3:	6a 00                	push   $0x0
  800fe5:	e8 5f f6 ff ff       	call   800649 <read>
	if (r < 0)
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 06                	js     800ff7 <getchar+0x24>
	if (r < 1)
  800ff1:	74 06                	je     800ff9 <getchar+0x26>
	return c;
  800ff3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    
		return -E_EOF;
  800ff9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800ffe:	eb f7                	jmp    800ff7 <getchar+0x24>

00801000 <iscons>:
{
  801000:	f3 0f 1e fb          	endbr32 
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100d:	50                   	push   %eax
  80100e:	ff 75 08             	pushl  0x8(%ebp)
  801011:	e8 b0 f3 ff ff       	call   8003c6 <fd_lookup>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 11                	js     80102e <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801026:	39 10                	cmp    %edx,(%eax)
  801028:	0f 94 c0             	sete   %al
  80102b:	0f b6 c0             	movzbl %al,%eax
}
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <opencons>:
{
  801030:	f3 0f 1e fb          	endbr32 
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80103a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103d:	50                   	push   %eax
  80103e:	e8 2d f3 ff ff       	call   800370 <fd_alloc>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 3a                	js     801084 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	68 07 04 00 00       	push   $0x407
  801052:	ff 75 f4             	pushl  -0xc(%ebp)
  801055:	6a 00                	push   $0x0
  801057:	e8 7c f1 ff ff       	call   8001d8 <sys_page_alloc>
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 21                	js     801084 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801063:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801066:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80106c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80106e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801071:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	50                   	push   %eax
  80107c:	e8 bc f2 ff ff       	call   80033d <fd2num>
  801081:	83 c4 10             	add    $0x10,%esp
}
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801086:	f3 0f 1e fb          	endbr32 
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	56                   	push   %esi
  80108e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80108f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801092:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801098:	e8 e8 f0 ff ff       	call   800185 <sys_getenvid>
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	ff 75 0c             	pushl  0xc(%ebp)
  8010a3:	ff 75 08             	pushl  0x8(%ebp)
  8010a6:	56                   	push   %esi
  8010a7:	50                   	push   %eax
  8010a8:	68 84 1f 80 00       	push   $0x801f84
  8010ad:	e8 bb 00 00 00       	call   80116d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010b2:	83 c4 18             	add    $0x18,%esp
  8010b5:	53                   	push   %ebx
  8010b6:	ff 75 10             	pushl  0x10(%ebp)
  8010b9:	e8 5a 00 00 00       	call   801118 <vcprintf>
	cprintf("\n");
  8010be:	c7 04 24 6f 1f 80 00 	movl   $0x801f6f,(%esp)
  8010c5:	e8 a3 00 00 00       	call   80116d <cprintf>
  8010ca:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010cd:	cc                   	int3   
  8010ce:	eb fd                	jmp    8010cd <_panic+0x47>

008010d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010d0:	f3 0f 1e fb          	endbr32 
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	53                   	push   %ebx
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010de:	8b 13                	mov    (%ebx),%edx
  8010e0:	8d 42 01             	lea    0x1(%edx),%eax
  8010e3:	89 03                	mov    %eax,(%ebx)
  8010e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010f1:	74 09                	je     8010fc <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010f3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010fc:	83 ec 08             	sub    $0x8,%esp
  8010ff:	68 ff 00 00 00       	push   $0xff
  801104:	8d 43 08             	lea    0x8(%ebx),%eax
  801107:	50                   	push   %eax
  801108:	e8 00 f0 ff ff       	call   80010d <sys_cputs>
		b->idx = 0;
  80110d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	eb db                	jmp    8010f3 <putch+0x23>

00801118 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801118:	f3 0f 1e fb          	endbr32 
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801125:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80112c:	00 00 00 
	b.cnt = 0;
  80112f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801136:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801139:	ff 75 0c             	pushl  0xc(%ebp)
  80113c:	ff 75 08             	pushl  0x8(%ebp)
  80113f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801145:	50                   	push   %eax
  801146:	68 d0 10 80 00       	push   $0x8010d0
  80114b:	e8 80 01 00 00       	call   8012d0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801150:	83 c4 08             	add    $0x8,%esp
  801153:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801159:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	e8 a8 ef ff ff       	call   80010d <sys_cputs>

	return b.cnt;
}
  801165:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    

0080116d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80116d:	f3 0f 1e fb          	endbr32 
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801177:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80117a:	50                   	push   %eax
  80117b:	ff 75 08             	pushl  0x8(%ebp)
  80117e:	e8 95 ff ff ff       	call   801118 <vcprintf>
	va_end(ap);

	return cnt;
}
  801183:	c9                   	leave  
  801184:	c3                   	ret    

00801185 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	57                   	push   %edi
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	83 ec 1c             	sub    $0x1c,%esp
  80118e:	89 c7                	mov    %eax,%edi
  801190:	89 d6                	mov    %edx,%esi
  801192:	8b 45 08             	mov    0x8(%ebp),%eax
  801195:	8b 55 0c             	mov    0xc(%ebp),%edx
  801198:	89 d1                	mov    %edx,%ecx
  80119a:	89 c2                	mov    %eax,%edx
  80119c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80119f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011b2:	39 c2                	cmp    %eax,%edx
  8011b4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011b7:	72 3e                	jb     8011f7 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011b9:	83 ec 0c             	sub    $0xc,%esp
  8011bc:	ff 75 18             	pushl  0x18(%ebp)
  8011bf:	83 eb 01             	sub    $0x1,%ebx
  8011c2:	53                   	push   %ebx
  8011c3:	50                   	push   %eax
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8011cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d3:	e8 28 0a 00 00       	call   801c00 <__udivdi3>
  8011d8:	83 c4 18             	add    $0x18,%esp
  8011db:	52                   	push   %edx
  8011dc:	50                   	push   %eax
  8011dd:	89 f2                	mov    %esi,%edx
  8011df:	89 f8                	mov    %edi,%eax
  8011e1:	e8 9f ff ff ff       	call   801185 <printnum>
  8011e6:	83 c4 20             	add    $0x20,%esp
  8011e9:	eb 13                	jmp    8011fe <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011eb:	83 ec 08             	sub    $0x8,%esp
  8011ee:	56                   	push   %esi
  8011ef:	ff 75 18             	pushl  0x18(%ebp)
  8011f2:	ff d7                	call   *%edi
  8011f4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011f7:	83 eb 01             	sub    $0x1,%ebx
  8011fa:	85 db                	test   %ebx,%ebx
  8011fc:	7f ed                	jg     8011eb <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	56                   	push   %esi
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	ff 75 e4             	pushl  -0x1c(%ebp)
  801208:	ff 75 e0             	pushl  -0x20(%ebp)
  80120b:	ff 75 dc             	pushl  -0x24(%ebp)
  80120e:	ff 75 d8             	pushl  -0x28(%ebp)
  801211:	e8 fa 0a 00 00       	call   801d10 <__umoddi3>
  801216:	83 c4 14             	add    $0x14,%esp
  801219:	0f be 80 a7 1f 80 00 	movsbl 0x801fa7(%eax),%eax
  801220:	50                   	push   %eax
  801221:	ff d7                	call   *%edi
}
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801229:	5b                   	pop    %ebx
  80122a:	5e                   	pop    %esi
  80122b:	5f                   	pop    %edi
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80122e:	83 fa 01             	cmp    $0x1,%edx
  801231:	7f 13                	jg     801246 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801233:	85 d2                	test   %edx,%edx
  801235:	74 1c                	je     801253 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801237:	8b 10                	mov    (%eax),%edx
  801239:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123c:	89 08                	mov    %ecx,(%eax)
  80123e:	8b 02                	mov    (%edx),%eax
  801240:	ba 00 00 00 00       	mov    $0x0,%edx
  801245:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801246:	8b 10                	mov    (%eax),%edx
  801248:	8d 4a 08             	lea    0x8(%edx),%ecx
  80124b:	89 08                	mov    %ecx,(%eax)
  80124d:	8b 02                	mov    (%edx),%eax
  80124f:	8b 52 04             	mov    0x4(%edx),%edx
  801252:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801253:	8b 10                	mov    (%eax),%edx
  801255:	8d 4a 04             	lea    0x4(%edx),%ecx
  801258:	89 08                	mov    %ecx,(%eax)
  80125a:	8b 02                	mov    (%edx),%eax
  80125c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801261:	c3                   	ret    

00801262 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801262:	83 fa 01             	cmp    $0x1,%edx
  801265:	7f 0f                	jg     801276 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801267:	85 d2                	test   %edx,%edx
  801269:	74 18                	je     801283 <getint+0x21>
		return va_arg(*ap, long);
  80126b:	8b 10                	mov    (%eax),%edx
  80126d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801270:	89 08                	mov    %ecx,(%eax)
  801272:	8b 02                	mov    (%edx),%eax
  801274:	99                   	cltd   
  801275:	c3                   	ret    
		return va_arg(*ap, long long);
  801276:	8b 10                	mov    (%eax),%edx
  801278:	8d 4a 08             	lea    0x8(%edx),%ecx
  80127b:	89 08                	mov    %ecx,(%eax)
  80127d:	8b 02                	mov    (%edx),%eax
  80127f:	8b 52 04             	mov    0x4(%edx),%edx
  801282:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801283:	8b 10                	mov    (%eax),%edx
  801285:	8d 4a 04             	lea    0x4(%edx),%ecx
  801288:	89 08                	mov    %ecx,(%eax)
  80128a:	8b 02                	mov    (%edx),%eax
  80128c:	99                   	cltd   
}
  80128d:	c3                   	ret    

0080128e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80128e:	f3 0f 1e fb          	endbr32 
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801298:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80129c:	8b 10                	mov    (%eax),%edx
  80129e:	3b 50 04             	cmp    0x4(%eax),%edx
  8012a1:	73 0a                	jae    8012ad <sprintputch+0x1f>
		*b->buf++ = ch;
  8012a3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012a6:	89 08                	mov    %ecx,(%eax)
  8012a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ab:	88 02                	mov    %al,(%edx)
}
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <printfmt>:
{
  8012af:	f3 0f 1e fb          	endbr32 
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012b9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012bc:	50                   	push   %eax
  8012bd:	ff 75 10             	pushl  0x10(%ebp)
  8012c0:	ff 75 0c             	pushl  0xc(%ebp)
  8012c3:	ff 75 08             	pushl  0x8(%ebp)
  8012c6:	e8 05 00 00 00       	call   8012d0 <vprintfmt>
}
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	c9                   	leave  
  8012cf:	c3                   	ret    

008012d0 <vprintfmt>:
{
  8012d0:	f3 0f 1e fb          	endbr32 
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	57                   	push   %edi
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 2c             	sub    $0x2c,%esp
  8012dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012e6:	e9 86 02 00 00       	jmp    801571 <vprintfmt+0x2a1>
		padc = ' ';
  8012eb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012ef:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012f6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012fd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801304:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801309:	8d 47 01             	lea    0x1(%edi),%eax
  80130c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80130f:	0f b6 17             	movzbl (%edi),%edx
  801312:	8d 42 dd             	lea    -0x23(%edx),%eax
  801315:	3c 55                	cmp    $0x55,%al
  801317:	0f 87 df 02 00 00    	ja     8015fc <vprintfmt+0x32c>
  80131d:	0f b6 c0             	movzbl %al,%eax
  801320:	3e ff 24 85 e0 20 80 	notrack jmp *0x8020e0(,%eax,4)
  801327:	00 
  801328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80132b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80132f:	eb d8                	jmp    801309 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801334:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801338:	eb cf                	jmp    801309 <vprintfmt+0x39>
  80133a:	0f b6 d2             	movzbl %dl,%edx
  80133d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801340:	b8 00 00 00 00       	mov    $0x0,%eax
  801345:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801348:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80134b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80134f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801352:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801355:	83 f9 09             	cmp    $0x9,%ecx
  801358:	77 52                	ja     8013ac <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80135a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80135d:	eb e9                	jmp    801348 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80135f:	8b 45 14             	mov    0x14(%ebp),%eax
  801362:	8d 50 04             	lea    0x4(%eax),%edx
  801365:	89 55 14             	mov    %edx,0x14(%ebp)
  801368:	8b 00                	mov    (%eax),%eax
  80136a:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80136d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801370:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801374:	79 93                	jns    801309 <vprintfmt+0x39>
				width = precision, precision = -1;
  801376:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801379:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80137c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801383:	eb 84                	jmp    801309 <vprintfmt+0x39>
  801385:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801388:	85 c0                	test   %eax,%eax
  80138a:	ba 00 00 00 00       	mov    $0x0,%edx
  80138f:	0f 49 d0             	cmovns %eax,%edx
  801392:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801398:	e9 6c ff ff ff       	jmp    801309 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80139d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8013a0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8013a7:	e9 5d ff ff ff       	jmp    801309 <vprintfmt+0x39>
  8013ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013b2:	eb bc                	jmp    801370 <vprintfmt+0xa0>
			lflag++;
  8013b4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013ba:	e9 4a ff ff ff       	jmp    801309 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c2:	8d 50 04             	lea    0x4(%eax),%edx
  8013c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	56                   	push   %esi
  8013cc:	ff 30                	pushl  (%eax)
  8013ce:	ff d3                	call   *%ebx
			break;
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	e9 96 01 00 00       	jmp    80156e <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013db:	8d 50 04             	lea    0x4(%eax),%edx
  8013de:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e1:	8b 00                	mov    (%eax),%eax
  8013e3:	99                   	cltd   
  8013e4:	31 d0                	xor    %edx,%eax
  8013e6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013e8:	83 f8 0f             	cmp    $0xf,%eax
  8013eb:	7f 20                	jg     80140d <vprintfmt+0x13d>
  8013ed:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8013f4:	85 d2                	test   %edx,%edx
  8013f6:	74 15                	je     80140d <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013f8:	52                   	push   %edx
  8013f9:	68 3d 1f 80 00       	push   $0x801f3d
  8013fe:	56                   	push   %esi
  8013ff:	53                   	push   %ebx
  801400:	e8 aa fe ff ff       	call   8012af <printfmt>
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	e9 61 01 00 00       	jmp    80156e <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80140d:	50                   	push   %eax
  80140e:	68 bf 1f 80 00       	push   $0x801fbf
  801413:	56                   	push   %esi
  801414:	53                   	push   %ebx
  801415:	e8 95 fe ff ff       	call   8012af <printfmt>
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	e9 4c 01 00 00       	jmp    80156e <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801422:	8b 45 14             	mov    0x14(%ebp),%eax
  801425:	8d 50 04             	lea    0x4(%eax),%edx
  801428:	89 55 14             	mov    %edx,0x14(%ebp)
  80142b:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80142d:	85 c9                	test   %ecx,%ecx
  80142f:	b8 b8 1f 80 00       	mov    $0x801fb8,%eax
  801434:	0f 45 c1             	cmovne %ecx,%eax
  801437:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80143a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80143e:	7e 06                	jle    801446 <vprintfmt+0x176>
  801440:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801444:	75 0d                	jne    801453 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801446:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801449:	89 c7                	mov    %eax,%edi
  80144b:	03 45 e0             	add    -0x20(%ebp),%eax
  80144e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801451:	eb 57                	jmp    8014aa <vprintfmt+0x1da>
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	ff 75 d8             	pushl  -0x28(%ebp)
  801459:	ff 75 cc             	pushl  -0x34(%ebp)
  80145c:	e8 4f 02 00 00       	call   8016b0 <strnlen>
  801461:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801464:	29 c2                	sub    %eax,%edx
  801466:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801469:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80146c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801470:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801473:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801475:	85 db                	test   %ebx,%ebx
  801477:	7e 10                	jle    801489 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	56                   	push   %esi
  80147d:	57                   	push   %edi
  80147e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801481:	83 eb 01             	sub    $0x1,%ebx
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	eb ec                	jmp    801475 <vprintfmt+0x1a5>
  801489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80148c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80148f:	85 d2                	test   %edx,%edx
  801491:	b8 00 00 00 00       	mov    $0x0,%eax
  801496:	0f 49 c2             	cmovns %edx,%eax
  801499:	29 c2                	sub    %eax,%edx
  80149b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80149e:	eb a6                	jmp    801446 <vprintfmt+0x176>
					putch(ch, putdat);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	56                   	push   %esi
  8014a4:	52                   	push   %edx
  8014a5:	ff d3                	call   *%ebx
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014ad:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014af:	83 c7 01             	add    $0x1,%edi
  8014b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b6:	0f be d0             	movsbl %al,%edx
  8014b9:	85 d2                	test   %edx,%edx
  8014bb:	74 42                	je     8014ff <vprintfmt+0x22f>
  8014bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014c1:	78 06                	js     8014c9 <vprintfmt+0x1f9>
  8014c3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014c7:	78 1e                	js     8014e7 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014c9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014cd:	74 d1                	je     8014a0 <vprintfmt+0x1d0>
  8014cf:	0f be c0             	movsbl %al,%eax
  8014d2:	83 e8 20             	sub    $0x20,%eax
  8014d5:	83 f8 5e             	cmp    $0x5e,%eax
  8014d8:	76 c6                	jbe    8014a0 <vprintfmt+0x1d0>
					putch('?', putdat);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	56                   	push   %esi
  8014de:	6a 3f                	push   $0x3f
  8014e0:	ff d3                	call   *%ebx
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	eb c3                	jmp    8014aa <vprintfmt+0x1da>
  8014e7:	89 cf                	mov    %ecx,%edi
  8014e9:	eb 0e                	jmp    8014f9 <vprintfmt+0x229>
				putch(' ', putdat);
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	56                   	push   %esi
  8014ef:	6a 20                	push   $0x20
  8014f1:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014f3:	83 ef 01             	sub    $0x1,%edi
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 ff                	test   %edi,%edi
  8014fb:	7f ee                	jg     8014eb <vprintfmt+0x21b>
  8014fd:	eb 6f                	jmp    80156e <vprintfmt+0x29e>
  8014ff:	89 cf                	mov    %ecx,%edi
  801501:	eb f6                	jmp    8014f9 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  801503:	89 ca                	mov    %ecx,%edx
  801505:	8d 45 14             	lea    0x14(%ebp),%eax
  801508:	e8 55 fd ff ff       	call   801262 <getint>
  80150d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801510:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  801513:	85 d2                	test   %edx,%edx
  801515:	78 0b                	js     801522 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  801517:	89 d1                	mov    %edx,%ecx
  801519:	89 c2                	mov    %eax,%edx
			base = 10;
  80151b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801520:	eb 32                	jmp    801554 <vprintfmt+0x284>
				putch('-', putdat);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	56                   	push   %esi
  801526:	6a 2d                	push   $0x2d
  801528:	ff d3                	call   *%ebx
				num = -(long long) num;
  80152a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80152d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801530:	f7 da                	neg    %edx
  801532:	83 d1 00             	adc    $0x0,%ecx
  801535:	f7 d9                	neg    %ecx
  801537:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80153a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80153f:	eb 13                	jmp    801554 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801541:	89 ca                	mov    %ecx,%edx
  801543:	8d 45 14             	lea    0x14(%ebp),%eax
  801546:	e8 e3 fc ff ff       	call   80122e <getuint>
  80154b:	89 d1                	mov    %edx,%ecx
  80154d:	89 c2                	mov    %eax,%edx
			base = 10;
  80154f:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80155b:	57                   	push   %edi
  80155c:	ff 75 e0             	pushl  -0x20(%ebp)
  80155f:	50                   	push   %eax
  801560:	51                   	push   %ecx
  801561:	52                   	push   %edx
  801562:	89 f2                	mov    %esi,%edx
  801564:	89 d8                	mov    %ebx,%eax
  801566:	e8 1a fc ff ff       	call   801185 <printnum>
			break;
  80156b:	83 c4 20             	add    $0x20,%esp
{
  80156e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801571:	83 c7 01             	add    $0x1,%edi
  801574:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801578:	83 f8 25             	cmp    $0x25,%eax
  80157b:	0f 84 6a fd ff ff    	je     8012eb <vprintfmt+0x1b>
			if (ch == '\0')
  801581:	85 c0                	test   %eax,%eax
  801583:	0f 84 93 00 00 00    	je     80161c <vprintfmt+0x34c>
			putch(ch, putdat);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	56                   	push   %esi
  80158d:	50                   	push   %eax
  80158e:	ff d3                	call   *%ebx
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	eb dc                	jmp    801571 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801595:	89 ca                	mov    %ecx,%edx
  801597:	8d 45 14             	lea    0x14(%ebp),%eax
  80159a:	e8 8f fc ff ff       	call   80122e <getuint>
  80159f:	89 d1                	mov    %edx,%ecx
  8015a1:	89 c2                	mov    %eax,%edx
			base = 8;
  8015a3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8015a8:	eb aa                	jmp    801554 <vprintfmt+0x284>
			putch('0', putdat);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	56                   	push   %esi
  8015ae:	6a 30                	push   $0x30
  8015b0:	ff d3                	call   *%ebx
			putch('x', putdat);
  8015b2:	83 c4 08             	add    $0x8,%esp
  8015b5:	56                   	push   %esi
  8015b6:	6a 78                	push   $0x78
  8015b8:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8015ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bd:	8d 50 04             	lea    0x4(%eax),%edx
  8015c0:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015c3:	8b 10                	mov    (%eax),%edx
  8015c5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015ca:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015cd:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015d2:	eb 80                	jmp    801554 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015d4:	89 ca                	mov    %ecx,%edx
  8015d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d9:	e8 50 fc ff ff       	call   80122e <getuint>
  8015de:	89 d1                	mov    %edx,%ecx
  8015e0:	89 c2                	mov    %eax,%edx
			base = 16;
  8015e2:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e7:	e9 68 ff ff ff       	jmp    801554 <vprintfmt+0x284>
			putch(ch, putdat);
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	56                   	push   %esi
  8015f0:	6a 25                	push   $0x25
  8015f2:	ff d3                	call   *%ebx
			break;
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	e9 72 ff ff ff       	jmp    80156e <vprintfmt+0x29e>
			putch('%', putdat);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	56                   	push   %esi
  801600:	6a 25                	push   $0x25
  801602:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	89 f8                	mov    %edi,%eax
  801609:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80160d:	74 05                	je     801614 <vprintfmt+0x344>
  80160f:	83 e8 01             	sub    $0x1,%eax
  801612:	eb f5                	jmp    801609 <vprintfmt+0x339>
  801614:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801617:	e9 52 ff ff ff       	jmp    80156e <vprintfmt+0x29e>
}
  80161c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5f                   	pop    %edi
  801622:	5d                   	pop    %ebp
  801623:	c3                   	ret    

00801624 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801624:	f3 0f 1e fb          	endbr32 
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	83 ec 18             	sub    $0x18,%esp
  80162e:	8b 45 08             	mov    0x8(%ebp),%eax
  801631:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801634:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801637:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80163b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80163e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801645:	85 c0                	test   %eax,%eax
  801647:	74 26                	je     80166f <vsnprintf+0x4b>
  801649:	85 d2                	test   %edx,%edx
  80164b:	7e 22                	jle    80166f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80164d:	ff 75 14             	pushl  0x14(%ebp)
  801650:	ff 75 10             	pushl  0x10(%ebp)
  801653:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	68 8e 12 80 00       	push   $0x80128e
  80165c:	e8 6f fc ff ff       	call   8012d0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801661:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801664:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801667:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166a:	83 c4 10             	add    $0x10,%esp
}
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    
		return -E_INVAL;
  80166f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801674:	eb f7                	jmp    80166d <vsnprintf+0x49>

00801676 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801676:	f3 0f 1e fb          	endbr32 
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801680:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801683:	50                   	push   %eax
  801684:	ff 75 10             	pushl  0x10(%ebp)
  801687:	ff 75 0c             	pushl  0xc(%ebp)
  80168a:	ff 75 08             	pushl  0x8(%ebp)
  80168d:	e8 92 ff ff ff       	call   801624 <vsnprintf>
	va_end(ap);

	return rc;
}
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801694:	f3 0f 1e fb          	endbr32 
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80169e:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016a7:	74 05                	je     8016ae <strlen+0x1a>
		n++;
  8016a9:	83 c0 01             	add    $0x1,%eax
  8016ac:	eb f5                	jmp    8016a3 <strlen+0xf>
	return n;
}
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016b0:	f3 0f 1e fb          	endbr32 
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c2:	39 d0                	cmp    %edx,%eax
  8016c4:	74 0d                	je     8016d3 <strnlen+0x23>
  8016c6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016ca:	74 05                	je     8016d1 <strnlen+0x21>
		n++;
  8016cc:	83 c0 01             	add    $0x1,%eax
  8016cf:	eb f1                	jmp    8016c2 <strnlen+0x12>
  8016d1:	89 c2                	mov    %eax,%edx
	return n;
}
  8016d3:	89 d0                	mov    %edx,%eax
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016d7:	f3 0f 1e fb          	endbr32 
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	53                   	push   %ebx
  8016df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ea:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016ee:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016f1:	83 c0 01             	add    $0x1,%eax
  8016f4:	84 d2                	test   %dl,%dl
  8016f6:	75 f2                	jne    8016ea <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016f8:	89 c8                	mov    %ecx,%eax
  8016fa:	5b                   	pop    %ebx
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016fd:	f3 0f 1e fb          	endbr32 
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	53                   	push   %ebx
  801705:	83 ec 10             	sub    $0x10,%esp
  801708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80170b:	53                   	push   %ebx
  80170c:	e8 83 ff ff ff       	call   801694 <strlen>
  801711:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801714:	ff 75 0c             	pushl  0xc(%ebp)
  801717:	01 d8                	add    %ebx,%eax
  801719:	50                   	push   %eax
  80171a:	e8 b8 ff ff ff       	call   8016d7 <strcpy>
	return dst;
}
  80171f:	89 d8                	mov    %ebx,%eax
  801721:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801726:	f3 0f 1e fb          	endbr32 
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
  80172f:	8b 75 08             	mov    0x8(%ebp),%esi
  801732:	8b 55 0c             	mov    0xc(%ebp),%edx
  801735:	89 f3                	mov    %esi,%ebx
  801737:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173a:	89 f0                	mov    %esi,%eax
  80173c:	39 d8                	cmp    %ebx,%eax
  80173e:	74 11                	je     801751 <strncpy+0x2b>
		*dst++ = *src;
  801740:	83 c0 01             	add    $0x1,%eax
  801743:	0f b6 0a             	movzbl (%edx),%ecx
  801746:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801749:	80 f9 01             	cmp    $0x1,%cl
  80174c:	83 da ff             	sbb    $0xffffffff,%edx
  80174f:	eb eb                	jmp    80173c <strncpy+0x16>
	}
	return ret;
}
  801751:	89 f0                	mov    %esi,%eax
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801757:	f3 0f 1e fb          	endbr32 
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
  801760:	8b 75 08             	mov    0x8(%ebp),%esi
  801763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801766:	8b 55 10             	mov    0x10(%ebp),%edx
  801769:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80176b:	85 d2                	test   %edx,%edx
  80176d:	74 21                	je     801790 <strlcpy+0x39>
  80176f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801773:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801775:	39 c2                	cmp    %eax,%edx
  801777:	74 14                	je     80178d <strlcpy+0x36>
  801779:	0f b6 19             	movzbl (%ecx),%ebx
  80177c:	84 db                	test   %bl,%bl
  80177e:	74 0b                	je     80178b <strlcpy+0x34>
			*dst++ = *src++;
  801780:	83 c1 01             	add    $0x1,%ecx
  801783:	83 c2 01             	add    $0x1,%edx
  801786:	88 5a ff             	mov    %bl,-0x1(%edx)
  801789:	eb ea                	jmp    801775 <strlcpy+0x1e>
  80178b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80178d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801790:	29 f0                	sub    %esi,%eax
}
  801792:	5b                   	pop    %ebx
  801793:	5e                   	pop    %esi
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801796:	f3 0f 1e fb          	endbr32 
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017a3:	0f b6 01             	movzbl (%ecx),%eax
  8017a6:	84 c0                	test   %al,%al
  8017a8:	74 0c                	je     8017b6 <strcmp+0x20>
  8017aa:	3a 02                	cmp    (%edx),%al
  8017ac:	75 08                	jne    8017b6 <strcmp+0x20>
		p++, q++;
  8017ae:	83 c1 01             	add    $0x1,%ecx
  8017b1:	83 c2 01             	add    $0x1,%edx
  8017b4:	eb ed                	jmp    8017a3 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b6:	0f b6 c0             	movzbl %al,%eax
  8017b9:	0f b6 12             	movzbl (%edx),%edx
  8017bc:	29 d0                	sub    %edx,%eax
}
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017c0:	f3 0f 1e fb          	endbr32 
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ce:	89 c3                	mov    %eax,%ebx
  8017d0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017d3:	eb 06                	jmp    8017db <strncmp+0x1b>
		n--, p++, q++;
  8017d5:	83 c0 01             	add    $0x1,%eax
  8017d8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017db:	39 d8                	cmp    %ebx,%eax
  8017dd:	74 16                	je     8017f5 <strncmp+0x35>
  8017df:	0f b6 08             	movzbl (%eax),%ecx
  8017e2:	84 c9                	test   %cl,%cl
  8017e4:	74 04                	je     8017ea <strncmp+0x2a>
  8017e6:	3a 0a                	cmp    (%edx),%cl
  8017e8:	74 eb                	je     8017d5 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ea:	0f b6 00             	movzbl (%eax),%eax
  8017ed:	0f b6 12             	movzbl (%edx),%edx
  8017f0:	29 d0                	sub    %edx,%eax
}
  8017f2:	5b                   	pop    %ebx
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    
		return 0;
  8017f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fa:	eb f6                	jmp    8017f2 <strncmp+0x32>

008017fc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017fc:	f3 0f 1e fb          	endbr32 
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180a:	0f b6 10             	movzbl (%eax),%edx
  80180d:	84 d2                	test   %dl,%dl
  80180f:	74 09                	je     80181a <strchr+0x1e>
		if (*s == c)
  801811:	38 ca                	cmp    %cl,%dl
  801813:	74 0a                	je     80181f <strchr+0x23>
	for (; *s; s++)
  801815:	83 c0 01             	add    $0x1,%eax
  801818:	eb f0                	jmp    80180a <strchr+0xe>
			return (char *) s;
	return 0;
  80181a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    

00801821 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801821:	f3 0f 1e fb          	endbr32 
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	8b 45 08             	mov    0x8(%ebp),%eax
  80182b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801832:	38 ca                	cmp    %cl,%dl
  801834:	74 09                	je     80183f <strfind+0x1e>
  801836:	84 d2                	test   %dl,%dl
  801838:	74 05                	je     80183f <strfind+0x1e>
	for (; *s; s++)
  80183a:	83 c0 01             	add    $0x1,%eax
  80183d:	eb f0                	jmp    80182f <strfind+0xe>
			break;
	return (char *) s;
}
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801841:	f3 0f 1e fb          	endbr32 
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	57                   	push   %edi
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	8b 55 08             	mov    0x8(%ebp),%edx
  80184e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801851:	85 c9                	test   %ecx,%ecx
  801853:	74 33                	je     801888 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801855:	89 d0                	mov    %edx,%eax
  801857:	09 c8                	or     %ecx,%eax
  801859:	a8 03                	test   $0x3,%al
  80185b:	75 23                	jne    801880 <memset+0x3f>
		c &= 0xFF;
  80185d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801861:	89 d8                	mov    %ebx,%eax
  801863:	c1 e0 08             	shl    $0x8,%eax
  801866:	89 df                	mov    %ebx,%edi
  801868:	c1 e7 18             	shl    $0x18,%edi
  80186b:	89 de                	mov    %ebx,%esi
  80186d:	c1 e6 10             	shl    $0x10,%esi
  801870:	09 f7                	or     %esi,%edi
  801872:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801874:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801877:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801879:	89 d7                	mov    %edx,%edi
  80187b:	fc                   	cld    
  80187c:	f3 ab                	rep stos %eax,%es:(%edi)
  80187e:	eb 08                	jmp    801888 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801880:	89 d7                	mov    %edx,%edi
  801882:	8b 45 0c             	mov    0xc(%ebp),%eax
  801885:	fc                   	cld    
  801886:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801888:	89 d0                	mov    %edx,%eax
  80188a:	5b                   	pop    %ebx
  80188b:	5e                   	pop    %esi
  80188c:	5f                   	pop    %edi
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80188f:	f3 0f 1e fb          	endbr32 
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	57                   	push   %edi
  801897:	56                   	push   %esi
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80189e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018a1:	39 c6                	cmp    %eax,%esi
  8018a3:	73 32                	jae    8018d7 <memmove+0x48>
  8018a5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018a8:	39 c2                	cmp    %eax,%edx
  8018aa:	76 2b                	jbe    8018d7 <memmove+0x48>
		s += n;
		d += n;
  8018ac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018af:	89 fe                	mov    %edi,%esi
  8018b1:	09 ce                	or     %ecx,%esi
  8018b3:	09 d6                	or     %edx,%esi
  8018b5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018bb:	75 0e                	jne    8018cb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018bd:	83 ef 04             	sub    $0x4,%edi
  8018c0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018c3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018c6:	fd                   	std    
  8018c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c9:	eb 09                	jmp    8018d4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018cb:	83 ef 01             	sub    $0x1,%edi
  8018ce:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018d1:	fd                   	std    
  8018d2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018d4:	fc                   	cld    
  8018d5:	eb 1a                	jmp    8018f1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d7:	89 c2                	mov    %eax,%edx
  8018d9:	09 ca                	or     %ecx,%edx
  8018db:	09 f2                	or     %esi,%edx
  8018dd:	f6 c2 03             	test   $0x3,%dl
  8018e0:	75 0a                	jne    8018ec <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018e2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018e5:	89 c7                	mov    %eax,%edi
  8018e7:	fc                   	cld    
  8018e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ea:	eb 05                	jmp    8018f1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018ec:	89 c7                	mov    %eax,%edi
  8018ee:	fc                   	cld    
  8018ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018f1:	5e                   	pop    %esi
  8018f2:	5f                   	pop    %edi
  8018f3:	5d                   	pop    %ebp
  8018f4:	c3                   	ret    

008018f5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018f5:	f3 0f 1e fb          	endbr32 
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018ff:	ff 75 10             	pushl  0x10(%ebp)
  801902:	ff 75 0c             	pushl  0xc(%ebp)
  801905:	ff 75 08             	pushl  0x8(%ebp)
  801908:	e8 82 ff ff ff       	call   80188f <memmove>
}
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80190f:	f3 0f 1e fb          	endbr32 
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	56                   	push   %esi
  801917:	53                   	push   %ebx
  801918:	8b 45 08             	mov    0x8(%ebp),%eax
  80191b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191e:	89 c6                	mov    %eax,%esi
  801920:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801923:	39 f0                	cmp    %esi,%eax
  801925:	74 1c                	je     801943 <memcmp+0x34>
		if (*s1 != *s2)
  801927:	0f b6 08             	movzbl (%eax),%ecx
  80192a:	0f b6 1a             	movzbl (%edx),%ebx
  80192d:	38 d9                	cmp    %bl,%cl
  80192f:	75 08                	jne    801939 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801931:	83 c0 01             	add    $0x1,%eax
  801934:	83 c2 01             	add    $0x1,%edx
  801937:	eb ea                	jmp    801923 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801939:	0f b6 c1             	movzbl %cl,%eax
  80193c:	0f b6 db             	movzbl %bl,%ebx
  80193f:	29 d8                	sub    %ebx,%eax
  801941:	eb 05                	jmp    801948 <memcmp+0x39>
	}

	return 0;
  801943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801948:	5b                   	pop    %ebx
  801949:	5e                   	pop    %esi
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80194c:	f3 0f 1e fb          	endbr32 
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	8b 45 08             	mov    0x8(%ebp),%eax
  801956:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801959:	89 c2                	mov    %eax,%edx
  80195b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80195e:	39 d0                	cmp    %edx,%eax
  801960:	73 09                	jae    80196b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801962:	38 08                	cmp    %cl,(%eax)
  801964:	74 05                	je     80196b <memfind+0x1f>
	for (; s < ends; s++)
  801966:	83 c0 01             	add    $0x1,%eax
  801969:	eb f3                	jmp    80195e <memfind+0x12>
			break;
	return (void *) s;
}
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80196d:	f3 0f 1e fb          	endbr32 
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	57                   	push   %edi
  801975:	56                   	push   %esi
  801976:	53                   	push   %ebx
  801977:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80197a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197d:	eb 03                	jmp    801982 <strtol+0x15>
		s++;
  80197f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801982:	0f b6 01             	movzbl (%ecx),%eax
  801985:	3c 20                	cmp    $0x20,%al
  801987:	74 f6                	je     80197f <strtol+0x12>
  801989:	3c 09                	cmp    $0x9,%al
  80198b:	74 f2                	je     80197f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80198d:	3c 2b                	cmp    $0x2b,%al
  80198f:	74 2a                	je     8019bb <strtol+0x4e>
	int neg = 0;
  801991:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801996:	3c 2d                	cmp    $0x2d,%al
  801998:	74 2b                	je     8019c5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80199a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019a0:	75 0f                	jne    8019b1 <strtol+0x44>
  8019a2:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a5:	74 28                	je     8019cf <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a7:	85 db                	test   %ebx,%ebx
  8019a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019ae:	0f 44 d8             	cmove  %eax,%ebx
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019b9:	eb 46                	jmp    801a01 <strtol+0x94>
		s++;
  8019bb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019be:	bf 00 00 00 00       	mov    $0x0,%edi
  8019c3:	eb d5                	jmp    80199a <strtol+0x2d>
		s++, neg = 1;
  8019c5:	83 c1 01             	add    $0x1,%ecx
  8019c8:	bf 01 00 00 00       	mov    $0x1,%edi
  8019cd:	eb cb                	jmp    80199a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019cf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019d3:	74 0e                	je     8019e3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019d5:	85 db                	test   %ebx,%ebx
  8019d7:	75 d8                	jne    8019b1 <strtol+0x44>
		s++, base = 8;
  8019d9:	83 c1 01             	add    $0x1,%ecx
  8019dc:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019e1:	eb ce                	jmp    8019b1 <strtol+0x44>
		s += 2, base = 16;
  8019e3:	83 c1 02             	add    $0x2,%ecx
  8019e6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019eb:	eb c4                	jmp    8019b1 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019ed:	0f be d2             	movsbl %dl,%edx
  8019f0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019f3:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f6:	7d 3a                	jge    801a32 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019f8:	83 c1 01             	add    $0x1,%ecx
  8019fb:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019ff:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a01:	0f b6 11             	movzbl (%ecx),%edx
  801a04:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a07:	89 f3                	mov    %esi,%ebx
  801a09:	80 fb 09             	cmp    $0x9,%bl
  801a0c:	76 df                	jbe    8019ed <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801a0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a11:	89 f3                	mov    %esi,%ebx
  801a13:	80 fb 19             	cmp    $0x19,%bl
  801a16:	77 08                	ja     801a20 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a18:	0f be d2             	movsbl %dl,%edx
  801a1b:	83 ea 57             	sub    $0x57,%edx
  801a1e:	eb d3                	jmp    8019f3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801a20:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a23:	89 f3                	mov    %esi,%ebx
  801a25:	80 fb 19             	cmp    $0x19,%bl
  801a28:	77 08                	ja     801a32 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a2a:	0f be d2             	movsbl %dl,%edx
  801a2d:	83 ea 37             	sub    $0x37,%edx
  801a30:	eb c1                	jmp    8019f3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a36:	74 05                	je     801a3d <strtol+0xd0>
		*endptr = (char *) s;
  801a38:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a3d:	89 c2                	mov    %eax,%edx
  801a3f:	f7 da                	neg    %edx
  801a41:	85 ff                	test   %edi,%edi
  801a43:	0f 45 c2             	cmovne %edx,%eax
}
  801a46:	5b                   	pop    %ebx
  801a47:	5e                   	pop    %esi
  801a48:	5f                   	pop    %edi
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    

00801a4b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a4b:	f3 0f 1e fb          	endbr32 
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a55:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a5c:	74 1c                	je     801a7a <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a61:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  801a66:	83 ec 08             	sub    $0x8,%esp
  801a69:	68 15 03 80 00       	push   $0x800315
  801a6e:	6a 00                	push   $0x0
  801a70:	e8 2a e8 ff ff       	call   80029f <sys_env_set_pgfault_upcall>
}
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  801a7a:	83 ec 04             	sub    $0x4,%esp
  801a7d:	6a 02                	push   $0x2
  801a7f:	68 00 f0 bf ee       	push   $0xeebff000
  801a84:	6a 00                	push   $0x0
  801a86:	e8 4d e7 ff ff       	call   8001d8 <sys_page_alloc>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	79 cc                	jns    801a5e <set_pgfault_handler+0x13>
  801a92:	83 ec 04             	sub    $0x4,%esp
  801a95:	68 9f 22 80 00       	push   $0x80229f
  801a9a:	6a 20                	push   $0x20
  801a9c:	68 ba 22 80 00       	push   $0x8022ba
  801aa1:	e8 e0 f5 ff ff       	call   801086 <_panic>

00801aa6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aa6:	f3 0f 1e fb          	endbr32 
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801abf:	0f 44 c2             	cmove  %edx,%eax
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	50                   	push   %eax
  801ac6:	e8 24 e8 ff ff       	call   8002ef <sys_ipc_recv>

	if (from_env_store != NULL)
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	85 f6                	test   %esi,%esi
  801ad0:	74 15                	je     801ae7 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad7:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801ada:	74 09                	je     801ae5 <ipc_recv+0x3f>
  801adc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ae2:	8b 52 74             	mov    0x74(%edx),%edx
  801ae5:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801ae7:	85 db                	test   %ebx,%ebx
  801ae9:	74 15                	je     801b00 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  801af0:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801af3:	74 09                	je     801afe <ipc_recv+0x58>
  801af5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801afb:	8b 52 78             	mov    0x78(%edx),%edx
  801afe:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801b00:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801b03:	74 08                	je     801b0d <ipc_recv+0x67>
  801b05:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b10:	5b                   	pop    %ebx
  801b11:	5e                   	pop    %esi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b14:	f3 0f 1e fb          	endbr32 
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	57                   	push   %edi
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b24:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b2a:	eb 1f                	jmp    801b4b <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801b2c:	6a 00                	push   $0x0
  801b2e:	68 00 00 c0 ee       	push   $0xeec00000
  801b33:	56                   	push   %esi
  801b34:	57                   	push   %edi
  801b35:	e8 8c e7 ff ff       	call   8002c6 <sys_ipc_try_send>
  801b3a:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	74 30                	je     801b71 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801b41:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b44:	75 19                	jne    801b5f <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801b46:	e8 62 e6 ff ff       	call   8001ad <sys_yield>
		if (pg != NULL) {
  801b4b:	85 db                	test   %ebx,%ebx
  801b4d:	74 dd                	je     801b2c <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801b4f:	ff 75 14             	pushl  0x14(%ebp)
  801b52:	53                   	push   %ebx
  801b53:	56                   	push   %esi
  801b54:	57                   	push   %edi
  801b55:	e8 6c e7 ff ff       	call   8002c6 <sys_ipc_try_send>
  801b5a:	83 c4 10             	add    $0x10,%esp
  801b5d:	eb de                	jmp    801b3d <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801b5f:	50                   	push   %eax
  801b60:	68 c8 22 80 00       	push   $0x8022c8
  801b65:	6a 3e                	push   $0x3e
  801b67:	68 d5 22 80 00       	push   $0x8022d5
  801b6c:	e8 15 f5 ff ff       	call   801086 <_panic>
	}
}
  801b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5e                   	pop    %esi
  801b76:	5f                   	pop    %edi
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b79:	f3 0f 1e fb          	endbr32 
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b83:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b88:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b8b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b91:	8b 52 50             	mov    0x50(%edx),%edx
  801b94:	39 ca                	cmp    %ecx,%edx
  801b96:	74 11                	je     801ba9 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b98:	83 c0 01             	add    $0x1,%eax
  801b9b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ba0:	75 e6                	jne    801b88 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba7:	eb 0b                	jmp    801bb4 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801ba9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bb1:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bb4:	5d                   	pop    %ebp
  801bb5:	c3                   	ret    

00801bb6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bb6:	f3 0f 1e fb          	endbr32 
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bc0:	89 c2                	mov    %eax,%edx
  801bc2:	c1 ea 16             	shr    $0x16,%edx
  801bc5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801bcc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801bd1:	f6 c1 01             	test   $0x1,%cl
  801bd4:	74 1c                	je     801bf2 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801bd6:	c1 e8 0c             	shr    $0xc,%eax
  801bd9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801be0:	a8 01                	test   $0x1,%al
  801be2:	74 0e                	je     801bf2 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801be4:	c1 e8 0c             	shr    $0xc,%eax
  801be7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801bee:	ef 
  801bef:	0f b7 d2             	movzwl %dx,%edx
}
  801bf2:	89 d0                	mov    %edx,%eax
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    
  801bf6:	66 90                	xchg   %ax,%ax
  801bf8:	66 90                	xchg   %ax,%ax
  801bfa:	66 90                	xchg   %ax,%ax
  801bfc:	66 90                	xchg   %ax,%ax
  801bfe:	66 90                	xchg   %ax,%ax

00801c00 <__udivdi3>:
  801c00:	f3 0f 1e fb          	endbr32 
  801c04:	55                   	push   %ebp
  801c05:	57                   	push   %edi
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	83 ec 1c             	sub    $0x1c,%esp
  801c0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c13:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c1b:	85 d2                	test   %edx,%edx
  801c1d:	75 19                	jne    801c38 <__udivdi3+0x38>
  801c1f:	39 f3                	cmp    %esi,%ebx
  801c21:	76 4d                	jbe    801c70 <__udivdi3+0x70>
  801c23:	31 ff                	xor    %edi,%edi
  801c25:	89 e8                	mov    %ebp,%eax
  801c27:	89 f2                	mov    %esi,%edx
  801c29:	f7 f3                	div    %ebx
  801c2b:	89 fa                	mov    %edi,%edx
  801c2d:	83 c4 1c             	add    $0x1c,%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
  801c35:	8d 76 00             	lea    0x0(%esi),%esi
  801c38:	39 f2                	cmp    %esi,%edx
  801c3a:	76 14                	jbe    801c50 <__udivdi3+0x50>
  801c3c:	31 ff                	xor    %edi,%edi
  801c3e:	31 c0                	xor    %eax,%eax
  801c40:	89 fa                	mov    %edi,%edx
  801c42:	83 c4 1c             	add    $0x1c,%esp
  801c45:	5b                   	pop    %ebx
  801c46:	5e                   	pop    %esi
  801c47:	5f                   	pop    %edi
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    
  801c4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c50:	0f bd fa             	bsr    %edx,%edi
  801c53:	83 f7 1f             	xor    $0x1f,%edi
  801c56:	75 48                	jne    801ca0 <__udivdi3+0xa0>
  801c58:	39 f2                	cmp    %esi,%edx
  801c5a:	72 06                	jb     801c62 <__udivdi3+0x62>
  801c5c:	31 c0                	xor    %eax,%eax
  801c5e:	39 eb                	cmp    %ebp,%ebx
  801c60:	77 de                	ja     801c40 <__udivdi3+0x40>
  801c62:	b8 01 00 00 00       	mov    $0x1,%eax
  801c67:	eb d7                	jmp    801c40 <__udivdi3+0x40>
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 d9                	mov    %ebx,%ecx
  801c72:	85 db                	test   %ebx,%ebx
  801c74:	75 0b                	jne    801c81 <__udivdi3+0x81>
  801c76:	b8 01 00 00 00       	mov    $0x1,%eax
  801c7b:	31 d2                	xor    %edx,%edx
  801c7d:	f7 f3                	div    %ebx
  801c7f:	89 c1                	mov    %eax,%ecx
  801c81:	31 d2                	xor    %edx,%edx
  801c83:	89 f0                	mov    %esi,%eax
  801c85:	f7 f1                	div    %ecx
  801c87:	89 c6                	mov    %eax,%esi
  801c89:	89 e8                	mov    %ebp,%eax
  801c8b:	89 f7                	mov    %esi,%edi
  801c8d:	f7 f1                	div    %ecx
  801c8f:	89 fa                	mov    %edi,%edx
  801c91:	83 c4 1c             	add    $0x1c,%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5f                   	pop    %edi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 f9                	mov    %edi,%ecx
  801ca2:	b8 20 00 00 00       	mov    $0x20,%eax
  801ca7:	29 f8                	sub    %edi,%eax
  801ca9:	d3 e2                	shl    %cl,%edx
  801cab:	89 54 24 08          	mov    %edx,0x8(%esp)
  801caf:	89 c1                	mov    %eax,%ecx
  801cb1:	89 da                	mov    %ebx,%edx
  801cb3:	d3 ea                	shr    %cl,%edx
  801cb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801cb9:	09 d1                	or     %edx,%ecx
  801cbb:	89 f2                	mov    %esi,%edx
  801cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cc1:	89 f9                	mov    %edi,%ecx
  801cc3:	d3 e3                	shl    %cl,%ebx
  801cc5:	89 c1                	mov    %eax,%ecx
  801cc7:	d3 ea                	shr    %cl,%edx
  801cc9:	89 f9                	mov    %edi,%ecx
  801ccb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ccf:	89 eb                	mov    %ebp,%ebx
  801cd1:	d3 e6                	shl    %cl,%esi
  801cd3:	89 c1                	mov    %eax,%ecx
  801cd5:	d3 eb                	shr    %cl,%ebx
  801cd7:	09 de                	or     %ebx,%esi
  801cd9:	89 f0                	mov    %esi,%eax
  801cdb:	f7 74 24 08          	divl   0x8(%esp)
  801cdf:	89 d6                	mov    %edx,%esi
  801ce1:	89 c3                	mov    %eax,%ebx
  801ce3:	f7 64 24 0c          	mull   0xc(%esp)
  801ce7:	39 d6                	cmp    %edx,%esi
  801ce9:	72 15                	jb     801d00 <__udivdi3+0x100>
  801ceb:	89 f9                	mov    %edi,%ecx
  801ced:	d3 e5                	shl    %cl,%ebp
  801cef:	39 c5                	cmp    %eax,%ebp
  801cf1:	73 04                	jae    801cf7 <__udivdi3+0xf7>
  801cf3:	39 d6                	cmp    %edx,%esi
  801cf5:	74 09                	je     801d00 <__udivdi3+0x100>
  801cf7:	89 d8                	mov    %ebx,%eax
  801cf9:	31 ff                	xor    %edi,%edi
  801cfb:	e9 40 ff ff ff       	jmp    801c40 <__udivdi3+0x40>
  801d00:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d03:	31 ff                	xor    %edi,%edi
  801d05:	e9 36 ff ff ff       	jmp    801c40 <__udivdi3+0x40>
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__umoddi3>:
  801d10:	f3 0f 1e fb          	endbr32 
  801d14:	55                   	push   %ebp
  801d15:	57                   	push   %edi
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	83 ec 1c             	sub    $0x1c,%esp
  801d1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d1f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d23:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d27:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	75 19                	jne    801d48 <__umoddi3+0x38>
  801d2f:	39 df                	cmp    %ebx,%edi
  801d31:	76 5d                	jbe    801d90 <__umoddi3+0x80>
  801d33:	89 f0                	mov    %esi,%eax
  801d35:	89 da                	mov    %ebx,%edx
  801d37:	f7 f7                	div    %edi
  801d39:	89 d0                	mov    %edx,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	83 c4 1c             	add    $0x1c,%esp
  801d40:	5b                   	pop    %ebx
  801d41:	5e                   	pop    %esi
  801d42:	5f                   	pop    %edi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    
  801d45:	8d 76 00             	lea    0x0(%esi),%esi
  801d48:	89 f2                	mov    %esi,%edx
  801d4a:	39 d8                	cmp    %ebx,%eax
  801d4c:	76 12                	jbe    801d60 <__umoddi3+0x50>
  801d4e:	89 f0                	mov    %esi,%eax
  801d50:	89 da                	mov    %ebx,%edx
  801d52:	83 c4 1c             	add    $0x1c,%esp
  801d55:	5b                   	pop    %ebx
  801d56:	5e                   	pop    %esi
  801d57:	5f                   	pop    %edi
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    
  801d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d60:	0f bd e8             	bsr    %eax,%ebp
  801d63:	83 f5 1f             	xor    $0x1f,%ebp
  801d66:	75 50                	jne    801db8 <__umoddi3+0xa8>
  801d68:	39 d8                	cmp    %ebx,%eax
  801d6a:	0f 82 e0 00 00 00    	jb     801e50 <__umoddi3+0x140>
  801d70:	89 d9                	mov    %ebx,%ecx
  801d72:	39 f7                	cmp    %esi,%edi
  801d74:	0f 86 d6 00 00 00    	jbe    801e50 <__umoddi3+0x140>
  801d7a:	89 d0                	mov    %edx,%eax
  801d7c:	89 ca                	mov    %ecx,%edx
  801d7e:	83 c4 1c             	add    $0x1c,%esp
  801d81:	5b                   	pop    %ebx
  801d82:	5e                   	pop    %esi
  801d83:	5f                   	pop    %edi
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    
  801d86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d8d:	8d 76 00             	lea    0x0(%esi),%esi
  801d90:	89 fd                	mov    %edi,%ebp
  801d92:	85 ff                	test   %edi,%edi
  801d94:	75 0b                	jne    801da1 <__umoddi3+0x91>
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f7                	div    %edi
  801d9f:	89 c5                	mov    %eax,%ebp
  801da1:	89 d8                	mov    %ebx,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f5                	div    %ebp
  801da7:	89 f0                	mov    %esi,%eax
  801da9:	f7 f5                	div    %ebp
  801dab:	89 d0                	mov    %edx,%eax
  801dad:	31 d2                	xor    %edx,%edx
  801daf:	eb 8c                	jmp    801d3d <__umoddi3+0x2d>
  801db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	ba 20 00 00 00       	mov    $0x20,%edx
  801dbf:	29 ea                	sub    %ebp,%edx
  801dc1:	d3 e0                	shl    %cl,%eax
  801dc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dc7:	89 d1                	mov    %edx,%ecx
  801dc9:	89 f8                	mov    %edi,%eax
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801dd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd5:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dd9:	09 c1                	or     %eax,%ecx
  801ddb:	89 d8                	mov    %ebx,%eax
  801ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de1:	89 e9                	mov    %ebp,%ecx
  801de3:	d3 e7                	shl    %cl,%edi
  801de5:	89 d1                	mov    %edx,%ecx
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801def:	d3 e3                	shl    %cl,%ebx
  801df1:	89 c7                	mov    %eax,%edi
  801df3:	89 d1                	mov    %edx,%ecx
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	d3 e8                	shr    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	89 fa                	mov    %edi,%edx
  801dfd:	d3 e6                	shl    %cl,%esi
  801dff:	09 d8                	or     %ebx,%eax
  801e01:	f7 74 24 08          	divl   0x8(%esp)
  801e05:	89 d1                	mov    %edx,%ecx
  801e07:	89 f3                	mov    %esi,%ebx
  801e09:	f7 64 24 0c          	mull   0xc(%esp)
  801e0d:	89 c6                	mov    %eax,%esi
  801e0f:	89 d7                	mov    %edx,%edi
  801e11:	39 d1                	cmp    %edx,%ecx
  801e13:	72 06                	jb     801e1b <__umoddi3+0x10b>
  801e15:	75 10                	jne    801e27 <__umoddi3+0x117>
  801e17:	39 c3                	cmp    %eax,%ebx
  801e19:	73 0c                	jae    801e27 <__umoddi3+0x117>
  801e1b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e1f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e23:	89 d7                	mov    %edx,%edi
  801e25:	89 c6                	mov    %eax,%esi
  801e27:	89 ca                	mov    %ecx,%edx
  801e29:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e2e:	29 f3                	sub    %esi,%ebx
  801e30:	19 fa                	sbb    %edi,%edx
  801e32:	89 d0                	mov    %edx,%eax
  801e34:	d3 e0                	shl    %cl,%eax
  801e36:	89 e9                	mov    %ebp,%ecx
  801e38:	d3 eb                	shr    %cl,%ebx
  801e3a:	d3 ea                	shr    %cl,%edx
  801e3c:	09 d8                	or     %ebx,%eax
  801e3e:	83 c4 1c             	add    $0x1c,%esp
  801e41:	5b                   	pop    %ebx
  801e42:	5e                   	pop    %esi
  801e43:	5f                   	pop    %edi
  801e44:	5d                   	pop    %ebp
  801e45:	c3                   	ret    
  801e46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e4d:	8d 76 00             	lea    0x0(%esi),%esi
  801e50:	29 fe                	sub    %edi,%esi
  801e52:	19 c3                	sbb    %eax,%ebx
  801e54:	89 f2                	mov    %esi,%edx
  801e56:	89 d9                	mov    %ebx,%ecx
  801e58:	e9 1d ff ff ff       	jmp    801d7a <__umoddi3+0x6a>
