
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00002117          	auipc	sp,0x2
    80000004:	25013103          	ld	sp,592(sp) # 80002250 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	006000ef          	jal	ra,8000001c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <start>:
extern void timervec();

// entry.S jumps here in machine mode on stack0.
void
start()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16

static inline uint64
r_mstatus()
{
  uint64 x;
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000022:	300027f3          	csrr	a5,mstatus
  // set M Previous Privilege mode to Supervisor, for mret.
  unsigned long x = r_mstatus();
  x &= ~MSTATUS_MPP_MASK;
    80000026:	7779                	lui	a4,0xffffe
    80000028:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffee4cf>
    8000002c:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000002e:	6705                	lui	a4,0x1
    80000030:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000034:	8fd9                	or	a5,a5,a4
}

static inline void 
w_mstatus(uint64 x)
{
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000036:	30079073          	csrw	mstatus,a5
// instruction address to which a return from
// exception will go.
static inline void 
w_mepc(uint64 x)
{
  asm volatile("csrw mepc, %0" : : "r" (x));
    8000003a:	00001797          	auipc	a5,0x1
    8000003e:	8fc78793          	addi	a5,a5,-1796 # 80000936 <main>
    80000042:	34179073          	csrw	mepc,a5
// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
  asm volatile("csrw satp, %0" : : "r" (x));
    80000046:	4781                	li	a5,0
    80000048:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    8000004c:	67c1                	lui	a5,0x10
    8000004e:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000050:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80000054:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000058:	104027f3          	csrr	a5,sie
  w_satp(0);

  // delegate all interrupts and exceptions to supervisor mode.
  w_medeleg(0xffff);
  w_mideleg(0xffff);
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000005c:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000060:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80000064:	57fd                	li	a5,-1
    80000066:	83a9                	srli	a5,a5,0xa
    80000068:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    8000006c:	47bd                	li	a5,15
    8000006e:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000072:	f14027f3          	csrr	a5,mhartid
  w_pmpcfg0(0xf);


  // keep each CPU's hartid in its tp register, for cpuid().
  int id = r_mhartid();
  w_tp(id);
    80000076:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    80000078:	823e                	mv	tp,a5

  // switch to supervisor mode and jump to main().
  asm volatile("mret");
    8000007a:	30200073          	mret
}
    8000007e:	6422                	ld	s0,8(sp)
    80000080:	0141                	addi	sp,sp,16
    80000082:	8082                	ret

0000000080000084 <consputc>:
// called by printf(), and to echo input characters,
// but not from write().
//
void
consputc(int c)
{
    80000084:	1141                	addi	sp,sp,-16
    80000086:	e406                	sd	ra,8(sp)
    80000088:	e022                	sd	s0,0(sp)
    8000008a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000008c:	10000793          	li	a5,256
    80000090:	00f50a63          	beq	a0,a5,800000a4 <consputc+0x20>
    // if the user typed backspace, overwrite with a space.
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
  } else {
    uartputc_sync(c);
    80000094:	00000097          	auipc	ra,0x0
    80000098:	3a2080e7          	jalr	930(ra) # 80000436 <uartputc_sync>
  }
}
    8000009c:	60a2                	ld	ra,8(sp)
    8000009e:	6402                	ld	s0,0(sp)
    800000a0:	0141                	addi	sp,sp,16
    800000a2:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800000a4:	4521                	li	a0,8
    800000a6:	00000097          	auipc	ra,0x0
    800000aa:	390080e7          	jalr	912(ra) # 80000436 <uartputc_sync>
    800000ae:	02000513          	li	a0,32
    800000b2:	00000097          	auipc	ra,0x0
    800000b6:	384080e7          	jalr	900(ra) # 80000436 <uartputc_sync>
    800000ba:	4521                	li	a0,8
    800000bc:	00000097          	auipc	ra,0x0
    800000c0:	37a080e7          	jalr	890(ra) # 80000436 <uartputc_sync>
    800000c4:	bfe1                	j	8000009c <consputc+0x18>

00000000800000c6 <consoleinit>:


//maybe delete ? It involves read and write
void
consoleinit(void)
{
    800000c6:	1141                	addi	sp,sp,-16
    800000c8:	e406                	sd	ra,8(sp)
    800000ca:	e022                	sd	s0,0(sp)
    800000cc:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800000ce:	00002597          	auipc	a1,0x2
    800000d2:	f3258593          	addi	a1,a1,-206 # 80002000 <swtch+0xc3a>
    800000d6:	0000a517          	auipc	a0,0xa
    800000da:	30a50513          	addi	a0,a0,778 # 8000a3e0 <cons>
    800000de:	00000097          	auipc	ra,0x0
    800000e2:	526080e7          	jalr	1318(ra) # 80000604 <initlock>

  // connect read and write system calls
  // to consoleread and consolewrite.
  // devsw[CONSOLE].read = consoleread;
  // devsw[CONSOLE].write = consolewrite;
}
    800000e6:	60a2                	ld	ra,8(sp)
    800000e8:	6402                	ld	s0,0(sp)
    800000ea:	0141                	addi	sp,sp,16
    800000ec:	8082                	ret

00000000800000ee <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800000ee:	7179                	addi	sp,sp,-48
    800000f0:	f406                	sd	ra,40(sp)
    800000f2:	f022                	sd	s0,32(sp)
    800000f4:	ec26                	sd	s1,24(sp)
    800000f6:	e84a                	sd	s2,16(sp)
    800000f8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800000fa:	c219                	beqz	a2,80000100 <printint+0x12>
    800000fc:	08054763          	bltz	a0,8000018a <printint+0x9c>
    x = -xx;
  else
    x = xx;
    80000100:	2501                	sext.w	a0,a0
    80000102:	4881                	li	a7,0
    80000104:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000108:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000010a:	2581                	sext.w	a1,a1
    8000010c:	00002617          	auipc	a2,0x2
    80000110:	f2460613          	addi	a2,a2,-220 # 80002030 <digits>
    80000114:	883a                	mv	a6,a4
    80000116:	2705                	addiw	a4,a4,1
    80000118:	02b577bb          	remuw	a5,a0,a1
    8000011c:	1782                	slli	a5,a5,0x20
    8000011e:	9381                	srli	a5,a5,0x20
    80000120:	97b2                	add	a5,a5,a2
    80000122:	0007c783          	lbu	a5,0(a5)
    80000126:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000012a:	0005079b          	sext.w	a5,a0
    8000012e:	02b5553b          	divuw	a0,a0,a1
    80000132:	0685                	addi	a3,a3,1
    80000134:	feb7f0e3          	bgeu	a5,a1,80000114 <printint+0x26>

  if(sign)
    80000138:	00088c63          	beqz	a7,80000150 <printint+0x62>
    buf[i++] = '-';
    8000013c:	fe070793          	addi	a5,a4,-32
    80000140:	00878733          	add	a4,a5,s0
    80000144:	02d00793          	li	a5,45
    80000148:	fef70823          	sb	a5,-16(a4)
    8000014c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000150:	02e05763          	blez	a4,8000017e <printint+0x90>
    80000154:	fd040793          	addi	a5,s0,-48
    80000158:	00e784b3          	add	s1,a5,a4
    8000015c:	fff78913          	addi	s2,a5,-1
    80000160:	993a                	add	s2,s2,a4
    80000162:	377d                	addiw	a4,a4,-1
    80000164:	1702                	slli	a4,a4,0x20
    80000166:	9301                	srli	a4,a4,0x20
    80000168:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000016c:	fff4c503          	lbu	a0,-1(s1)
    80000170:	00000097          	auipc	ra,0x0
    80000174:	f14080e7          	jalr	-236(ra) # 80000084 <consputc>
  while(--i >= 0)
    80000178:	14fd                	addi	s1,s1,-1
    8000017a:	ff2499e3          	bne	s1,s2,8000016c <printint+0x7e>
}
    8000017e:	70a2                	ld	ra,40(sp)
    80000180:	7402                	ld	s0,32(sp)
    80000182:	64e2                	ld	s1,24(sp)
    80000184:	6942                	ld	s2,16(sp)
    80000186:	6145                	addi	sp,sp,48
    80000188:	8082                	ret
    x = -xx;
    8000018a:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000018e:	4885                	li	a7,1
    x = -xx;
    80000190:	bf95                	j	80000104 <printint+0x16>

0000000080000192 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000192:	1101                	addi	sp,sp,-32
    80000194:	ec06                	sd	ra,24(sp)
    80000196:	e822                	sd	s0,16(sp)
    80000198:	e426                	sd	s1,8(sp)
    8000019a:	1000                	addi	s0,sp,32
    8000019c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000019e:	0000a797          	auipc	a5,0xa
    800001a2:	3007a123          	sw	zero,770(a5) # 8000a4a0 <pr+0x18>
  printf("panic: ");
    800001a6:	00002517          	auipc	a0,0x2
    800001aa:	e6250513          	addi	a0,a0,-414 # 80002008 <swtch+0xc42>
    800001ae:	00000097          	auipc	ra,0x0
    800001b2:	02e080e7          	jalr	46(ra) # 800001dc <printf>
  printf(s);
    800001b6:	8526                	mv	a0,s1
    800001b8:	00000097          	auipc	ra,0x0
    800001bc:	024080e7          	jalr	36(ra) # 800001dc <printf>
  printf("\n");
    800001c0:	00002517          	auipc	a0,0x2
    800001c4:	ef850513          	addi	a0,a0,-264 # 800020b8 <digits+0x88>
    800001c8:	00000097          	auipc	ra,0x0
    800001cc:	014080e7          	jalr	20(ra) # 800001dc <printf>
  panicked = 1; // freeze uart output from other CPUs
    800001d0:	4785                	li	a5,1
    800001d2:	00002717          	auipc	a4,0x2
    800001d6:	08f72f23          	sw	a5,158(a4) # 80002270 <panicked>
  for(;;)
    800001da:	a001                	j	800001da <panic+0x48>

00000000800001dc <printf>:
{
    800001dc:	7131                	addi	sp,sp,-192
    800001de:	fc86                	sd	ra,120(sp)
    800001e0:	f8a2                	sd	s0,112(sp)
    800001e2:	f4a6                	sd	s1,104(sp)
    800001e4:	f0ca                	sd	s2,96(sp)
    800001e6:	ecce                	sd	s3,88(sp)
    800001e8:	e8d2                	sd	s4,80(sp)
    800001ea:	e4d6                	sd	s5,72(sp)
    800001ec:	e0da                	sd	s6,64(sp)
    800001ee:	fc5e                	sd	s7,56(sp)
    800001f0:	f862                	sd	s8,48(sp)
    800001f2:	f466                	sd	s9,40(sp)
    800001f4:	f06a                	sd	s10,32(sp)
    800001f6:	ec6e                	sd	s11,24(sp)
    800001f8:	0100                	addi	s0,sp,128
    800001fa:	8a2a                	mv	s4,a0
    800001fc:	e40c                	sd	a1,8(s0)
    800001fe:	e810                	sd	a2,16(s0)
    80000200:	ec14                	sd	a3,24(s0)
    80000202:	f018                	sd	a4,32(s0)
    80000204:	f41c                	sd	a5,40(s0)
    80000206:	03043823          	sd	a6,48(s0)
    8000020a:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    8000020e:	0000ad97          	auipc	s11,0xa
    80000212:	292dad83          	lw	s11,658(s11) # 8000a4a0 <pr+0x18>
  if(locking)
    80000216:	020d9b63          	bnez	s11,8000024c <printf+0x70>
  if (fmt == 0)
    8000021a:	040a0263          	beqz	s4,8000025e <printf+0x82>
  va_start(ap, fmt);
    8000021e:	00840793          	addi	a5,s0,8
    80000222:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000226:	000a4503          	lbu	a0,0(s4)
    8000022a:	14050f63          	beqz	a0,80000388 <printf+0x1ac>
    8000022e:	4981                	li	s3,0
    if(c != '%'){
    80000230:	02500a93          	li	s5,37
    switch(c){
    80000234:	07000b93          	li	s7,112
  consputc('x');
    80000238:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000023a:	00002b17          	auipc	s6,0x2
    8000023e:	df6b0b13          	addi	s6,s6,-522 # 80002030 <digits>
    switch(c){
    80000242:	07300c93          	li	s9,115
    80000246:	06400c13          	li	s8,100
    8000024a:	a82d                	j	80000284 <printf+0xa8>
    acquire(&pr.lock);
    8000024c:	0000a517          	auipc	a0,0xa
    80000250:	23c50513          	addi	a0,a0,572 # 8000a488 <pr>
    80000254:	00000097          	auipc	ra,0x0
    80000258:	440080e7          	jalr	1088(ra) # 80000694 <acquire>
    8000025c:	bf7d                	j	8000021a <printf+0x3e>
    panic("null fmt");
    8000025e:	00002517          	auipc	a0,0x2
    80000262:	dba50513          	addi	a0,a0,-582 # 80002018 <swtch+0xc52>
    80000266:	00000097          	auipc	ra,0x0
    8000026a:	f2c080e7          	jalr	-212(ra) # 80000192 <panic>
      consputc(c);
    8000026e:	00000097          	auipc	ra,0x0
    80000272:	e16080e7          	jalr	-490(ra) # 80000084 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000276:	2985                	addiw	s3,s3,1
    80000278:	013a07b3          	add	a5,s4,s3
    8000027c:	0007c503          	lbu	a0,0(a5)
    80000280:	10050463          	beqz	a0,80000388 <printf+0x1ac>
    if(c != '%'){
    80000284:	ff5515e3          	bne	a0,s5,8000026e <printf+0x92>
    c = fmt[++i] & 0xff;
    80000288:	2985                	addiw	s3,s3,1
    8000028a:	013a07b3          	add	a5,s4,s3
    8000028e:	0007c783          	lbu	a5,0(a5)
    80000292:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000296:	cbed                	beqz	a5,80000388 <printf+0x1ac>
    switch(c){
    80000298:	05778a63          	beq	a5,s7,800002ec <printf+0x110>
    8000029c:	02fbf663          	bgeu	s7,a5,800002c8 <printf+0xec>
    800002a0:	09978863          	beq	a5,s9,80000330 <printf+0x154>
    800002a4:	07800713          	li	a4,120
    800002a8:	0ce79563          	bne	a5,a4,80000372 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    800002ac:	f8843783          	ld	a5,-120(s0)
    800002b0:	00878713          	addi	a4,a5,8
    800002b4:	f8e43423          	sd	a4,-120(s0)
    800002b8:	4605                	li	a2,1
    800002ba:	85ea                	mv	a1,s10
    800002bc:	4388                	lw	a0,0(a5)
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	e30080e7          	jalr	-464(ra) # 800000ee <printint>
      break;
    800002c6:	bf45                	j	80000276 <printf+0x9a>
    switch(c){
    800002c8:	09578f63          	beq	a5,s5,80000366 <printf+0x18a>
    800002cc:	0b879363          	bne	a5,s8,80000372 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    800002d0:	f8843783          	ld	a5,-120(s0)
    800002d4:	00878713          	addi	a4,a5,8
    800002d8:	f8e43423          	sd	a4,-120(s0)
    800002dc:	4605                	li	a2,1
    800002de:	45a9                	li	a1,10
    800002e0:	4388                	lw	a0,0(a5)
    800002e2:	00000097          	auipc	ra,0x0
    800002e6:	e0c080e7          	jalr	-500(ra) # 800000ee <printint>
      break;
    800002ea:	b771                	j	80000276 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800002ec:	f8843783          	ld	a5,-120(s0)
    800002f0:	00878713          	addi	a4,a5,8
    800002f4:	f8e43423          	sd	a4,-120(s0)
    800002f8:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800002fc:	03000513          	li	a0,48
    80000300:	00000097          	auipc	ra,0x0
    80000304:	d84080e7          	jalr	-636(ra) # 80000084 <consputc>
  consputc('x');
    80000308:	07800513          	li	a0,120
    8000030c:	00000097          	auipc	ra,0x0
    80000310:	d78080e7          	jalr	-648(ra) # 80000084 <consputc>
    80000314:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000316:	03c95793          	srli	a5,s2,0x3c
    8000031a:	97da                	add	a5,a5,s6
    8000031c:	0007c503          	lbu	a0,0(a5)
    80000320:	00000097          	auipc	ra,0x0
    80000324:	d64080e7          	jalr	-668(ra) # 80000084 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000328:	0912                	slli	s2,s2,0x4
    8000032a:	34fd                	addiw	s1,s1,-1
    8000032c:	f4ed                	bnez	s1,80000316 <printf+0x13a>
    8000032e:	b7a1                	j	80000276 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80000330:	f8843783          	ld	a5,-120(s0)
    80000334:	00878713          	addi	a4,a5,8
    80000338:	f8e43423          	sd	a4,-120(s0)
    8000033c:	6384                	ld	s1,0(a5)
    8000033e:	cc89                	beqz	s1,80000358 <printf+0x17c>
      for(; *s; s++)
    80000340:	0004c503          	lbu	a0,0(s1)
    80000344:	d90d                	beqz	a0,80000276 <printf+0x9a>
        consputc(*s);
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	d3e080e7          	jalr	-706(ra) # 80000084 <consputc>
      for(; *s; s++)
    8000034e:	0485                	addi	s1,s1,1
    80000350:	0004c503          	lbu	a0,0(s1)
    80000354:	f96d                	bnez	a0,80000346 <printf+0x16a>
    80000356:	b705                	j	80000276 <printf+0x9a>
        s = "(null)";
    80000358:	00002497          	auipc	s1,0x2
    8000035c:	cb848493          	addi	s1,s1,-840 # 80002010 <swtch+0xc4a>
      for(; *s; s++)
    80000360:	02800513          	li	a0,40
    80000364:	b7cd                	j	80000346 <printf+0x16a>
      consputc('%');
    80000366:	8556                	mv	a0,s5
    80000368:	00000097          	auipc	ra,0x0
    8000036c:	d1c080e7          	jalr	-740(ra) # 80000084 <consputc>
      break;
    80000370:	b719                	j	80000276 <printf+0x9a>
      consputc('%');
    80000372:	8556                	mv	a0,s5
    80000374:	00000097          	auipc	ra,0x0
    80000378:	d10080e7          	jalr	-752(ra) # 80000084 <consputc>
      consputc(c);
    8000037c:	8526                	mv	a0,s1
    8000037e:	00000097          	auipc	ra,0x0
    80000382:	d06080e7          	jalr	-762(ra) # 80000084 <consputc>
      break;
    80000386:	bdc5                	j	80000276 <printf+0x9a>
  if(locking)
    80000388:	020d9163          	bnez	s11,800003aa <printf+0x1ce>
}
    8000038c:	70e6                	ld	ra,120(sp)
    8000038e:	7446                	ld	s0,112(sp)
    80000390:	74a6                	ld	s1,104(sp)
    80000392:	7906                	ld	s2,96(sp)
    80000394:	69e6                	ld	s3,88(sp)
    80000396:	6a46                	ld	s4,80(sp)
    80000398:	6aa6                	ld	s5,72(sp)
    8000039a:	6b06                	ld	s6,64(sp)
    8000039c:	7be2                	ld	s7,56(sp)
    8000039e:	7c42                	ld	s8,48(sp)
    800003a0:	7ca2                	ld	s9,40(sp)
    800003a2:	7d02                	ld	s10,32(sp)
    800003a4:	6de2                	ld	s11,24(sp)
    800003a6:	6129                	addi	sp,sp,192
    800003a8:	8082                	ret
    release(&pr.lock);
    800003aa:	0000a517          	auipc	a0,0xa
    800003ae:	0de50513          	addi	a0,a0,222 # 8000a488 <pr>
    800003b2:	00000097          	auipc	ra,0x0
    800003b6:	396080e7          	jalr	918(ra) # 80000748 <release>
}
    800003ba:	bfc9                	j	8000038c <printf+0x1b0>

00000000800003bc <printfinit>:
    ;
}

void
printfinit(void)
{
    800003bc:	1101                	addi	sp,sp,-32
    800003be:	ec06                	sd	ra,24(sp)
    800003c0:	e822                	sd	s0,16(sp)
    800003c2:	e426                	sd	s1,8(sp)
    800003c4:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800003c6:	0000a497          	auipc	s1,0xa
    800003ca:	0c248493          	addi	s1,s1,194 # 8000a488 <pr>
    800003ce:	00002597          	auipc	a1,0x2
    800003d2:	c5a58593          	addi	a1,a1,-934 # 80002028 <swtch+0xc62>
    800003d6:	8526                	mv	a0,s1
    800003d8:	00000097          	auipc	ra,0x0
    800003dc:	22c080e7          	jalr	556(ra) # 80000604 <initlock>
  pr.locking = 1;
    800003e0:	4785                	li	a5,1
    800003e2:	cc9c                	sw	a5,24(s1)
}
    800003e4:	60e2                	ld	ra,24(sp)
    800003e6:	6442                	ld	s0,16(sp)
    800003e8:	64a2                	ld	s1,8(sp)
    800003ea:	6105                	addi	sp,sp,32
    800003ec:	8082                	ret

00000000800003ee <uartinit>:

void uartstart();

void
uartinit(void)
{
    800003ee:	1141                	addi	sp,sp,-16
    800003f0:	e406                	sd	ra,8(sp)
    800003f2:	e022                	sd	s0,0(sp)
    800003f4:	0800                	addi	s0,sp,16
  // disable interrupts.
  // WriteReg(IER, 0x00);

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800003f6:	100007b7          	lui	a5,0x10000
    800003fa:	f8000713          	li	a4,-128
    800003fe:	00e781a3          	sb	a4,3(a5) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000402:	470d                	li	a4,3
    80000404:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000408:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000040c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000410:	471d                	li	a4,7
    80000412:	00e78123          	sb	a4,2(a5)

  // enable transmit and receive interrupts.
  // WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);

  initlock(&uart_tx_lock, "uart");
    80000416:	00002597          	auipc	a1,0x2
    8000041a:	c3258593          	addi	a1,a1,-974 # 80002048 <digits+0x18>
    8000041e:	0000a517          	auipc	a0,0xa
    80000422:	08a50513          	addi	a0,a0,138 # 8000a4a8 <uart_tx_lock>
    80000426:	00000097          	auipc	ra,0x0
    8000042a:	1de080e7          	jalr	478(ra) # 80000604 <initlock>
}
    8000042e:	60a2                	ld	ra,8(sp)
    80000430:	6402                	ld	s0,0(sp)
    80000432:	0141                	addi	sp,sp,16
    80000434:	8082                	ret

0000000080000436 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000436:	1101                	addi	sp,sp,-32
    80000438:	ec06                	sd	ra,24(sp)
    8000043a:	e822                	sd	s0,16(sp)
    8000043c:	e426                	sd	s1,8(sp)
    8000043e:	1000                	addi	s0,sp,32
    80000440:	84aa                	mv	s1,a0
  push_off();
    80000442:	00000097          	auipc	ra,0x0
    80000446:	206080e7          	jalr	518(ra) # 80000648 <push_off>

  if(panicked){
    8000044a:	00002797          	auipc	a5,0x2
    8000044e:	e267a783          	lw	a5,-474(a5) # 80002270 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000452:	10000737          	lui	a4,0x10000
  if(panicked){
    80000456:	c391                	beqz	a5,8000045a <uartputc_sync+0x24>
    for(;;)
    80000458:	a001                	j	80000458 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000045a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000045e:	0207f793          	andi	a5,a5,32
    80000462:	dfe5                	beqz	a5,8000045a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000464:	0ff4f513          	zext.b	a0,s1
    80000468:	100007b7          	lui	a5,0x10000
    8000046c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	278080e7          	jalr	632(ra) # 800006e8 <pop_off>
}
    80000478:	60e2                	ld	ra,24(sp)
    8000047a:	6442                	ld	s0,16(sp)
    8000047c:	64a2                	ld	s1,8(sp)
    8000047e:	6105                	addi	sp,sp,32
    80000480:	8082                	ret

0000000080000482 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000482:	1141                	addi	sp,sp,-16
    80000484:	e422                	sd	s0,8(sp)
    80000486:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000488:	100007b7          	lui	a5,0x10000
    8000048c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000490:	8b85                	andi	a5,a5,1
    80000492:	cb81                	beqz	a5,800004a2 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000494:	100007b7          	lui	a5,0x10000
    80000498:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000049c:	6422                	ld	s0,8(sp)
    8000049e:	0141                	addi	sp,sp,16
    800004a0:	8082                	ret
    return -1;
    800004a2:	557d                	li	a0,-1
    800004a4:	bfe5                	j	8000049c <uartgetc+0x1a>

00000000800004a6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800004a6:	1101                	addi	sp,sp,-32
    800004a8:	ec06                	sd	ra,24(sp)
    800004aa:	e822                	sd	s0,16(sp)
    800004ac:	e426                	sd	s1,8(sp)
    800004ae:	e04a                	sd	s2,0(sp)
    800004b0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800004b2:	03451793          	slli	a5,a0,0x34
    800004b6:	ebb9                	bnez	a5,8000050c <kfree+0x66>
    800004b8:	84aa                	mv	s1,a0
    800004ba:	00010797          	auipc	a5,0x10
    800004be:	e7678793          	addi	a5,a5,-394 # 80010330 <end>
    800004c2:	04f56563          	bltu	a0,a5,8000050c <kfree+0x66>
    800004c6:	47c5                	li	a5,17
    800004c8:	07ee                	slli	a5,a5,0x1b
    800004ca:	04f57163          	bgeu	a0,a5,8000050c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800004ce:	6605                	lui	a2,0x1
    800004d0:	4585                	li	a1,1
    800004d2:	00000097          	auipc	ra,0x0
    800004d6:	2be080e7          	jalr	702(ra) # 80000790 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800004da:	0000a917          	auipc	s2,0xa
    800004de:	00690913          	addi	s2,s2,6 # 8000a4e0 <kmem>
    800004e2:	854a                	mv	a0,s2
    800004e4:	00000097          	auipc	ra,0x0
    800004e8:	1b0080e7          	jalr	432(ra) # 80000694 <acquire>
  r->next = kmem.freelist;
    800004ec:	01893783          	ld	a5,24(s2)
    800004f0:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800004f2:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    800004f6:	854a                	mv	a0,s2
    800004f8:	00000097          	auipc	ra,0x0
    800004fc:	250080e7          	jalr	592(ra) # 80000748 <release>
}
    80000500:	60e2                	ld	ra,24(sp)
    80000502:	6442                	ld	s0,16(sp)
    80000504:	64a2                	ld	s1,8(sp)
    80000506:	6902                	ld	s2,0(sp)
    80000508:	6105                	addi	sp,sp,32
    8000050a:	8082                	ret
    panic("kfree");
    8000050c:	00002517          	auipc	a0,0x2
    80000510:	b4450513          	addi	a0,a0,-1212 # 80002050 <digits+0x20>
    80000514:	00000097          	auipc	ra,0x0
    80000518:	c7e080e7          	jalr	-898(ra) # 80000192 <panic>

000000008000051c <freerange>:
{
    8000051c:	7179                	addi	sp,sp,-48
    8000051e:	f406                	sd	ra,40(sp)
    80000520:	f022                	sd	s0,32(sp)
    80000522:	ec26                	sd	s1,24(sp)
    80000524:	e84a                	sd	s2,16(sp)
    80000526:	e44e                	sd	s3,8(sp)
    80000528:	e052                	sd	s4,0(sp)
    8000052a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    8000052c:	6785                	lui	a5,0x1
    8000052e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000532:	00e504b3          	add	s1,a0,a4
    80000536:	777d                	lui	a4,0xfffff
    80000538:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000053a:	94be                	add	s1,s1,a5
    8000053c:	0095ee63          	bltu	a1,s1,80000558 <freerange+0x3c>
    80000540:	892e                	mv	s2,a1
    kfree(p);
    80000542:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000544:	6985                	lui	s3,0x1
    kfree(p);
    80000546:	01448533          	add	a0,s1,s4
    8000054a:	00000097          	auipc	ra,0x0
    8000054e:	f5c080e7          	jalr	-164(ra) # 800004a6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000552:	94ce                	add	s1,s1,s3
    80000554:	fe9979e3          	bgeu	s2,s1,80000546 <freerange+0x2a>
}
    80000558:	70a2                	ld	ra,40(sp)
    8000055a:	7402                	ld	s0,32(sp)
    8000055c:	64e2                	ld	s1,24(sp)
    8000055e:	6942                	ld	s2,16(sp)
    80000560:	69a2                	ld	s3,8(sp)
    80000562:	6a02                	ld	s4,0(sp)
    80000564:	6145                	addi	sp,sp,48
    80000566:	8082                	ret

0000000080000568 <kinit>:
{
    80000568:	1141                	addi	sp,sp,-16
    8000056a:	e406                	sd	ra,8(sp)
    8000056c:	e022                	sd	s0,0(sp)
    8000056e:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000570:	00002597          	auipc	a1,0x2
    80000574:	ae858593          	addi	a1,a1,-1304 # 80002058 <digits+0x28>
    80000578:	0000a517          	auipc	a0,0xa
    8000057c:	f6850513          	addi	a0,a0,-152 # 8000a4e0 <kmem>
    80000580:	00000097          	auipc	ra,0x0
    80000584:	084080e7          	jalr	132(ra) # 80000604 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000588:	45c5                	li	a1,17
    8000058a:	05ee                	slli	a1,a1,0x1b
    8000058c:	00010517          	auipc	a0,0x10
    80000590:	da450513          	addi	a0,a0,-604 # 80010330 <end>
    80000594:	00000097          	auipc	ra,0x0
    80000598:	f88080e7          	jalr	-120(ra) # 8000051c <freerange>
}
    8000059c:	60a2                	ld	ra,8(sp)
    8000059e:	6402                	ld	s0,0(sp)
    800005a0:	0141                	addi	sp,sp,16
    800005a2:	8082                	ret

00000000800005a4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    800005a4:	1101                	addi	sp,sp,-32
    800005a6:	ec06                	sd	ra,24(sp)
    800005a8:	e822                	sd	s0,16(sp)
    800005aa:	e426                	sd	s1,8(sp)
    800005ac:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    800005ae:	0000a497          	auipc	s1,0xa
    800005b2:	f3248493          	addi	s1,s1,-206 # 8000a4e0 <kmem>
    800005b6:	8526                	mv	a0,s1
    800005b8:	00000097          	auipc	ra,0x0
    800005bc:	0dc080e7          	jalr	220(ra) # 80000694 <acquire>
  r = kmem.freelist;
    800005c0:	6c84                	ld	s1,24(s1)
  if(r)
    800005c2:	c885                	beqz	s1,800005f2 <kalloc+0x4e>
    kmem.freelist = r->next;
    800005c4:	609c                	ld	a5,0(s1)
    800005c6:	0000a517          	auipc	a0,0xa
    800005ca:	f1a50513          	addi	a0,a0,-230 # 8000a4e0 <kmem>
    800005ce:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    800005d0:	00000097          	auipc	ra,0x0
    800005d4:	178080e7          	jalr	376(ra) # 80000748 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    800005d8:	6605                	lui	a2,0x1
    800005da:	4595                	li	a1,5
    800005dc:	8526                	mv	a0,s1
    800005de:	00000097          	auipc	ra,0x0
    800005e2:	1b2080e7          	jalr	434(ra) # 80000790 <memset>
  return (void*)r;
}
    800005e6:	8526                	mv	a0,s1
    800005e8:	60e2                	ld	ra,24(sp)
    800005ea:	6442                	ld	s0,16(sp)
    800005ec:	64a2                	ld	s1,8(sp)
    800005ee:	6105                	addi	sp,sp,32
    800005f0:	8082                	ret
  release(&kmem.lock);
    800005f2:	0000a517          	auipc	a0,0xa
    800005f6:	eee50513          	addi	a0,a0,-274 # 8000a4e0 <kmem>
    800005fa:	00000097          	auipc	ra,0x0
    800005fe:	14e080e7          	jalr	334(ra) # 80000748 <release>
  if(r)
    80000602:	b7d5                	j	800005e6 <kalloc+0x42>

0000000080000604 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000604:	1141                	addi	sp,sp,-16
    80000606:	e422                	sd	s0,8(sp)
    80000608:	0800                	addi	s0,sp,16
  lk->name = name;
    8000060a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    8000060c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000610:	00053823          	sd	zero,16(a0)
}
    80000614:	6422                	ld	s0,8(sp)
    80000616:	0141                	addi	sp,sp,16
    80000618:	8082                	ret

000000008000061a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    8000061a:	411c                	lw	a5,0(a0)
    8000061c:	e399                	bnez	a5,80000622 <holding+0x8>
    8000061e:	4501                	li	a0,0
  return r;
}
    80000620:	8082                	ret
{
    80000622:	1101                	addi	sp,sp,-32
    80000624:	ec06                	sd	ra,24(sp)
    80000626:	e822                	sd	s0,16(sp)
    80000628:	e426                	sd	s1,8(sp)
    8000062a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    8000062c:	6904                	ld	s1,16(a0)
    8000062e:	00000097          	auipc	ra,0x0
    80000632:	466080e7          	jalr	1126(ra) # 80000a94 <mycpu>
    80000636:	40a48533          	sub	a0,s1,a0
    8000063a:	00153513          	seqz	a0,a0
}
    8000063e:	60e2                	ld	ra,24(sp)
    80000640:	6442                	ld	s0,16(sp)
    80000642:	64a2                	ld	s1,8(sp)
    80000644:	6105                	addi	sp,sp,32
    80000646:	8082                	ret

0000000080000648 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000648:	1101                	addi	sp,sp,-32
    8000064a:	ec06                	sd	ra,24(sp)
    8000064c:	e822                	sd	s0,16(sp)
    8000064e:	e426                	sd	s1,8(sp)
    80000650:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000652:	100024f3          	csrr	s1,sstatus
    80000656:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000065a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000065c:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000660:	00000097          	auipc	ra,0x0
    80000664:	434080e7          	jalr	1076(ra) # 80000a94 <mycpu>
    80000668:	5d3c                	lw	a5,120(a0)
    8000066a:	cf89                	beqz	a5,80000684 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	428080e7          	jalr	1064(ra) # 80000a94 <mycpu>
    80000674:	5d3c                	lw	a5,120(a0)
    80000676:	2785                	addiw	a5,a5,1
    80000678:	dd3c                	sw	a5,120(a0)
}
    8000067a:	60e2                	ld	ra,24(sp)
    8000067c:	6442                	ld	s0,16(sp)
    8000067e:	64a2                	ld	s1,8(sp)
    80000680:	6105                	addi	sp,sp,32
    80000682:	8082                	ret
    mycpu()->intena = old;
    80000684:	00000097          	auipc	ra,0x0
    80000688:	410080e7          	jalr	1040(ra) # 80000a94 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    8000068c:	8085                	srli	s1,s1,0x1
    8000068e:	8885                	andi	s1,s1,1
    80000690:	dd64                	sw	s1,124(a0)
    80000692:	bfe9                	j	8000066c <push_off+0x24>

0000000080000694 <acquire>:
{
    80000694:	1101                	addi	sp,sp,-32
    80000696:	ec06                	sd	ra,24(sp)
    80000698:	e822                	sd	s0,16(sp)
    8000069a:	e426                	sd	s1,8(sp)
    8000069c:	1000                	addi	s0,sp,32
    8000069e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	fa8080e7          	jalr	-88(ra) # 80000648 <push_off>
  if(holding(lk))
    800006a8:	8526                	mv	a0,s1
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	f70080e7          	jalr	-144(ra) # 8000061a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800006b2:	4705                	li	a4,1
  if(holding(lk))
    800006b4:	e115                	bnez	a0,800006d8 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800006b6:	87ba                	mv	a5,a4
    800006b8:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800006bc:	2781                	sext.w	a5,a5
    800006be:	ffe5                	bnez	a5,800006b6 <acquire+0x22>
  __sync_synchronize();
    800006c0:	0ff0000f          	fence
  lk->cpu = mycpu();
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	3d0080e7          	jalr	976(ra) # 80000a94 <mycpu>
    800006cc:	e888                	sd	a0,16(s1)
}
    800006ce:	60e2                	ld	ra,24(sp)
    800006d0:	6442                	ld	s0,16(sp)
    800006d2:	64a2                	ld	s1,8(sp)
    800006d4:	6105                	addi	sp,sp,32
    800006d6:	8082                	ret
    panic("acquire");
    800006d8:	00002517          	auipc	a0,0x2
    800006dc:	98850513          	addi	a0,a0,-1656 # 80002060 <digits+0x30>
    800006e0:	00000097          	auipc	ra,0x0
    800006e4:	ab2080e7          	jalr	-1358(ra) # 80000192 <panic>

00000000800006e8 <pop_off>:

void
pop_off(void)
{
    800006e8:	1141                	addi	sp,sp,-16
    800006ea:	e406                	sd	ra,8(sp)
    800006ec:	e022                	sd	s0,0(sp)
    800006ee:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	3a4080e7          	jalr	932(ra) # 80000a94 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800006f8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800006fc:	8b89                	andi	a5,a5,2
  if(intr_get())
    800006fe:	e78d                	bnez	a5,80000728 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000700:	5d3c                	lw	a5,120(a0)
    80000702:	02f05b63          	blez	a5,80000738 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000706:	37fd                	addiw	a5,a5,-1
    80000708:	0007871b          	sext.w	a4,a5
    8000070c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    8000070e:	eb09                	bnez	a4,80000720 <pop_off+0x38>
    80000710:	5d7c                	lw	a5,124(a0)
    80000712:	c799                	beqz	a5,80000720 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000714:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000718:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000071c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000720:	60a2                	ld	ra,8(sp)
    80000722:	6402                	ld	s0,0(sp)
    80000724:	0141                	addi	sp,sp,16
    80000726:	8082                	ret
    panic("pop_off - interruptible");
    80000728:	00002517          	auipc	a0,0x2
    8000072c:	94050513          	addi	a0,a0,-1728 # 80002068 <digits+0x38>
    80000730:	00000097          	auipc	ra,0x0
    80000734:	a62080e7          	jalr	-1438(ra) # 80000192 <panic>
    panic("pop_off");
    80000738:	00002517          	auipc	a0,0x2
    8000073c:	94850513          	addi	a0,a0,-1720 # 80002080 <digits+0x50>
    80000740:	00000097          	auipc	ra,0x0
    80000744:	a52080e7          	jalr	-1454(ra) # 80000192 <panic>

0000000080000748 <release>:
{
    80000748:	1101                	addi	sp,sp,-32
    8000074a:	ec06                	sd	ra,24(sp)
    8000074c:	e822                	sd	s0,16(sp)
    8000074e:	e426                	sd	s1,8(sp)
    80000750:	1000                	addi	s0,sp,32
    80000752:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000754:	00000097          	auipc	ra,0x0
    80000758:	ec6080e7          	jalr	-314(ra) # 8000061a <holding>
    8000075c:	c115                	beqz	a0,80000780 <release+0x38>
  lk->cpu = 0;
    8000075e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000762:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000766:	0f50000f          	fence	iorw,ow
    8000076a:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    8000076e:	00000097          	auipc	ra,0x0
    80000772:	f7a080e7          	jalr	-134(ra) # 800006e8 <pop_off>
}
    80000776:	60e2                	ld	ra,24(sp)
    80000778:	6442                	ld	s0,16(sp)
    8000077a:	64a2                	ld	s1,8(sp)
    8000077c:	6105                	addi	sp,sp,32
    8000077e:	8082                	ret
    panic("release");
    80000780:	00002517          	auipc	a0,0x2
    80000784:	90850513          	addi	a0,a0,-1784 # 80002088 <digits+0x58>
    80000788:	00000097          	auipc	ra,0x0
    8000078c:	a0a080e7          	jalr	-1526(ra) # 80000192 <panic>

0000000080000790 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000790:	1141                	addi	sp,sp,-16
    80000792:	e422                	sd	s0,8(sp)
    80000794:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000796:	ca19                	beqz	a2,800007ac <memset+0x1c>
    80000798:	87aa                	mv	a5,a0
    8000079a:	1602                	slli	a2,a2,0x20
    8000079c:	9201                	srli	a2,a2,0x20
    8000079e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    800007a2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800007a6:	0785                	addi	a5,a5,1
    800007a8:	fee79de3          	bne	a5,a4,800007a2 <memset+0x12>
  }
  return dst;
}
    800007ac:	6422                	ld	s0,8(sp)
    800007ae:	0141                	addi	sp,sp,16
    800007b0:	8082                	ret

00000000800007b2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800007b2:	1141                	addi	sp,sp,-16
    800007b4:	e422                	sd	s0,8(sp)
    800007b6:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800007b8:	ca05                	beqz	a2,800007e8 <memcmp+0x36>
    800007ba:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    800007be:	1682                	slli	a3,a3,0x20
    800007c0:	9281                	srli	a3,a3,0x20
    800007c2:	0685                	addi	a3,a3,1
    800007c4:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800007c6:	00054783          	lbu	a5,0(a0)
    800007ca:	0005c703          	lbu	a4,0(a1)
    800007ce:	00e79863          	bne	a5,a4,800007de <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800007d2:	0505                	addi	a0,a0,1
    800007d4:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800007d6:	fed518e3          	bne	a0,a3,800007c6 <memcmp+0x14>
  }

  return 0;
    800007da:	4501                	li	a0,0
    800007dc:	a019                	j	800007e2 <memcmp+0x30>
      return *s1 - *s2;
    800007de:	40e7853b          	subw	a0,a5,a4
}
    800007e2:	6422                	ld	s0,8(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret
  return 0;
    800007e8:	4501                	li	a0,0
    800007ea:	bfe5                	j	800007e2 <memcmp+0x30>

00000000800007ec <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800007ec:	1141                	addi	sp,sp,-16
    800007ee:	e422                	sd	s0,8(sp)
    800007f0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800007f2:	c205                	beqz	a2,80000812 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800007f4:	02a5e263          	bltu	a1,a0,80000818 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800007f8:	1602                	slli	a2,a2,0x20
    800007fa:	9201                	srli	a2,a2,0x20
    800007fc:	00c587b3          	add	a5,a1,a2
{
    80000800:	872a                	mv	a4,a0
      *d++ = *s++;
    80000802:	0585                	addi	a1,a1,1
    80000804:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffeecd1>
    80000806:	fff5c683          	lbu	a3,-1(a1)
    8000080a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    8000080e:	fef59ae3          	bne	a1,a5,80000802 <memmove+0x16>

  return dst;
}
    80000812:	6422                	ld	s0,8(sp)
    80000814:	0141                	addi	sp,sp,16
    80000816:	8082                	ret
  if(s < d && s + n > d){
    80000818:	02061693          	slli	a3,a2,0x20
    8000081c:	9281                	srli	a3,a3,0x20
    8000081e:	00d58733          	add	a4,a1,a3
    80000822:	fce57be3          	bgeu	a0,a4,800007f8 <memmove+0xc>
    d += n;
    80000826:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000828:	fff6079b          	addiw	a5,a2,-1
    8000082c:	1782                	slli	a5,a5,0x20
    8000082e:	9381                	srli	a5,a5,0x20
    80000830:	fff7c793          	not	a5,a5
    80000834:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000836:	177d                	addi	a4,a4,-1
    80000838:	16fd                	addi	a3,a3,-1
    8000083a:	00074603          	lbu	a2,0(a4)
    8000083e:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000842:	fee79ae3          	bne	a5,a4,80000836 <memmove+0x4a>
    80000846:	b7f1                	j	80000812 <memmove+0x26>

0000000080000848 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000848:	1141                	addi	sp,sp,-16
    8000084a:	e406                	sd	ra,8(sp)
    8000084c:	e022                	sd	s0,0(sp)
    8000084e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000850:	00000097          	auipc	ra,0x0
    80000854:	f9c080e7          	jalr	-100(ra) # 800007ec <memmove>
}
    80000858:	60a2                	ld	ra,8(sp)
    8000085a:	6402                	ld	s0,0(sp)
    8000085c:	0141                	addi	sp,sp,16
    8000085e:	8082                	ret

0000000080000860 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e422                	sd	s0,8(sp)
    80000864:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000866:	ce11                	beqz	a2,80000882 <strncmp+0x22>
    80000868:	00054783          	lbu	a5,0(a0)
    8000086c:	cf89                	beqz	a5,80000886 <strncmp+0x26>
    8000086e:	0005c703          	lbu	a4,0(a1)
    80000872:	00f71a63          	bne	a4,a5,80000886 <strncmp+0x26>
    n--, p++, q++;
    80000876:	367d                	addiw	a2,a2,-1
    80000878:	0505                	addi	a0,a0,1
    8000087a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000087c:	f675                	bnez	a2,80000868 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000087e:	4501                	li	a0,0
    80000880:	a809                	j	80000892 <strncmp+0x32>
    80000882:	4501                	li	a0,0
    80000884:	a039                	j	80000892 <strncmp+0x32>
  if(n == 0)
    80000886:	ca09                	beqz	a2,80000898 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000888:	00054503          	lbu	a0,0(a0)
    8000088c:	0005c783          	lbu	a5,0(a1)
    80000890:	9d1d                	subw	a0,a0,a5
}
    80000892:	6422                	ld	s0,8(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret
    return 0;
    80000898:	4501                	li	a0,0
    8000089a:	bfe5                	j	80000892 <strncmp+0x32>

000000008000089c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000089c:	1141                	addi	sp,sp,-16
    8000089e:	e422                	sd	s0,8(sp)
    800008a0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800008a2:	872a                	mv	a4,a0
    800008a4:	8832                	mv	a6,a2
    800008a6:	367d                	addiw	a2,a2,-1
    800008a8:	01005963          	blez	a6,800008ba <strncpy+0x1e>
    800008ac:	0705                	addi	a4,a4,1
    800008ae:	0005c783          	lbu	a5,0(a1)
    800008b2:	fef70fa3          	sb	a5,-1(a4)
    800008b6:	0585                	addi	a1,a1,1
    800008b8:	f7f5                	bnez	a5,800008a4 <strncpy+0x8>
    ;
  while(n-- > 0)
    800008ba:	86ba                	mv	a3,a4
    800008bc:	00c05c63          	blez	a2,800008d4 <strncpy+0x38>
    *s++ = 0;
    800008c0:	0685                	addi	a3,a3,1
    800008c2:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800008c6:	40d707bb          	subw	a5,a4,a3
    800008ca:	37fd                	addiw	a5,a5,-1
    800008cc:	010787bb          	addw	a5,a5,a6
    800008d0:	fef048e3          	bgtz	a5,800008c0 <strncpy+0x24>
  return os;
}
    800008d4:	6422                	ld	s0,8(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800008da:	1141                	addi	sp,sp,-16
    800008dc:	e422                	sd	s0,8(sp)
    800008de:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800008e0:	02c05363          	blez	a2,80000906 <safestrcpy+0x2c>
    800008e4:	fff6069b          	addiw	a3,a2,-1
    800008e8:	1682                	slli	a3,a3,0x20
    800008ea:	9281                	srli	a3,a3,0x20
    800008ec:	96ae                	add	a3,a3,a1
    800008ee:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800008f0:	00d58963          	beq	a1,a3,80000902 <safestrcpy+0x28>
    800008f4:	0585                	addi	a1,a1,1
    800008f6:	0785                	addi	a5,a5,1
    800008f8:	fff5c703          	lbu	a4,-1(a1)
    800008fc:	fee78fa3          	sb	a4,-1(a5)
    80000900:	fb65                	bnez	a4,800008f0 <safestrcpy+0x16>
    ;
  *s = 0;
    80000902:	00078023          	sb	zero,0(a5)
  return os;
}
    80000906:	6422                	ld	s0,8(sp)
    80000908:	0141                	addi	sp,sp,16
    8000090a:	8082                	ret

000000008000090c <strlen>:

int
strlen(const char *s)
{
    8000090c:	1141                	addi	sp,sp,-16
    8000090e:	e422                	sd	s0,8(sp)
    80000910:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000912:	00054783          	lbu	a5,0(a0)
    80000916:	cf91                	beqz	a5,80000932 <strlen+0x26>
    80000918:	0505                	addi	a0,a0,1
    8000091a:	87aa                	mv	a5,a0
    8000091c:	4685                	li	a3,1
    8000091e:	9e89                	subw	a3,a3,a0
    80000920:	00f6853b          	addw	a0,a3,a5
    80000924:	0785                	addi	a5,a5,1
    80000926:	fff7c703          	lbu	a4,-1(a5)
    8000092a:	fb7d                	bnez	a4,80000920 <strlen+0x14>
    ;
  return n;
}
    8000092c:	6422                	ld	s0,8(sp)
    8000092e:	0141                	addi	sp,sp,16
    80000930:	8082                	ret
  for(n = 0; s[n]; n++)
    80000932:	4501                	li	a0,0
    80000934:	bfe5                	j	8000092c <strlen+0x20>

0000000080000936 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000936:	1141                	addi	sp,sp,-16
    80000938:	e406                	sd	ra,8(sp)
    8000093a:	e022                	sd	s0,0(sp)
    8000093c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000093e:	00000097          	auipc	ra,0x0
    80000942:	146080e7          	jalr	326(ra) # 80000a84 <cpuid>
    procinit();      // process table
    userinit();
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000946:	00002717          	auipc	a4,0x2
    8000094a:	94270713          	addi	a4,a4,-1726 # 80002288 <started>
  if(cpuid() == 0){
    8000094e:	c51d                	beqz	a0,8000097c <main+0x46>
    while(started == 0)
    80000950:	431c                	lw	a5,0(a4)
    80000952:	2781                	sext.w	a5,a5
    80000954:	dff5                	beqz	a5,80000950 <main+0x1a>
      ;
    __sync_synchronize();
    80000956:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	12a080e7          	jalr	298(ra) # 80000a84 <cpuid>
    80000962:	85aa                	mv	a1,a0
    80000964:	00001517          	auipc	a0,0x1
    80000968:	74450513          	addi	a0,a0,1860 # 800020a8 <digits+0x78>
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	870080e7          	jalr	-1936(ra) # 800001dc <printf>
  }

  scheduler();        
    80000974:	00000097          	auipc	ra,0x0
    80000978:	346080e7          	jalr	838(ra) # 80000cba <scheduler>
    consoleinit();
    8000097c:	fffff097          	auipc	ra,0xfffff
    80000980:	74a080e7          	jalr	1866(ra) # 800000c6 <consoleinit>
    printfinit();
    80000984:	00000097          	auipc	ra,0x0
    80000988:	a38080e7          	jalr	-1480(ra) # 800003bc <printfinit>
    printf("\n");
    8000098c:	00001517          	auipc	a0,0x1
    80000990:	72c50513          	addi	a0,a0,1836 # 800020b8 <digits+0x88>
    80000994:	00000097          	auipc	ra,0x0
    80000998:	848080e7          	jalr	-1976(ra) # 800001dc <printf>
    printf("xv6 kernel is booting\n");
    8000099c:	00001517          	auipc	a0,0x1
    800009a0:	6f450513          	addi	a0,a0,1780 # 80002090 <digits+0x60>
    800009a4:	00000097          	auipc	ra,0x0
    800009a8:	838080e7          	jalr	-1992(ra) # 800001dc <printf>
    printf("\n");
    800009ac:	00001517          	auipc	a0,0x1
    800009b0:	70c50513          	addi	a0,a0,1804 # 800020b8 <digits+0x88>
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	828080e7          	jalr	-2008(ra) # 800001dc <printf>
    kinit();         // physical page allocator
    800009bc:	00000097          	auipc	ra,0x0
    800009c0:	bac080e7          	jalr	-1108(ra) # 80000568 <kinit>
    procinit();      // process table
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	020080e7          	jalr	32(ra) # 800009e4 <procinit>
    userinit();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	540080e7          	jalr	1344(ra) # 80000f0c <userinit>
    __sync_synchronize();
    800009d4:	0ff0000f          	fence
    started = 1;
    800009d8:	4785                	li	a5,1
    800009da:	00002717          	auipc	a4,0x2
    800009de:	8af72723          	sw	a5,-1874(a4) # 80002288 <started>
    800009e2:	bf49                	j	80000974 <main+0x3e>

00000000800009e4 <procinit>:
// guard page.
void

// initialize the proc table.
procinit(void)
{
    800009e4:	7179                	addi	sp,sp,-48
    800009e6:	f406                	sd	ra,40(sp)
    800009e8:	f022                	sd	s0,32(sp)
    800009ea:	ec26                	sd	s1,24(sp)
    800009ec:	e84a                	sd	s2,16(sp)
    800009ee:	e44e                	sd	s3,8(sp)
    800009f0:	e052                	sd	s4,0(sp)
    800009f2:	1800                	addi	s0,sp,48
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800009f4:	00001597          	auipc	a1,0x1
    800009f8:	6cc58593          	addi	a1,a1,1740 # 800020c0 <digits+0x90>
    800009fc:	0000a517          	auipc	a0,0xa
    80000a00:	b0450513          	addi	a0,a0,-1276 # 8000a500 <pid_lock>
    80000a04:	00000097          	auipc	ra,0x0
    80000a08:	c00080e7          	jalr	-1024(ra) # 80000604 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000a0c:	00001597          	auipc	a1,0x1
    80000a10:	6bc58593          	addi	a1,a1,1724 # 800020c8 <digits+0x98>
    80000a14:	0000a517          	auipc	a0,0xa
    80000a18:	b0450513          	addi	a0,a0,-1276 # 8000a518 <wait_lock>
    80000a1c:	00000097          	auipc	ra,0x0
    80000a20:	be8080e7          	jalr	-1048(ra) # 80000604 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000a24:	0000a497          	auipc	s1,0xa
    80000a28:	f0c48493          	addi	s1,s1,-244 # 8000a930 <proc>
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      initlock(&p->lock, "proc");
    80000a2c:	00001a17          	auipc	s4,0x1
    80000a30:	6b4a0a13          	addi	s4,s4,1716 # 800020e0 <digits+0xb0>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000a34:	00010997          	auipc	s3,0x10
    80000a38:	8fc98993          	addi	s3,s3,-1796 # 80010330 <end>
      char *pa = kalloc();
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	b68080e7          	jalr	-1176(ra) # 800005a4 <kalloc>
    80000a44:	892a                	mv	s2,a0
      if(pa == 0)
    80000a46:	c51d                	beqz	a0,80000a74 <procinit+0x90>
      initlock(&p->lock, "proc");
    80000a48:	85d2                	mv	a1,s4
    80000a4a:	8526                	mv	a0,s1
    80000a4c:	00000097          	auipc	ra,0x0
    80000a50:	bb8080e7          	jalr	-1096(ra) # 80000604 <initlock>
      p->state = UNUSED;
    80000a54:	0004ac23          	sw	zero,24(s1)
      p->kstack = (uint64)pa;
    80000a58:	0524b023          	sd	s2,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000a5c:	16848493          	addi	s1,s1,360
    80000a60:	fd349ee3          	bne	s1,s3,80000a3c <procinit+0x58>
  }
}
    80000a64:	70a2                	ld	ra,40(sp)
    80000a66:	7402                	ld	s0,32(sp)
    80000a68:	64e2                	ld	s1,24(sp)
    80000a6a:	6942                	ld	s2,16(sp)
    80000a6c:	69a2                	ld	s3,8(sp)
    80000a6e:	6a02                	ld	s4,0(sp)
    80000a70:	6145                	addi	sp,sp,48
    80000a72:	8082                	ret
        panic("kalloc");
    80000a74:	00001517          	auipc	a0,0x1
    80000a78:	66450513          	addi	a0,a0,1636 # 800020d8 <digits+0xa8>
    80000a7c:	fffff097          	auipc	ra,0xfffff
    80000a80:	716080e7          	jalr	1814(ra) # 80000192 <panic>

0000000080000a84 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000a84:	1141                	addi	sp,sp,-16
    80000a86:	e422                	sd	s0,8(sp)
    80000a88:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000a8a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000a8c:	2501                	sext.w	a0,a0
    80000a8e:	6422                	ld	s0,8(sp)
    80000a90:	0141                	addi	sp,sp,16
    80000a92:	8082                	ret

0000000080000a94 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000a94:	1141                	addi	sp,sp,-16
    80000a96:	e422                	sd	s0,8(sp)
    80000a98:	0800                	addi	s0,sp,16
    80000a9a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000a9c:	2781                	sext.w	a5,a5
    80000a9e:	079e                	slli	a5,a5,0x7
  return c;
}
    80000aa0:	0000a517          	auipc	a0,0xa
    80000aa4:	a9050513          	addi	a0,a0,-1392 # 8000a530 <cpus>
    80000aa8:	953e                	add	a0,a0,a5
    80000aaa:	6422                	ld	s0,8(sp)
    80000aac:	0141                	addi	sp,sp,16
    80000aae:	8082                	ret

0000000080000ab0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000ab0:	1101                	addi	sp,sp,-32
    80000ab2:	ec06                	sd	ra,24(sp)
    80000ab4:	e822                	sd	s0,16(sp)
    80000ab6:	e426                	sd	s1,8(sp)
    80000ab8:	1000                	addi	s0,sp,32
  push_off();
    80000aba:	00000097          	auipc	ra,0x0
    80000abe:	b8e080e7          	jalr	-1138(ra) # 80000648 <push_off>
    80000ac2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000ac4:	2781                	sext.w	a5,a5
    80000ac6:	079e                	slli	a5,a5,0x7
    80000ac8:	0000a717          	auipc	a4,0xa
    80000acc:	a3870713          	addi	a4,a4,-1480 # 8000a500 <pid_lock>
    80000ad0:	97ba                	add	a5,a5,a4
    80000ad2:	7b84                	ld	s1,48(a5)
  pop_off();
    80000ad4:	00000097          	auipc	ra,0x0
    80000ad8:	c14080e7          	jalr	-1004(ra) # 800006e8 <pop_off>
  return p;
}
    80000adc:	8526                	mv	a0,s1
    80000ade:	60e2                	ld	ra,24(sp)
    80000ae0:	6442                	ld	s0,16(sp)
    80000ae2:	64a2                	ld	s1,8(sp)
    80000ae4:	6105                	addi	sp,sp,32
    80000ae6:	8082                	ret

0000000080000ae8 <allocpid>:

int
allocpid()
{
    80000ae8:	1101                	addi	sp,sp,-32
    80000aea:	ec06                	sd	ra,24(sp)
    80000aec:	e822                	sd	s0,16(sp)
    80000aee:	e426                	sd	s1,8(sp)
    80000af0:	e04a                	sd	s2,0(sp)
    80000af2:	1000                	addi	s0,sp,32
  int pid;
  
  acquire(&pid_lock);
    80000af4:	0000a917          	auipc	s2,0xa
    80000af8:	a0c90913          	addi	s2,s2,-1524 # 8000a500 <pid_lock>
    80000afc:	854a                	mv	a0,s2
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	b96080e7          	jalr	-1130(ra) # 80000694 <acquire>
  pid = nextpid;
    80000b06:	00001797          	auipc	a5,0x1
    80000b0a:	6fa78793          	addi	a5,a5,1786 # 80002200 <nextpid>
    80000b0e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000b10:	0014871b          	addiw	a4,s1,1
    80000b14:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000b16:	854a                	mv	a0,s2
    80000b18:	00000097          	auipc	ra,0x0
    80000b1c:	c30080e7          	jalr	-976(ra) # 80000748 <release>

  return pid;
}
    80000b20:	8526                	mv	a0,s1
    80000b22:	60e2                	ld	ra,24(sp)
    80000b24:	6442                	ld	s0,16(sp)
    80000b26:	64a2                	ld	s1,8(sp)
    80000b28:	6902                	ld	s2,0(sp)
    80000b2a:	6105                	addi	sp,sp,32
    80000b2c:	8082                	ret

0000000080000b2e <allocproc>:
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
    80000b2e:	1101                	addi	sp,sp,-32
    80000b30:	ec06                	sd	ra,24(sp)
    80000b32:	e822                	sd	s0,16(sp)
    80000b34:	e426                	sd	s1,8(sp)
    80000b36:	e04a                	sd	s2,0(sp)
    80000b38:	1000                	addi	s0,sp,32
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    80000b3a:	0000a497          	auipc	s1,0xa
    80000b3e:	df648493          	addi	s1,s1,-522 # 8000a930 <proc>
    80000b42:	0000f917          	auipc	s2,0xf
    80000b46:	7ee90913          	addi	s2,s2,2030 # 80010330 <end>
    acquire(&p->lock);
    80000b4a:	8526                	mv	a0,s1
    80000b4c:	00000097          	auipc	ra,0x0
    80000b50:	b48080e7          	jalr	-1208(ra) # 80000694 <acquire>
    if(p->state == UNUSED) {
    80000b54:	4c9c                	lw	a5,24(s1)
    80000b56:	cf81                	beqz	a5,80000b6e <allocproc+0x40>
      goto found;
    } else {
      release(&p->lock);
    80000b58:	8526                	mv	a0,s1
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	bee080e7          	jalr	-1042(ra) # 80000748 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000b62:	16848493          	addi	s1,s1,360
    80000b66:	ff2492e3          	bne	s1,s2,80000b4a <allocproc+0x1c>
    }
  }
  return 0;
    80000b6a:	4481                	li	s1,0
    80000b6c:	a815                	j	80000ba0 <allocproc+0x72>

found:
  p->pid = allocpid();
    80000b6e:	00000097          	auipc	ra,0x0
    80000b72:	f7a080e7          	jalr	-134(ra) # 80000ae8 <allocpid>
    80000b76:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000b78:	4785                	li	a5,1
    80000b7a:	cc9c                	sw	a5,24(s1)

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
    80000b7c:	07000613          	li	a2,112
    80000b80:	4581                	li	a1,0
    80000b82:	06048513          	addi	a0,s1,96
    80000b86:	00000097          	auipc	ra,0x0
    80000b8a:	c0a080e7          	jalr	-1014(ra) # 80000790 <memset>
  p->context.ra = (uint64)forkret;
    80000b8e:	00000797          	auipc	a5,0x0
    80000b92:	35e78793          	addi	a5,a5,862 # 80000eec <forkret>
    80000b96:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80000b98:	60bc                	ld	a5,64(s1)
    80000b9a:	6705                	lui	a4,0x1
    80000b9c:	97ba                	add	a5,a5,a4
    80000b9e:	f4bc                	sd	a5,104(s1)

  return p;
}
    80000ba0:	8526                	mv	a0,s1
    80000ba2:	60e2                	ld	ra,24(sp)
    80000ba4:	6442                	ld	s0,16(sp)
    80000ba6:	64a2                	ld	s1,8(sp)
    80000ba8:	6902                	ld	s2,0(sp)
    80000baa:	6105                	addi	sp,sp,32
    80000bac:	8082                	ret

0000000080000bae <growproc>:

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
    80000bae:	1141                	addi	sp,sp,-16
    80000bb0:	e406                	sd	ra,8(sp)
    80000bb2:	e022                	sd	s0,0(sp)
    80000bb4:	0800                	addi	s0,sp,16
  uint64 sz;
  struct proc *p = myproc();
    80000bb6:	00000097          	auipc	ra,0x0
    80000bba:	efa080e7          	jalr	-262(ra) # 80000ab0 <myproc>

  sz = p->sz;
  p->sz = sz;
  return 0;
}
    80000bbe:	4501                	li	a0,0
    80000bc0:	60a2                	ld	ra,8(sp)
    80000bc2:	6402                	ld	s0,0(sp)
    80000bc4:	0141                	addi	sp,sp,16
    80000bc6:	8082                	ret

0000000080000bc8 <fork>:

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
    80000bc8:	7139                	addi	sp,sp,-64
    80000bca:	fc06                	sd	ra,56(sp)
    80000bcc:	f822                	sd	s0,48(sp)
    80000bce:	f426                	sd	s1,40(sp)
    80000bd0:	f04a                	sd	s2,32(sp)
    80000bd2:	ec4e                	sd	s3,24(sp)
    80000bd4:	e852                	sd	s4,16(sp)
    80000bd6:	e456                	sd	s5,8(sp)
    80000bd8:	e05a                	sd	s6,0(sp)
    80000bda:	0080                	addi	s0,sp,64
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	ed4080e7          	jalr	-300(ra) # 80000ab0 <myproc>
    80000be4:	8b2a                	mv	s6,a0

  // Allocate process.
  if((np = allocproc()) == 0){
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	f48080e7          	jalr	-184(ra) # 80000b2e <allocproc>
    80000bee:	c561                	beqz	a0,80000cb6 <fork+0xee>
    80000bf0:	89aa                	mv	s3,a0
    return -1;
  }

  // Copy user memory from parent to child.
  np->sz = p->sz;
    80000bf2:	048b3783          	ld	a5,72(s6)
    80000bf6:	e53c                	sd	a5,72(a0)

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);
    80000bf8:	058b3683          	ld	a3,88(s6)
    80000bfc:	87b6                	mv	a5,a3
    80000bfe:	6d38                	ld	a4,88(a0)
    80000c00:	12068693          	addi	a3,a3,288
    80000c04:	0007b803          	ld	a6,0(a5)
    80000c08:	6788                	ld	a0,8(a5)
    80000c0a:	6b8c                	ld	a1,16(a5)
    80000c0c:	6f90                	ld	a2,24(a5)
    80000c0e:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80000c12:	e708                	sd	a0,8(a4)
    80000c14:	eb0c                	sd	a1,16(a4)
    80000c16:	ef10                	sd	a2,24(a4)
    80000c18:	02078793          	addi	a5,a5,32
    80000c1c:	02070713          	addi	a4,a4,32
    80000c20:	fed792e3          	bne	a5,a3,80000c04 <fork+0x3c>

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;
    80000c24:	0589b783          	ld	a5,88(s3)
    80000c28:	0607b823          	sd	zero,112(a5)

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    80000c2c:	0d0b0493          	addi	s1,s6,208
    80000c30:	150b0913          	addi	s2,s6,336
    if(p->ofile[i])

  safestrcpy(np->name, p->name, sizeof(p->name));
    80000c34:	158b0a93          	addi	s5,s6,344
    80000c38:	15898a13          	addi	s4,s3,344
    80000c3c:	a021                	j	80000c44 <fork+0x7c>
  for(i = 0; i < NOFILE; i++)
    80000c3e:	04a1                	addi	s1,s1,8
    80000c40:	01248c63          	beq	s1,s2,80000c58 <fork+0x90>
    if(p->ofile[i])
    80000c44:	609c                	ld	a5,0(s1)
    80000c46:	dfe5                	beqz	a5,80000c3e <fork+0x76>
  safestrcpy(np->name, p->name, sizeof(p->name));
    80000c48:	4641                	li	a2,16
    80000c4a:	85d6                	mv	a1,s5
    80000c4c:	8552                	mv	a0,s4
    80000c4e:	00000097          	auipc	ra,0x0
    80000c52:	c8c080e7          	jalr	-884(ra) # 800008da <safestrcpy>
    80000c56:	b7e5                	j	80000c3e <fork+0x76>

  pid = np->pid;
    80000c58:	0309a903          	lw	s2,48(s3)

  release(&np->lock);
    80000c5c:	854e                	mv	a0,s3
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	aea080e7          	jalr	-1302(ra) # 80000748 <release>

  acquire(&wait_lock);
    80000c66:	0000a497          	auipc	s1,0xa
    80000c6a:	8b248493          	addi	s1,s1,-1870 # 8000a518 <wait_lock>
    80000c6e:	8526                	mv	a0,s1
    80000c70:	00000097          	auipc	ra,0x0
    80000c74:	a24080e7          	jalr	-1500(ra) # 80000694 <acquire>
  np->parent = p;
    80000c78:	0369bc23          	sd	s6,56(s3)
  release(&wait_lock);
    80000c7c:	8526                	mv	a0,s1
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	aca080e7          	jalr	-1334(ra) # 80000748 <release>

  acquire(&np->lock);
    80000c86:	854e                	mv	a0,s3
    80000c88:	00000097          	auipc	ra,0x0
    80000c8c:	a0c080e7          	jalr	-1524(ra) # 80000694 <acquire>
  np->state = RUNNABLE;
    80000c90:	478d                	li	a5,3
    80000c92:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80000c96:	854e                	mv	a0,s3
    80000c98:	00000097          	auipc	ra,0x0
    80000c9c:	ab0080e7          	jalr	-1360(ra) # 80000748 <release>
  
  return pid;
}
    80000ca0:	854a                	mv	a0,s2
    80000ca2:	70e2                	ld	ra,56(sp)
    80000ca4:	7442                	ld	s0,48(sp)
    80000ca6:	74a2                	ld	s1,40(sp)
    80000ca8:	7902                	ld	s2,32(sp)
    80000caa:	69e2                	ld	s3,24(sp)
    80000cac:	6a42                	ld	s4,16(sp)
    80000cae:	6aa2                	ld	s5,8(sp)
    80000cb0:	6b02                	ld	s6,0(sp)
    80000cb2:	6121                	addi	sp,sp,64
    80000cb4:	8082                	ret
    return -1;
    80000cb6:	597d                	li	s2,-1
    80000cb8:	b7e5                	j	80000ca0 <fork+0xd8>

0000000080000cba <scheduler>:
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
    80000cba:	7139                	addi	sp,sp,-64
    80000cbc:	fc06                	sd	ra,56(sp)
    80000cbe:	f822                	sd	s0,48(sp)
    80000cc0:	f426                	sd	s1,40(sp)
    80000cc2:	f04a                	sd	s2,32(sp)
    80000cc4:	ec4e                	sd	s3,24(sp)
    80000cc6:	e852                	sd	s4,16(sp)
    80000cc8:	e456                	sd	s5,8(sp)
    80000cca:	e05a                	sd	s6,0(sp)
    80000ccc:	0080                	addi	s0,sp,64
    80000cce:	8792                	mv	a5,tp
  int id = r_tp();
    80000cd0:	2781                	sext.w	a5,a5
  struct proc *p;
  struct proc *m;
  struct cpu *c = mycpu();
  
  c->proc = 0;
    80000cd2:	00779a93          	slli	s5,a5,0x7
    80000cd6:	0000a717          	auipc	a4,0xa
    80000cda:	82a70713          	addi	a4,a4,-2006 # 8000a500 <pid_lock>
    80000cde:	9756                	add	a4,a4,s5
    80000ce0:	02073823          	sd	zero,48(a4)
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);
    80000ce4:	0000a717          	auipc	a4,0xa
    80000ce8:	85470713          	addi	a4,a4,-1964 # 8000a538 <cpus+0x8>
    80000cec:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80000cee:	498d                	li	s3,3
        p->state = RUNNING;
    80000cf0:	4b11                	li	s6,4
        c->proc = p;
    80000cf2:	079e                	slli	a5,a5,0x7
    80000cf4:	0000aa17          	auipc	s4,0xa
    80000cf8:	80ca0a13          	addi	s4,s4,-2036 # 8000a500 <pid_lock>
    80000cfc:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80000cfe:	0000f917          	auipc	s2,0xf
    80000d02:	63290913          	addi	s2,s2,1586 # 80010330 <end>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d06:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d0a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d0e:	10079073          	csrw	sstatus,a5
    80000d12:	0000a497          	auipc	s1,0xa
    80000d16:	c1e48493          	addi	s1,s1,-994 # 8000a930 <proc>
    80000d1a:	a811                	j	80000d2e <scheduler+0x74>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
      }
      release(&p->lock);
    80000d1c:	8526                	mv	a0,s1
    80000d1e:	00000097          	auipc	ra,0x0
    80000d22:	a2a080e7          	jalr	-1494(ra) # 80000748 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80000d26:	16848493          	addi	s1,s1,360
    80000d2a:	03248863          	beq	s1,s2,80000d5a <scheduler+0xa0>
      acquire(&p->lock);
    80000d2e:	8526                	mv	a0,s1
    80000d30:	00000097          	auipc	ra,0x0
    80000d34:	964080e7          	jalr	-1692(ra) # 80000694 <acquire>
      if(p->state == RUNNABLE) {
    80000d38:	4c9c                	lw	a5,24(s1)
    80000d3a:	ff3791e3          	bne	a5,s3,80000d1c <scheduler+0x62>
        p->state = RUNNING;
    80000d3e:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80000d42:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80000d46:	06048593          	addi	a1,s1,96
    80000d4a:	8556                	mv	a0,s5
    80000d4c:	00000097          	auipc	ra,0x0
    80000d50:	67a080e7          	jalr	1658(ra) # 800013c6 <swtch>
        c->proc = 0;
    80000d54:	020a3823          	sd	zero,48(s4)
    80000d58:	b7d1                	j	80000d1c <scheduler+0x62>
    }
    for(m = proc; m < &proc[NPROC]; m++) {
    80000d5a:	0000a497          	auipc	s1,0xa
    80000d5e:	bd648493          	addi	s1,s1,-1066 # 8000a930 <proc>
    80000d62:	a811                	j	80000d76 <scheduler+0xbc>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
      }
      release(&m->lock);
    80000d64:	8526                	mv	a0,s1
    80000d66:	00000097          	auipc	ra,0x0
    80000d6a:	9e2080e7          	jalr	-1566(ra) # 80000748 <release>
    for(m = proc; m < &proc[NPROC]; m++) {
    80000d6e:	16848493          	addi	s1,s1,360
    80000d72:	f9248ae3          	beq	s1,s2,80000d06 <scheduler+0x4c>
      acquire(&m->lock);
    80000d76:	8526                	mv	a0,s1
    80000d78:	00000097          	auipc	ra,0x0
    80000d7c:	91c080e7          	jalr	-1764(ra) # 80000694 <acquire>
      if(m->state == RUNNABLE) {
    80000d80:	4c9c                	lw	a5,24(s1)
    80000d82:	ff3791e3          	bne	a5,s3,80000d64 <scheduler+0xaa>
        m->state = RUNNING;
    80000d86:	0164ac23          	sw	s6,24(s1)
        c->proc = m;
    80000d8a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &m->context);
    80000d8e:	06048593          	addi	a1,s1,96
    80000d92:	8556                	mv	a0,s5
    80000d94:	00000097          	auipc	ra,0x0
    80000d98:	632080e7          	jalr	1586(ra) # 800013c6 <swtch>
        c->proc = 0;
    80000d9c:	020a3823          	sd	zero,48(s4)
    80000da0:	b7d1                	j	80000d64 <scheduler+0xaa>

0000000080000da2 <sched>:
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
    80000da2:	7179                	addi	sp,sp,-48
    80000da4:	f406                	sd	ra,40(sp)
    80000da6:	f022                	sd	s0,32(sp)
    80000da8:	ec26                	sd	s1,24(sp)
    80000daa:	e84a                	sd	s2,16(sp)
    80000dac:	e44e                	sd	s3,8(sp)
    80000dae:	1800                	addi	s0,sp,48
  int intena;
  struct proc *p = myproc();
    80000db0:	00000097          	auipc	ra,0x0
    80000db4:	d00080e7          	jalr	-768(ra) # 80000ab0 <myproc>
    80000db8:	84aa                	mv	s1,a0

  if(!holding(&p->lock))
    80000dba:	00000097          	auipc	ra,0x0
    80000dbe:	860080e7          	jalr	-1952(ra) # 8000061a <holding>
    80000dc2:	c93d                	beqz	a0,80000e38 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80000dc4:	8792                	mv	a5,tp
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    80000dc6:	2781                	sext.w	a5,a5
    80000dc8:	079e                	slli	a5,a5,0x7
    80000dca:	00009717          	auipc	a4,0x9
    80000dce:	73670713          	addi	a4,a4,1846 # 8000a500 <pid_lock>
    80000dd2:	97ba                	add	a5,a5,a4
    80000dd4:	0a87a703          	lw	a4,168(a5)
    80000dd8:	4785                	li	a5,1
    80000dda:	06f71763          	bne	a4,a5,80000e48 <sched+0xa6>
    panic("sched locks");
  if(p->state == RUNNING)
    80000dde:	4c98                	lw	a4,24(s1)
    80000de0:	4791                	li	a5,4
    80000de2:	06f70b63          	beq	a4,a5,80000e58 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000de6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000dea:	8b89                	andi	a5,a5,2
    panic("sched running");
  if(intr_get())
    80000dec:	efb5                	bnez	a5,80000e68 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80000dee:	8792                	mv	a5,tp
    panic("sched interruptible");

  intena = mycpu()->intena;
    80000df0:	00009917          	auipc	s2,0x9
    80000df4:	71090913          	addi	s2,s2,1808 # 8000a500 <pid_lock>
    80000df8:	2781                	sext.w	a5,a5
    80000dfa:	079e                	slli	a5,a5,0x7
    80000dfc:	97ca                	add	a5,a5,s2
    80000dfe:	0ac7a983          	lw	s3,172(a5)
    80000e02:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80000e04:	2781                	sext.w	a5,a5
    80000e06:	079e                	slli	a5,a5,0x7
    80000e08:	00009597          	auipc	a1,0x9
    80000e0c:	73058593          	addi	a1,a1,1840 # 8000a538 <cpus+0x8>
    80000e10:	95be                	add	a1,a1,a5
    80000e12:	06048513          	addi	a0,s1,96
    80000e16:	00000097          	auipc	ra,0x0
    80000e1a:	5b0080e7          	jalr	1456(ra) # 800013c6 <swtch>
    80000e1e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80000e20:	2781                	sext.w	a5,a5
    80000e22:	079e                	slli	a5,a5,0x7
    80000e24:	993e                	add	s2,s2,a5
    80000e26:	0b392623          	sw	s3,172(s2)
}
    80000e2a:	70a2                	ld	ra,40(sp)
    80000e2c:	7402                	ld	s0,32(sp)
    80000e2e:	64e2                	ld	s1,24(sp)
    80000e30:	6942                	ld	s2,16(sp)
    80000e32:	69a2                	ld	s3,8(sp)
    80000e34:	6145                	addi	sp,sp,48
    80000e36:	8082                	ret
    panic("sched p->lock");
    80000e38:	00001517          	auipc	a0,0x1
    80000e3c:	2b050513          	addi	a0,a0,688 # 800020e8 <digits+0xb8>
    80000e40:	fffff097          	auipc	ra,0xfffff
    80000e44:	352080e7          	jalr	850(ra) # 80000192 <panic>
    panic("sched locks");
    80000e48:	00001517          	auipc	a0,0x1
    80000e4c:	2b050513          	addi	a0,a0,688 # 800020f8 <digits+0xc8>
    80000e50:	fffff097          	auipc	ra,0xfffff
    80000e54:	342080e7          	jalr	834(ra) # 80000192 <panic>
    panic("sched running");
    80000e58:	00001517          	auipc	a0,0x1
    80000e5c:	2b050513          	addi	a0,a0,688 # 80002108 <digits+0xd8>
    80000e60:	fffff097          	auipc	ra,0xfffff
    80000e64:	332080e7          	jalr	818(ra) # 80000192 <panic>
    panic("sched interruptible");
    80000e68:	00001517          	auipc	a0,0x1
    80000e6c:	2b050513          	addi	a0,a0,688 # 80002118 <digits+0xe8>
    80000e70:	fffff097          	auipc	ra,0xfffff
    80000e74:	322080e7          	jalr	802(ra) # 80000192 <panic>

0000000080000e78 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
    80000e78:	1101                	addi	sp,sp,-32
    80000e7a:	ec06                	sd	ra,24(sp)
    80000e7c:	e822                	sd	s0,16(sp)
    80000e7e:	e426                	sd	s1,8(sp)
    80000e80:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80000e82:	00000097          	auipc	ra,0x0
    80000e86:	c2e080e7          	jalr	-978(ra) # 80000ab0 <myproc>
    80000e8a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80000e8c:	00000097          	auipc	ra,0x0
    80000e90:	808080e7          	jalr	-2040(ra) # 80000694 <acquire>
  p->state = RUNNABLE;
    80000e94:	478d                	li	a5,3
    80000e96:	cc9c                	sw	a5,24(s1)
  sched();
    80000e98:	00000097          	auipc	ra,0x0
    80000e9c:	f0a080e7          	jalr	-246(ra) # 80000da2 <sched>
  release(&p->lock);
    80000ea0:	8526                	mv	a0,s1
    80000ea2:	00000097          	auipc	ra,0x0
    80000ea6:	8a6080e7          	jalr	-1882(ra) # 80000748 <release>
}
    80000eaa:	60e2                	ld	ra,24(sp)
    80000eac:	6442                	ld	s0,16(sp)
    80000eae:	64a2                	ld	s1,8(sp)
    80000eb0:	6105                	addi	sp,sp,32
    80000eb2:	8082                	ret

0000000080000eb4 <do_my_bidding>:
{
    80000eb4:	1101                	addi	sp,sp,-32
    80000eb6:	ec06                	sd	ra,24(sp)
    80000eb8:	e822                	sd	s0,16(sp)
    80000eba:	e426                	sd	s1,8(sp)
    80000ebc:	e04a                	sd	s2,0(sp)
    80000ebe:	1000                	addi	s0,sp,32
    printf("Running proc %d on cpu %d\n", proc->pid, cid);                                            
    80000ec0:	00001917          	auipc	s2,0x1
    80000ec4:	27090913          	addi	s2,s2,624 # 80002130 <digits+0x100>
    80000ec8:	8492                	mv	s1,tp
    struct proc *proc = myproc();                                                                     
    80000eca:	00000097          	auipc	ra,0x0
    80000ece:	be6080e7          	jalr	-1050(ra) # 80000ab0 <myproc>
    printf("Running proc %d on cpu %d\n", proc->pid, cid);                                            
    80000ed2:	0004861b          	sext.w	a2,s1
    80000ed6:	590c                	lw	a1,48(a0)
    80000ed8:	854a                	mv	a0,s2
    80000eda:	fffff097          	auipc	ra,0xfffff
    80000ede:	302080e7          	jalr	770(ra) # 800001dc <printf>
    yield();                                                                                          
    80000ee2:	00000097          	auipc	ra,0x0
    80000ee6:	f96080e7          	jalr	-106(ra) # 80000e78 <yield>
  for (;;) {
    80000eea:	bff9                	j	80000ec8 <do_my_bidding+0x14>

0000000080000eec <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000eec:	1141                	addi	sp,sp,-16
    80000eee:	e406                	sd	ra,8(sp)
    80000ef0:	e022                	sd	s0,0(sp)
    80000ef2:	0800                	addi	s0,sp,16
  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	bbc080e7          	jalr	-1092(ra) # 80000ab0 <myproc>
    80000efc:	00000097          	auipc	ra,0x0
    80000f00:	84c080e7          	jalr	-1972(ra) # 80000748 <release>

  do_my_bidding();
    80000f04:	00000097          	auipc	ra,0x0
    80000f08:	fb0080e7          	jalr	-80(ra) # 80000eb4 <do_my_bidding>

0000000080000f0c <userinit>:
}

// Should be a loop that jus calls allocproc
void
userinit(void)
{
    80000f0c:	7139                	addi	sp,sp,-64
    80000f0e:	fc06                	sd	ra,56(sp)
    80000f10:	f822                	sd	s0,48(sp)
    80000f12:	f426                	sd	s1,40(sp)
    80000f14:	f04a                	sd	s2,32(sp)
    80000f16:	ec4e                	sd	s3,24(sp)
    80000f18:	e852                	sd	s4,16(sp)
    80000f1a:	e456                	sd	s5,8(sp)
    80000f1c:	0080                	addi	s0,sp,64
    80000f1e:	4935                	li	s2,13
  struct proc *p;
  for(int i = 0; i < 13; i++) {
    p = allocproc();
    initproc = p;
    80000f20:	00001a97          	auipc	s5,0x1
    80000f24:	370a8a93          	addi	s5,s5,880 # 80002290 <initproc>
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80000f28:	00001a17          	auipc	s4,0x1
    80000f2c:	228a0a13          	addi	s4,s4,552 # 80002150 <digits+0x120>
    p->state = RUNNABLE;
    80000f30:	498d                	li	s3,3
    p = allocproc();
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	bfc080e7          	jalr	-1028(ra) # 80000b2e <allocproc>
    80000f3a:	84aa                	mv	s1,a0
    initproc = p;
    80000f3c:	00aab023          	sd	a0,0(s5)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80000f40:	4641                	li	a2,16
    80000f42:	85d2                	mv	a1,s4
    80000f44:	15850513          	addi	a0,a0,344
    80000f48:	00000097          	auipc	ra,0x0
    80000f4c:	992080e7          	jalr	-1646(ra) # 800008da <safestrcpy>
    p->state = RUNNABLE;
    80000f50:	0134ac23          	sw	s3,24(s1)
    release(&p->lock);
    80000f54:	8526                	mv	a0,s1
    80000f56:	fffff097          	auipc	ra,0xfffff
    80000f5a:	7f2080e7          	jalr	2034(ra) # 80000748 <release>
  for(int i = 0; i < 13; i++) {
    80000f5e:	397d                	addiw	s2,s2,-1
    80000f60:	fc0919e3          	bnez	s2,80000f32 <userinit+0x26>
  }
}
    80000f64:	70e2                	ld	ra,56(sp)
    80000f66:	7442                	ld	s0,48(sp)
    80000f68:	74a2                	ld	s1,40(sp)
    80000f6a:	7902                	ld	s2,32(sp)
    80000f6c:	69e2                	ld	s3,24(sp)
    80000f6e:	6a42                	ld	s4,16(sp)
    80000f70:	6aa2                	ld	s5,8(sp)
    80000f72:	6121                	addi	sp,sp,64
    80000f74:	8082                	ret

0000000080000f76 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80000f76:	7179                	addi	sp,sp,-48
    80000f78:	f406                	sd	ra,40(sp)
    80000f7a:	f022                	sd	s0,32(sp)
    80000f7c:	ec26                	sd	s1,24(sp)
    80000f7e:	e84a                	sd	s2,16(sp)
    80000f80:	e44e                	sd	s3,8(sp)
    80000f82:	1800                	addi	s0,sp,48
    80000f84:	89aa                	mv	s3,a0
    80000f86:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80000f88:	00000097          	auipc	ra,0x0
    80000f8c:	b28080e7          	jalr	-1240(ra) # 80000ab0 <myproc>
    80000f90:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80000f92:	fffff097          	auipc	ra,0xfffff
    80000f96:	702080e7          	jalr	1794(ra) # 80000694 <acquire>
  release(lk);
    80000f9a:	854a                	mv	a0,s2
    80000f9c:	fffff097          	auipc	ra,0xfffff
    80000fa0:	7ac080e7          	jalr	1964(ra) # 80000748 <release>

  // Go to sleep.
  p->chan = chan;
    80000fa4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80000fa8:	4789                	li	a5,2
    80000faa:	cc9c                	sw	a5,24(s1)

  sched();
    80000fac:	00000097          	auipc	ra,0x0
    80000fb0:	df6080e7          	jalr	-522(ra) # 80000da2 <sched>

  // Tidy up.
  p->chan = 0;
    80000fb4:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80000fb8:	8526                	mv	a0,s1
    80000fba:	fffff097          	auipc	ra,0xfffff
    80000fbe:	78e080e7          	jalr	1934(ra) # 80000748 <release>
  acquire(lk);
    80000fc2:	854a                	mv	a0,s2
    80000fc4:	fffff097          	auipc	ra,0xfffff
    80000fc8:	6d0080e7          	jalr	1744(ra) # 80000694 <acquire>
}
    80000fcc:	70a2                	ld	ra,40(sp)
    80000fce:	7402                	ld	s0,32(sp)
    80000fd0:	64e2                	ld	s1,24(sp)
    80000fd2:	6942                	ld	s2,16(sp)
    80000fd4:	69a2                	ld	s3,8(sp)
    80000fd6:	6145                	addi	sp,sp,48
    80000fd8:	8082                	ret

0000000080000fda <wait>:
{
    80000fda:	7139                	addi	sp,sp,-64
    80000fdc:	fc06                	sd	ra,56(sp)
    80000fde:	f822                	sd	s0,48(sp)
    80000fe0:	f426                	sd	s1,40(sp)
    80000fe2:	f04a                	sd	s2,32(sp)
    80000fe4:	ec4e                	sd	s3,24(sp)
    80000fe6:	e852                	sd	s4,16(sp)
    80000fe8:	e456                	sd	s5,8(sp)
    80000fea:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80000fec:	00000097          	auipc	ra,0x0
    80000ff0:	ac4080e7          	jalr	-1340(ra) # 80000ab0 <myproc>
    80000ff4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80000ff6:	00009517          	auipc	a0,0x9
    80000ffa:	52250513          	addi	a0,a0,1314 # 8000a518 <wait_lock>
    80000ffe:	fffff097          	auipc	ra,0xfffff
    80001002:	696080e7          	jalr	1686(ra) # 80000694 <acquire>
        if(pp->state == ZOMBIE){
    80001006:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001008:	0000f997          	auipc	s3,0xf
    8000100c:	32898993          	addi	s3,s3,808 # 80010330 <end>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001010:	00009a97          	auipc	s5,0x9
    80001014:	508a8a93          	addi	s5,s5,1288 # 8000a518 <wait_lock>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001018:	0000a497          	auipc	s1,0xa
    8000101c:	91848493          	addi	s1,s1,-1768 # 8000a930 <proc>
    80001020:	a029                	j	8000102a <wait+0x50>
    80001022:	16848493          	addi	s1,s1,360
    80001026:	03348363          	beq	s1,s3,8000104c <wait+0x72>
      if(pp->parent == p){
    8000102a:	7c9c                	ld	a5,56(s1)
    8000102c:	ff279be3          	bne	a5,s2,80001022 <wait+0x48>
        acquire(&pp->lock);
    80001030:	8526                	mv	a0,s1
    80001032:	fffff097          	auipc	ra,0xfffff
    80001036:	662080e7          	jalr	1634(ra) # 80000694 <acquire>
        if(pp->state == ZOMBIE){
    8000103a:	4c9c                	lw	a5,24(s1)
    8000103c:	01478f63          	beq	a5,s4,8000105a <wait+0x80>
        release(&pp->lock);
    80001040:	8526                	mv	a0,s1
    80001042:	fffff097          	auipc	ra,0xfffff
    80001046:	706080e7          	jalr	1798(ra) # 80000748 <release>
    8000104a:	bfe1                	j	80001022 <wait+0x48>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000104c:	85d6                	mv	a1,s5
    8000104e:	854a                	mv	a0,s2
    80001050:	00000097          	auipc	ra,0x0
    80001054:	f26080e7          	jalr	-218(ra) # 80000f76 <sleep>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001058:	b7c1                	j	80001018 <wait+0x3e>
            release(&pp->lock);
    8000105a:	8526                	mv	a0,s1
    8000105c:	fffff097          	auipc	ra,0xfffff
    80001060:	6ec080e7          	jalr	1772(ra) # 80000748 <release>
            release(&wait_lock);
    80001064:	00009517          	auipc	a0,0x9
    80001068:	4b450513          	addi	a0,a0,1204 # 8000a518 <wait_lock>
    8000106c:	fffff097          	auipc	ra,0xfffff
    80001070:	6dc080e7          	jalr	1756(ra) # 80000748 <release>
}
    80001074:	557d                	li	a0,-1
    80001076:	70e2                	ld	ra,56(sp)
    80001078:	7442                	ld	s0,48(sp)
    8000107a:	74a2                	ld	s1,40(sp)
    8000107c:	7902                	ld	s2,32(sp)
    8000107e:	69e2                	ld	s3,24(sp)
    80001080:	6a42                	ld	s4,16(sp)
    80001082:	6aa2                	ld	s5,8(sp)
    80001084:	6121                	addi	sp,sp,64
    80001086:	8082                	ret

0000000080001088 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001088:	7139                	addi	sp,sp,-64
    8000108a:	fc06                	sd	ra,56(sp)
    8000108c:	f822                	sd	s0,48(sp)
    8000108e:	f426                	sd	s1,40(sp)
    80001090:	f04a                	sd	s2,32(sp)
    80001092:	ec4e                	sd	s3,24(sp)
    80001094:	e852                	sd	s4,16(sp)
    80001096:	e456                	sd	s5,8(sp)
    80001098:	0080                	addi	s0,sp,64
    8000109a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000109c:	0000a497          	auipc	s1,0xa
    800010a0:	89448493          	addi	s1,s1,-1900 # 8000a930 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800010a4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800010a6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800010a8:	0000f917          	auipc	s2,0xf
    800010ac:	28890913          	addi	s2,s2,648 # 80010330 <end>
    800010b0:	a811                	j	800010c4 <wakeup+0x3c>
      }
      release(&p->lock);
    800010b2:	8526                	mv	a0,s1
    800010b4:	fffff097          	auipc	ra,0xfffff
    800010b8:	694080e7          	jalr	1684(ra) # 80000748 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800010bc:	16848493          	addi	s1,s1,360
    800010c0:	03248663          	beq	s1,s2,800010ec <wakeup+0x64>
    if(p != myproc()){
    800010c4:	00000097          	auipc	ra,0x0
    800010c8:	9ec080e7          	jalr	-1556(ra) # 80000ab0 <myproc>
    800010cc:	fea488e3          	beq	s1,a0,800010bc <wakeup+0x34>
      acquire(&p->lock);
    800010d0:	8526                	mv	a0,s1
    800010d2:	fffff097          	auipc	ra,0xfffff
    800010d6:	5c2080e7          	jalr	1474(ra) # 80000694 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800010da:	4c9c                	lw	a5,24(s1)
    800010dc:	fd379be3          	bne	a5,s3,800010b2 <wakeup+0x2a>
    800010e0:	709c                	ld	a5,32(s1)
    800010e2:	fd4798e3          	bne	a5,s4,800010b2 <wakeup+0x2a>
        p->state = RUNNABLE;
    800010e6:	0154ac23          	sw	s5,24(s1)
    800010ea:	b7e1                	j	800010b2 <wakeup+0x2a>
    }
  }
}
    800010ec:	70e2                	ld	ra,56(sp)
    800010ee:	7442                	ld	s0,48(sp)
    800010f0:	74a2                	ld	s1,40(sp)
    800010f2:	7902                	ld	s2,32(sp)
    800010f4:	69e2                	ld	s3,24(sp)
    800010f6:	6a42                	ld	s4,16(sp)
    800010f8:	6aa2                	ld	s5,8(sp)
    800010fa:	6121                	addi	sp,sp,64
    800010fc:	8082                	ret

00000000800010fe <reparent>:
{
    800010fe:	7179                	addi	sp,sp,-48
    80001100:	f406                	sd	ra,40(sp)
    80001102:	f022                	sd	s0,32(sp)
    80001104:	ec26                	sd	s1,24(sp)
    80001106:	e84a                	sd	s2,16(sp)
    80001108:	e44e                	sd	s3,8(sp)
    8000110a:	e052                	sd	s4,0(sp)
    8000110c:	1800                	addi	s0,sp,48
    8000110e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001110:	0000a497          	auipc	s1,0xa
    80001114:	82048493          	addi	s1,s1,-2016 # 8000a930 <proc>
      pp->parent = initproc;
    80001118:	00001a17          	auipc	s4,0x1
    8000111c:	178a0a13          	addi	s4,s4,376 # 80002290 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001120:	0000f997          	auipc	s3,0xf
    80001124:	21098993          	addi	s3,s3,528 # 80010330 <end>
    80001128:	a029                	j	80001132 <reparent+0x34>
    8000112a:	16848493          	addi	s1,s1,360
    8000112e:	01348d63          	beq	s1,s3,80001148 <reparent+0x4a>
    if(pp->parent == p){
    80001132:	7c9c                	ld	a5,56(s1)
    80001134:	ff279be3          	bne	a5,s2,8000112a <reparent+0x2c>
      pp->parent = initproc;
    80001138:	000a3503          	ld	a0,0(s4)
    8000113c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000113e:	00000097          	auipc	ra,0x0
    80001142:	f4a080e7          	jalr	-182(ra) # 80001088 <wakeup>
    80001146:	b7d5                	j	8000112a <reparent+0x2c>
}
    80001148:	70a2                	ld	ra,40(sp)
    8000114a:	7402                	ld	s0,32(sp)
    8000114c:	64e2                	ld	s1,24(sp)
    8000114e:	6942                	ld	s2,16(sp)
    80001150:	69a2                	ld	s3,8(sp)
    80001152:	6a02                	ld	s4,0(sp)
    80001154:	6145                	addi	sp,sp,48
    80001156:	8082                	ret

0000000080001158 <exit>:
{
    80001158:	7179                	addi	sp,sp,-48
    8000115a:	f406                	sd	ra,40(sp)
    8000115c:	f022                	sd	s0,32(sp)
    8000115e:	ec26                	sd	s1,24(sp)
    80001160:	e84a                	sd	s2,16(sp)
    80001162:	e44e                	sd	s3,8(sp)
    80001164:	1800                	addi	s0,sp,48
    80001166:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	948080e7          	jalr	-1720(ra) # 80000ab0 <myproc>
    80001170:	84aa                	mv	s1,a0
  if(p == initproc)
    80001172:	00001717          	auipc	a4,0x1
    80001176:	11e73703          	ld	a4,286(a4) # 80002290 <initproc>
    8000117a:	0d050793          	addi	a5,a0,208
    8000117e:	15050693          	addi	a3,a0,336
    80001182:	00a71d63          	bne	a4,a0,8000119c <exit+0x44>
    panic("init exiting");
    80001186:	00001517          	auipc	a0,0x1
    8000118a:	fda50513          	addi	a0,a0,-38 # 80002160 <digits+0x130>
    8000118e:	fffff097          	auipc	ra,0xfffff
    80001192:	004080e7          	jalr	4(ra) # 80000192 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80001196:	07a1                	addi	a5,a5,8
    80001198:	00d78763          	beq	a5,a3,800011a6 <exit+0x4e>
    if(p->ofile[fd]){
    8000119c:	6398                	ld	a4,0(a5)
    8000119e:	df65                	beqz	a4,80001196 <exit+0x3e>
      p->ofile[fd] = 0;
    800011a0:	0007b023          	sd	zero,0(a5)
    800011a4:	bfcd                	j	80001196 <exit+0x3e>
  p->cwd = 0;
    800011a6:	1404b823          	sd	zero,336(s1)
  acquire(&wait_lock);
    800011aa:	00009997          	auipc	s3,0x9
    800011ae:	36e98993          	addi	s3,s3,878 # 8000a518 <wait_lock>
    800011b2:	854e                	mv	a0,s3
    800011b4:	fffff097          	auipc	ra,0xfffff
    800011b8:	4e0080e7          	jalr	1248(ra) # 80000694 <acquire>
  reparent(p);
    800011bc:	8526                	mv	a0,s1
    800011be:	00000097          	auipc	ra,0x0
    800011c2:	f40080e7          	jalr	-192(ra) # 800010fe <reparent>
  wakeup(p->parent);
    800011c6:	7c88                	ld	a0,56(s1)
    800011c8:	00000097          	auipc	ra,0x0
    800011cc:	ec0080e7          	jalr	-320(ra) # 80001088 <wakeup>
  acquire(&p->lock);
    800011d0:	8526                	mv	a0,s1
    800011d2:	fffff097          	auipc	ra,0xfffff
    800011d6:	4c2080e7          	jalr	1218(ra) # 80000694 <acquire>
  p->xstate = status;
    800011da:	0324a623          	sw	s2,44(s1)
  p->state = ZOMBIE;
    800011de:	4795                	li	a5,5
    800011e0:	cc9c                	sw	a5,24(s1)
  release(&wait_lock);
    800011e2:	854e                	mv	a0,s3
    800011e4:	fffff097          	auipc	ra,0xfffff
    800011e8:	564080e7          	jalr	1380(ra) # 80000748 <release>
  sched();
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	bb6080e7          	jalr	-1098(ra) # 80000da2 <sched>
  panic("zombie exit");
    800011f4:	00001517          	auipc	a0,0x1
    800011f8:	f7c50513          	addi	a0,a0,-132 # 80002170 <digits+0x140>
    800011fc:	fffff097          	auipc	ra,0xfffff
    80001200:	f96080e7          	jalr	-106(ra) # 80000192 <panic>

0000000080001204 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001204:	7179                	addi	sp,sp,-48
    80001206:	f406                	sd	ra,40(sp)
    80001208:	f022                	sd	s0,32(sp)
    8000120a:	ec26                	sd	s1,24(sp)
    8000120c:	e84a                	sd	s2,16(sp)
    8000120e:	e44e                	sd	s3,8(sp)
    80001210:	1800                	addi	s0,sp,48
    80001212:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001214:	00009497          	auipc	s1,0x9
    80001218:	71c48493          	addi	s1,s1,1820 # 8000a930 <proc>
    8000121c:	0000f997          	auipc	s3,0xf
    80001220:	11498993          	addi	s3,s3,276 # 80010330 <end>
    acquire(&p->lock);
    80001224:	8526                	mv	a0,s1
    80001226:	fffff097          	auipc	ra,0xfffff
    8000122a:	46e080e7          	jalr	1134(ra) # 80000694 <acquire>
    if(p->pid == pid){
    8000122e:	589c                	lw	a5,48(s1)
    80001230:	01278d63          	beq	a5,s2,8000124a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001234:	8526                	mv	a0,s1
    80001236:	fffff097          	auipc	ra,0xfffff
    8000123a:	512080e7          	jalr	1298(ra) # 80000748 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000123e:	16848493          	addi	s1,s1,360
    80001242:	ff3491e3          	bne	s1,s3,80001224 <kill+0x20>
  }
  return -1;
    80001246:	557d                	li	a0,-1
    80001248:	a829                	j	80001262 <kill+0x5e>
      p->killed = 1;
    8000124a:	4785                	li	a5,1
    8000124c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000124e:	4c98                	lw	a4,24(s1)
    80001250:	4789                	li	a5,2
    80001252:	00f70f63          	beq	a4,a5,80001270 <kill+0x6c>
      release(&p->lock);
    80001256:	8526                	mv	a0,s1
    80001258:	fffff097          	auipc	ra,0xfffff
    8000125c:	4f0080e7          	jalr	1264(ra) # 80000748 <release>
      return 0;
    80001260:	4501                	li	a0,0
}
    80001262:	70a2                	ld	ra,40(sp)
    80001264:	7402                	ld	s0,32(sp)
    80001266:	64e2                	ld	s1,24(sp)
    80001268:	6942                	ld	s2,16(sp)
    8000126a:	69a2                	ld	s3,8(sp)
    8000126c:	6145                	addi	sp,sp,48
    8000126e:	8082                	ret
        p->state = RUNNABLE;
    80001270:	478d                	li	a5,3
    80001272:	cc9c                	sw	a5,24(s1)
    80001274:	b7cd                	j	80001256 <kill+0x52>

0000000080001276 <setkilled>:

void
setkilled(struct proc *p)
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
    80001280:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001282:	fffff097          	auipc	ra,0xfffff
    80001286:	412080e7          	jalr	1042(ra) # 80000694 <acquire>
  p->killed = 1;
    8000128a:	4785                	li	a5,1
    8000128c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000128e:	8526                	mv	a0,s1
    80001290:	fffff097          	auipc	ra,0xfffff
    80001294:	4b8080e7          	jalr	1208(ra) # 80000748 <release>
}
    80001298:	60e2                	ld	ra,24(sp)
    8000129a:	6442                	ld	s0,16(sp)
    8000129c:	64a2                	ld	s1,8(sp)
    8000129e:	6105                	addi	sp,sp,32
    800012a0:	8082                	ret

00000000800012a2 <killed>:

int
killed(struct proc *p)
{
    800012a2:	1101                	addi	sp,sp,-32
    800012a4:	ec06                	sd	ra,24(sp)
    800012a6:	e822                	sd	s0,16(sp)
    800012a8:	e426                	sd	s1,8(sp)
    800012aa:	e04a                	sd	s2,0(sp)
    800012ac:	1000                	addi	s0,sp,32
    800012ae:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	3e4080e7          	jalr	996(ra) # 80000694 <acquire>
  k = p->killed;
    800012b8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800012bc:	8526                	mv	a0,s1
    800012be:	fffff097          	auipc	ra,0xfffff
    800012c2:	48a080e7          	jalr	1162(ra) # 80000748 <release>
  return k;
}
    800012c6:	854a                	mv	a0,s2
    800012c8:	60e2                	ld	ra,24(sp)
    800012ca:	6442                	ld	s0,16(sp)
    800012cc:	64a2                	ld	s1,8(sp)
    800012ce:	6902                	ld	s2,0(sp)
    800012d0:	6105                	addi	sp,sp,32
    800012d2:	8082                	ret

00000000800012d4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800012d4:	1141                	addi	sp,sp,-16
    800012d6:	e406                	sd	ra,8(sp)
    800012d8:	e022                	sd	s0,0(sp)
    800012da:	0800                	addi	s0,sp,16
    800012dc:	852e                	mv	a0,a1
    800012de:	85b2                	mv	a1,a2
  memmove((char *)dst, src, len);
    800012e0:	0006861b          	sext.w	a2,a3
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	508080e7          	jalr	1288(ra) # 800007ec <memmove>
  return 0;
}
    800012ec:	4501                	li	a0,0
    800012ee:	60a2                	ld	ra,8(sp)
    800012f0:	6402                	ld	s0,0(sp)
    800012f2:	0141                	addi	sp,sp,16
    800012f4:	8082                	ret

00000000800012f6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800012f6:	1141                	addi	sp,sp,-16
    800012f8:	e406                	sd	ra,8(sp)
    800012fa:	e022                	sd	s0,0(sp)
    800012fc:	0800                	addi	s0,sp,16
    800012fe:	85b2                	mv	a1,a2
  memmove(dst, (char*)src, len);
    80001300:	0006861b          	sext.w	a2,a3
    80001304:	fffff097          	auipc	ra,0xfffff
    80001308:	4e8080e7          	jalr	1256(ra) # 800007ec <memmove>
  return 0;
}
    8000130c:	4501                	li	a0,0
    8000130e:	60a2                	ld	ra,8(sp)
    80001310:	6402                	ld	s0,0(sp)
    80001312:	0141                	addi	sp,sp,16
    80001314:	8082                	ret

0000000080001316 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001316:	715d                	addi	sp,sp,-80
    80001318:	e486                	sd	ra,72(sp)
    8000131a:	e0a2                	sd	s0,64(sp)
    8000131c:	fc26                	sd	s1,56(sp)
    8000131e:	f84a                	sd	s2,48(sp)
    80001320:	f44e                	sd	s3,40(sp)
    80001322:	f052                	sd	s4,32(sp)
    80001324:	ec56                	sd	s5,24(sp)
    80001326:	e85a                	sd	s6,16(sp)
    80001328:	e45e                	sd	s7,8(sp)
    8000132a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000132c:	00001517          	auipc	a0,0x1
    80001330:	d8c50513          	addi	a0,a0,-628 # 800020b8 <digits+0x88>
    80001334:	fffff097          	auipc	ra,0xfffff
    80001338:	ea8080e7          	jalr	-344(ra) # 800001dc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000133c:	00009497          	auipc	s1,0x9
    80001340:	74c48493          	addi	s1,s1,1868 # 8000aa88 <proc+0x158>
    80001344:	0000f917          	auipc	s2,0xf
    80001348:	14490913          	addi	s2,s2,324 # 80010488 <end+0x158>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000134c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000134e:	00001997          	auipc	s3,0x1
    80001352:	e3298993          	addi	s3,s3,-462 # 80002180 <digits+0x150>
    printf("%d %s %s", p->pid, state, p->name);
    80001356:	00001a97          	auipc	s5,0x1
    8000135a:	e32a8a93          	addi	s5,s5,-462 # 80002188 <digits+0x158>
    printf("\n");
    8000135e:	00001a17          	auipc	s4,0x1
    80001362:	d5aa0a13          	addi	s4,s4,-678 # 800020b8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001366:	00001b97          	auipc	s7,0x1
    8000136a:	e62b8b93          	addi	s7,s7,-414 # 800021c8 <states.0>
    8000136e:	a00d                	j	80001390 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001370:	ed86a583          	lw	a1,-296(a3)
    80001374:	8556                	mv	a0,s5
    80001376:	fffff097          	auipc	ra,0xfffff
    8000137a:	e66080e7          	jalr	-410(ra) # 800001dc <printf>
    printf("\n");
    8000137e:	8552                	mv	a0,s4
    80001380:	fffff097          	auipc	ra,0xfffff
    80001384:	e5c080e7          	jalr	-420(ra) # 800001dc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001388:	16848493          	addi	s1,s1,360
    8000138c:	03248263          	beq	s1,s2,800013b0 <procdump+0x9a>
    if(p->state == UNUSED)
    80001390:	86a6                	mv	a3,s1
    80001392:	ec04a783          	lw	a5,-320(s1)
    80001396:	dbed                	beqz	a5,80001388 <procdump+0x72>
      state = "???";
    80001398:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000139a:	fcfb6be3          	bltu	s6,a5,80001370 <procdump+0x5a>
    8000139e:	02079713          	slli	a4,a5,0x20
    800013a2:	01d75793          	srli	a5,a4,0x1d
    800013a6:	97de                	add	a5,a5,s7
    800013a8:	6390                	ld	a2,0(a5)
    800013aa:	f279                	bnez	a2,80001370 <procdump+0x5a>
      state = "???";
    800013ac:	864e                	mv	a2,s3
    800013ae:	b7c9                	j	80001370 <procdump+0x5a>
  }
}
    800013b0:	60a6                	ld	ra,72(sp)
    800013b2:	6406                	ld	s0,64(sp)
    800013b4:	74e2                	ld	s1,56(sp)
    800013b6:	7942                	ld	s2,48(sp)
    800013b8:	79a2                	ld	s3,40(sp)
    800013ba:	7a02                	ld	s4,32(sp)
    800013bc:	6ae2                	ld	s5,24(sp)
    800013be:	6b42                	ld	s6,16(sp)
    800013c0:	6ba2                	ld	s7,8(sp)
    800013c2:	6161                	addi	sp,sp,80
    800013c4:	8082                	ret

00000000800013c6 <swtch>:
    800013c6:	00153023          	sd	ra,0(a0)
    800013ca:	00253423          	sd	sp,8(a0)
    800013ce:	e900                	sd	s0,16(a0)
    800013d0:	ed04                	sd	s1,24(a0)
    800013d2:	03253023          	sd	s2,32(a0)
    800013d6:	03353423          	sd	s3,40(a0)
    800013da:	03453823          	sd	s4,48(a0)
    800013de:	03553c23          	sd	s5,56(a0)
    800013e2:	05653023          	sd	s6,64(a0)
    800013e6:	05753423          	sd	s7,72(a0)
    800013ea:	05853823          	sd	s8,80(a0)
    800013ee:	05953c23          	sd	s9,88(a0)
    800013f2:	07a53023          	sd	s10,96(a0)
    800013f6:	07b53423          	sd	s11,104(a0)
    800013fa:	0005b083          	ld	ra,0(a1)
    800013fe:	0085b103          	ld	sp,8(a1)
    80001402:	6980                	ld	s0,16(a1)
    80001404:	6d84                	ld	s1,24(a1)
    80001406:	0205b903          	ld	s2,32(a1)
    8000140a:	0285b983          	ld	s3,40(a1)
    8000140e:	0305ba03          	ld	s4,48(a1)
    80001412:	0385ba83          	ld	s5,56(a1)
    80001416:	0405bb03          	ld	s6,64(a1)
    8000141a:	0485bb83          	ld	s7,72(a1)
    8000141e:	0505bc03          	ld	s8,80(a1)
    80001422:	0585bc83          	ld	s9,88(a1)
    80001426:	0605bd03          	ld	s10,96(a1)
    8000142a:	0685bd83          	ld	s11,104(a1)
    8000142e:	8082                	ret
	...
