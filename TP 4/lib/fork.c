// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW 0x800

// IMPLEMENTAR DUP_OR_SHARE
static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
	// Si la pagina no es solo lectura
	if (perm & PTE_W) {
		int r;

		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
			panic("sys_page_alloc failed at dup_or_share");
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
			panic("sys_page_map failed at dup_or_share");
		memmove(UTEMP, va, PGSIZE);
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
			panic("sys_page_unmap failed at dup_or_share");
	} else {
		int r;
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
			panic("sys_page_map failed at dup_or_share");
	}
}


// IMPLEMENTAR FORK_V0 -> SIMILAR A DUMBFORK
envid_t
fork_v0(void)
{
	envid_t envid;
	uint8_t *addr;
	int r;

	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork failed");
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Aca en el for la diferencia con dumbfork
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
		pde_t *pgdirentry = (pde_t *) (PGADDR(
		        PDX(uvpd), PTX(uvpd), (PDX(addr) * sizeof(pde_t))));

		if ((*pgdirentry) & PTE_P) {
			pte_t *pgtablentry =
			        (pte_t *) (PGADDR(PDX(uvpt),
			                          PDX(addr),
			                          (PTX(addr) * sizeof(pte_t))));
			// Si la pagina esta mapeada se llama a dup_or_share
			// ptablentry&PTE_SYSCALL para limitar flags a los que acepta sys_page_map
			if ((*pgtablentry) & PTE_P)
				dup_or_share(envid,
				             addr,
				             (*pgtablentry) & PTE_SYSCALL);
		}
	}
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status failed at fork_v0");

	return envid;
}

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// Page Table Entry
	pte_t pt_e = uvpt[PGNUM(addr)];

	// (1) a write
	if ((err & FEC_WR) == 0)
		panic("ERROR EN PGFAULT: WRITE");

	// (2) to a copy-on-write
	if ((pt_e & PTE_COW) == 0)
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// no return
	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
		panic("pgfault failed");
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
	    0)
		panic("pgfault failed");
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
		panic("pgfault failed");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);

	if (pt_e & PTE_SHARE) {
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
	int err;

	// handle padre
	set_pgfault_handler(pgfault);

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	size_t pd_x;
	pd_x = 0;

	size_t pt_x;
	pt_x = 0;

	while (pd_x < PDX(UTOP)) {
		pde_t pd_e = uvpd[pd_x];
		// Ver si PT alocada
		if ((pd_e & PTE_P) == 0) {
			pd_x++;
			continue;
		}
		pt_x = 0;

		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
					panic("ERROR EN FORK: sys_page_alloc: "
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
