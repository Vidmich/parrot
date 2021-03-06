# POWER/AIX asm helper functions for preserving cache synchronization and
# respecting AIX calling conventions

# Commented instructions are the important bits; supporting boilerplate
# generated by xlc

.machine "pwr"
.set SP,1; .set RTOC,2; .set BO_ALWAYS,20; .set CR0_LT,0

.globl .aix_get_toc
.globl .ppc_sync
.globl .ppc_flush_line
.globl .Parrot_ppc_jit_restore_nonvolatile_registers

# Flushes the cache line whose address is passed in
.ppc_flush_line:
    .function .ppc_flush_line,.ppc_flush_line,2,0
    stm 30,-8(1)
    stu 1,-48(1)
    mr 30,1
    st 3,72(30)
    l 0,72(30)
    clf 0,0 # "Cache Line Flush", analog of "dcbf" instruction on PPC
    l 1,0(1)
    lmw 30,-8(1)
    bcr BO_ALWAYS,CR0_LT

# Synchronizes the cache
.ppc_sync:
    .function .ppc_sync,.ppc_sync,2,0
    dcs # "Data Cache Synchronize", analog of "sync" instruction on PPC
    bcr BO_ALWAYS,CR0_LT

# Returns the value from the TOC register r2
.aix_get_toc:
    .function .aix_get_toc,.aix_get_toc,2,0
    stu SP,-80(SP)
    mr 3, RTOC # Copy r2 (TOC) into r3 (return value)
    st 3,68(SP)
    cal SP,80(SP)
    bcr BO_ALWAYS,CR0_LT
