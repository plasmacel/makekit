# Cross compile

The triple has the general format `<arch><sub>-<vendor>-<sys>-<abi>`, where:
- `arch` = x86_64, i386, arm, thumb, mips, etc.
- `sub` = for ex. on ARM: v5, v6m, v7a, v7m, etc.
- `vendor` = pc, apple, nvidia, ibm, etc.
- `sys` = none, linux, win32, darwin, cuda, etc.
- `abi` = eabi, gnu, android, macho, elf, etc.

You can find out your host platform triplet using the command `clang -dumpmachine`

More info
- https://clang.llvm.org/docs/CrossCompilation.html
- 

### Processor (`arch`)

- `arm`            : ARM (little endian): arm, armv.*, xscale
- `armeb`          : ARM (big endian): armeb
- `aarch64`        : AArch64 (little endian): aarch64
- `aarch64_be`     : AArch64 (big endian): aarch64_be
- `arc`            : ARC: Synopsys ARC
- `avr`            : AVR: Atmel AVR microcontroller
- `bpfel`          : eBPF or extended BPF or 64-bit BPF (little endian)
- `bpfeb`          : eBPF or extended BPF or 64-bit BPF (big endian)
- `hexagon`        : Hexagon: hexagon
- `mips`           : MIPS: mips, mipsallegrex
- `mipsel`         : MIPSEL: mipsel, mipsallegrexel
- `mips64`         : MIPS64: mips64
- `mips64el`       : MIPS64EL: mips64el
- `msp430`         : MSP430: msp430
- `nios2`          : NIOSII: nios2
- `ppc`            : PPC: powerpc
- `ppc64`          : PPC64: powerpc64, ppu
- `ppc64le`        : PPC64LE: powerpc64le
- `r600`           : R600: AMD GPUs HD2XXX - HD6XXX
- `amdgcn`         : AMDGCN: AMD GCN GPUs
- `riscv32`        : RISC-V (32-bit): riscv32
- `riscv64`        : RISC-V (64-bit): riscv64
- `sparc`          : Sparc: sparc
- `sparcv9`        : Sparcv9: Sparcv9
- `sparcel`        : Sparc: (endianness = little). NB: 'Sparcle' is a CPU variant
- `systemz`        : SystemZ: s390x
- `tce`            : TCE (http://tce.cs.tut.fi/): tce
- `tcele`          : TCE little endian (http://tce.cs.tut.fi/): tcele
- `thumb`          : Thumb (little endian): thumb, thumbv.*
- `thumbeb`        : Thumb (big endian): thumbeb
- `x86`            : X86: i[3-9]86
- `x86_64`         : X86-64: amd64, x86_64
- `xcore`          : XCore: xcore
- `nvptx`          : NVPTX: 32-bit
- `nvptx64`        : NVPTX: 64-bit
- `le32`           : le32: generic little-endian 32-bit CPU (PNaCl)
- `le64`           : le64: generic little-endian 64-bit CPU (PNaCl)
- `amdil`          : AMDIL
- `amdil64`        : AMDIL with 64-bit pointers
- `hsail`          : AMD HSAIL
- `hsail64`        : AMD HSAIL with 64-bit pointers
- `spir`           : SPIR: standard portable IR for OpenCL 32-bit version
- `spir64`         : SPIR: standard portable IR for OpenCL 64-bit version
- `kalimba`        : Kalimba: generic kalimba
- `shave`          : SHAVE: Movidius vector VLIW processors
- `lanai`          : Lanai: Lanai 32-bit
- `wasm32`         : WebAssembly with 32-bit pointers
- `wasm64`         : WebAssembly with 64-bit pointers

### Vendor (`vendor`)

- `Apple`
- `PC`
- `SCEI`
- `BGP`
- `BGQ`
- `Freescale`
- `IBM`
- `ImaginationTechnologies`
- `MipsTechnologies`
- `NVIDIA`
- `CSR`
- `Myriad`
- `AMD`
- `Mesa`
- `SUSE`
- `OpenEmbedded`

### Operation system (`sys`)

- `ananas`
- `cloudabi`
- `darwin`
- `dragonfly`
- `freebsd`
- `fuchsia`
- `ios`
- `kfreebsd`
- `linux`
- `lv2`        : PS3
- `macosx`
- `netbsd`
- `openbsd`
- `solaris`
- `win32`
- `haiku`
- `minix`
- `rtems`
- `nacl`       : Native Client
- `cnk`        : BG/P Compute-Node Kernel
- `aix`
- `cuda`       : NVIDIA CUDA
- `nvcl`       : NVIDIA OpenCL
- `amdhsa`     : AMD HSA Runtime
- `ps4`
- `elfiamcu`
- `tvos`       : Apple tvOS
- `watchos`    : Apple watchOS
- `mesa3d`
- `contiki`
- `amdpal`     : AMD PAL Runtime

### ABI Environment (`abi`)

- `gnu`
- `gnuabin32`
- `gnuabi64`
- `gnueabi`
- `gnueabihf`
- `gnux32`
- `code16`
- `eabi`
- `eabihf`
- `android`
- `musl`
- `musleabi`
- `musleabihf`
- `msvc`
- `itanium`
- `cygnus`
- `coreclr`
- `simulator` : simulator variants of other systems, e.g., apple's ios

