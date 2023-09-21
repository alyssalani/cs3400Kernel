
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
    800000d2:	f3258593          	addi	a1,a1,-206 # 80002000 <swtch+0xb92>
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
    800001aa:	e6250513          	addi	a0,a0,-414 # 80002008 <swtch+0xb9a>
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
    80000262:	dba50513          	addi	a0,a0,-582 # 80002018 <swtch+0xbaa>
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
    8000035c:	cb848493          	addi	s1,s1,-840 # 80002010 <swtch+0xba2>
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
    800003d2:	c5a58593          	addi	a1,a1,-934 # 80002028 <swtch+0xbba>
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
    80000632:	456080e7          	jalr	1110(ra) # 80000a84 <mycpu>
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
    80000664:	424080e7          	jalr	1060(ra) # 80000a84 <mycpu>
    80000668:	5d3c                	lw	a5,120(a0)
    8000066a:	cf89                	beqz	a5,80000684 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	418080e7          	jalr	1048(ra) # 80000a84 <mycpu>
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
    80000688:	400080e7          	jalr	1024(ra) # 80000a84 <mycpu>
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
    800006c8:	3c0080e7          	jalr	960(ra) # 80000a84 <mycpu>
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
    800006f4:	394080e7          	jalr	916(ra) # 80000a84 <mycpu>
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
    80000942:	136080e7          	jalr	310(ra) # 80000a74 <cpuid>
    kinit();         // physical page allocator
    procinit();      // process table
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
    8000095e:	11a080e7          	jalr	282(ra) # 80000a74 <cpuid>
    80000962:	85aa                	mv	a1,a0
    80000964:	00001517          	auipc	a0,0x1
    80000968:	74450513          	addi	a0,a0,1860 # 800020a8 <digits+0x78>
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	870080e7          	jalr	-1936(ra) # 800001dc <printf>
  }

  scheduler();        
    80000974:	00000097          	auipc	ra,0x0
    80000978:	3f6080e7          	jalr	1014(ra) # 80000d6a <scheduler>
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
    800009c8:	018080e7          	jalr	24(ra) # 800009dc <procinit>
    __sync_synchronize();
    800009cc:	0ff0000f          	fence
    started = 1;
    800009d0:	4785                	li	a5,1
    800009d2:	00002717          	auipc	a4,0x2
    800009d6:	8af72b23          	sw	a5,-1866(a4) # 80002288 <started>
    800009da:	bf69                	j	80000974 <main+0x3e>

00000000800009dc <procinit>:
// guard page.
void

// initialize the proc table.
procinit(void)
{
    800009dc:	7179                	addi	sp,sp,-48
    800009de:	f406                	sd	ra,40(sp)
    800009e0:	f022                	sd	s0,32(sp)
    800009e2:	ec26                	sd	s1,24(sp)
    800009e4:	e84a                	sd	s2,16(sp)
    800009e6:	e44e                	sd	s3,8(sp)
    800009e8:	1800                	addi	s0,sp,48
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800009ea:	00001597          	auipc	a1,0x1
    800009ee:	6d658593          	addi	a1,a1,1750 # 800020c0 <digits+0x90>
    800009f2:	0000a517          	auipc	a0,0xa
    800009f6:	b0e50513          	addi	a0,a0,-1266 # 8000a500 <pid_lock>
    800009fa:	00000097          	auipc	ra,0x0
    800009fe:	c0a080e7          	jalr	-1014(ra) # 80000604 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000a02:	00001597          	auipc	a1,0x1
    80000a06:	6c658593          	addi	a1,a1,1734 # 800020c8 <digits+0x98>
    80000a0a:	0000a517          	auipc	a0,0xa
    80000a0e:	b0e50513          	addi	a0,a0,-1266 # 8000a518 <wait_lock>
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	bf2080e7          	jalr	-1038(ra) # 80000604 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000a1a:	0000a497          	auipc	s1,0xa
    80000a1e:	f1648493          	addi	s1,s1,-234 # 8000a930 <proc>
      initlock(&p->lock, "proc");
    80000a22:	00001997          	auipc	s3,0x1
    80000a26:	6b698993          	addi	s3,s3,1718 # 800020d8 <digits+0xa8>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000a2a:	00010917          	auipc	s2,0x10
    80000a2e:	90690913          	addi	s2,s2,-1786 # 80010330 <end>
      initlock(&p->lock, "proc");
    80000a32:	85ce                	mv	a1,s3
    80000a34:	8526                	mv	a0,s1
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	bce080e7          	jalr	-1074(ra) # 80000604 <initlock>
      p->state = UNUSED;
    80000a3e:	0004ac23          	sw	zero,24(s1)

      char *pa = kalloc();
    80000a42:	00000097          	auipc	ra,0x0
    80000a46:	b62080e7          	jalr	-1182(ra) # 800005a4 <kalloc>
      if (pa == 0)
    80000a4a:	cd09                	beqz	a0,80000a64 <procinit+0x88>
          panic("kalloc");
      p->kstack = (uint64)pa;
    80000a4c:	e0a8                	sd	a0,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000a4e:	16848493          	addi	s1,s1,360
    80000a52:	ff2490e3          	bne	s1,s2,80000a32 <procinit+0x56>
  }
}
    80000a56:	70a2                	ld	ra,40(sp)
    80000a58:	7402                	ld	s0,32(sp)
    80000a5a:	64e2                	ld	s1,24(sp)
    80000a5c:	6942                	ld	s2,16(sp)
    80000a5e:	69a2                	ld	s3,8(sp)
    80000a60:	6145                	addi	sp,sp,48
    80000a62:	8082                	ret
          panic("kalloc");
    80000a64:	00001517          	auipc	a0,0x1
    80000a68:	67c50513          	addi	a0,a0,1660 # 800020e0 <digits+0xb0>
    80000a6c:	fffff097          	auipc	ra,0xfffff
    80000a70:	726080e7          	jalr	1830(ra) # 80000192 <panic>

0000000080000a74 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000a74:	1141                	addi	sp,sp,-16
    80000a76:	e422                	sd	s0,8(sp)
    80000a78:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000a7a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000a7c:	2501                	sext.w	a0,a0
    80000a7e:	6422                	ld	s0,8(sp)
    80000a80:	0141                	addi	sp,sp,16
    80000a82:	8082                	ret

0000000080000a84 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000a84:	1141                	addi	sp,sp,-16
    80000a86:	e422                	sd	s0,8(sp)
    80000a88:	0800                	addi	s0,sp,16
    80000a8a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000a8c:	2781                	sext.w	a5,a5
    80000a8e:	079e                	slli	a5,a5,0x7
  return c;
}
    80000a90:	0000a517          	auipc	a0,0xa
    80000a94:	aa050513          	addi	a0,a0,-1376 # 8000a530 <cpus>
    80000a98:	953e                	add	a0,a0,a5
    80000a9a:	6422                	ld	s0,8(sp)
    80000a9c:	0141                	addi	sp,sp,16
    80000a9e:	8082                	ret

0000000080000aa0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000aa0:	1101                	addi	sp,sp,-32
    80000aa2:	ec06                	sd	ra,24(sp)
    80000aa4:	e822                	sd	s0,16(sp)
    80000aa6:	e426                	sd	s1,8(sp)
    80000aa8:	1000                	addi	s0,sp,32
  push_off();
    80000aaa:	00000097          	auipc	ra,0x0
    80000aae:	b9e080e7          	jalr	-1122(ra) # 80000648 <push_off>
    80000ab2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000ab4:	2781                	sext.w	a5,a5
    80000ab6:	079e                	slli	a5,a5,0x7
    80000ab8:	0000a717          	auipc	a4,0xa
    80000abc:	a4870713          	addi	a4,a4,-1464 # 8000a500 <pid_lock>
    80000ac0:	97ba                	add	a5,a5,a4
    80000ac2:	7b84                	ld	s1,48(a5)
  pop_off();
    80000ac4:	00000097          	auipc	ra,0x0
    80000ac8:	c24080e7          	jalr	-988(ra) # 800006e8 <pop_off>
  return p;
}
    80000acc:	8526                	mv	a0,s1
    80000ace:	60e2                	ld	ra,24(sp)
    80000ad0:	6442                	ld	s0,16(sp)
    80000ad2:	64a2                	ld	s1,8(sp)
    80000ad4:	6105                	addi	sp,sp,32
    80000ad6:	8082                	ret

0000000080000ad8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000ad8:	1141                	addi	sp,sp,-16
    80000ada:	e406                	sd	ra,8(sp)
    80000adc:	e022                	sd	s0,0(sp)
    80000ade:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000ae0:	00000097          	auipc	ra,0x0
    80000ae4:	fc0080e7          	jalr	-64(ra) # 80000aa0 <myproc>
    80000ae8:	00000097          	auipc	ra,0x0
    80000aec:	c60080e7          	jalr	-928(ra) # 80000748 <release>

  if (first) {
    80000af0:	00001797          	auipc	a5,0x1
    80000af4:	7107a783          	lw	a5,1808(a5) # 80002200 <first.1>
    80000af8:	c789                	beqz	a5,80000b02 <forkret+0x2a>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    80000afa:	00001797          	auipc	a5,0x1
    80000afe:	7007a323          	sw	zero,1798(a5) # 80002200 <first.1>
  }

}
    80000b02:	60a2                	ld	ra,8(sp)
    80000b04:	6402                	ld	s0,0(sp)
    80000b06:	0141                	addi	sp,sp,16
    80000b08:	8082                	ret

0000000080000b0a <allocpid>:
{
    80000b0a:	1101                	addi	sp,sp,-32
    80000b0c:	ec06                	sd	ra,24(sp)
    80000b0e:	e822                	sd	s0,16(sp)
    80000b10:	e426                	sd	s1,8(sp)
    80000b12:	e04a                	sd	s2,0(sp)
    80000b14:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000b16:	0000a917          	auipc	s2,0xa
    80000b1a:	9ea90913          	addi	s2,s2,-1558 # 8000a500 <pid_lock>
    80000b1e:	854a                	mv	a0,s2
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	b74080e7          	jalr	-1164(ra) # 80000694 <acquire>
  pid = nextpid;
    80000b28:	00001797          	auipc	a5,0x1
    80000b2c:	6dc78793          	addi	a5,a5,1756 # 80002204 <nextpid>
    80000b30:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000b32:	0014871b          	addiw	a4,s1,1
    80000b36:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000b38:	854a                	mv	a0,s2
    80000b3a:	00000097          	auipc	ra,0x0
    80000b3e:	c0e080e7          	jalr	-1010(ra) # 80000748 <release>
}
    80000b42:	8526                	mv	a0,s1
    80000b44:	60e2                	ld	ra,24(sp)
    80000b46:	6442                	ld	s0,16(sp)
    80000b48:	64a2                	ld	s1,8(sp)
    80000b4a:	6902                	ld	s2,0(sp)
    80000b4c:	6105                	addi	sp,sp,32
    80000b4e:	8082                	ret

0000000080000b50 <allocproc>:
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	e04a                	sd	s2,0(sp)
    80000b5a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80000b5c:	0000a497          	auipc	s1,0xa
    80000b60:	dd448493          	addi	s1,s1,-556 # 8000a930 <proc>
    80000b64:	0000f917          	auipc	s2,0xf
    80000b68:	7cc90913          	addi	s2,s2,1996 # 80010330 <end>
    acquire(&p->lock);
    80000b6c:	8526                	mv	a0,s1
    80000b6e:	00000097          	auipc	ra,0x0
    80000b72:	b26080e7          	jalr	-1242(ra) # 80000694 <acquire>
    if(p->state == UNUSED) {
    80000b76:	4c9c                	lw	a5,24(s1)
    80000b78:	cf81                	beqz	a5,80000b90 <allocproc+0x40>
      release(&p->lock);
    80000b7a:	8526                	mv	a0,s1
    80000b7c:	00000097          	auipc	ra,0x0
    80000b80:	bcc080e7          	jalr	-1076(ra) # 80000748 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000b84:	16848493          	addi	s1,s1,360
    80000b88:	ff2492e3          	bne	s1,s2,80000b6c <allocproc+0x1c>
  return 0;
    80000b8c:	4481                	li	s1,0
    80000b8e:	a0a9                	j	80000bd8 <allocproc+0x88>
  p->pid = allocpid();
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	f7a080e7          	jalr	-134(ra) # 80000b0a <allocpid>
    80000b98:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000b9a:	4785                	li	a5,1
    80000b9c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	a06080e7          	jalr	-1530(ra) # 800005a4 <kalloc>
    80000ba6:	892a                	mv	s2,a0
    80000ba8:	eca8                	sd	a0,88(s1)
    80000baa:	cd15                	beqz	a0,80000be6 <allocproc+0x96>
  if(p->pagetable == 0){
    80000bac:	0504b903          	ld	s2,80(s1)
    80000bb0:	06090963          	beqz	s2,80000c22 <allocproc+0xd2>
  memset(&p->context, 0, sizeof(p->context));
    80000bb4:	07000613          	li	a2,112
    80000bb8:	4581                	li	a1,0
    80000bba:	06048513          	addi	a0,s1,96
    80000bbe:	00000097          	auipc	ra,0x0
    80000bc2:	bd2080e7          	jalr	-1070(ra) # 80000790 <memset>
  p->context.ra = (uint64)forkret;
    80000bc6:	00000797          	auipc	a5,0x0
    80000bca:	f1278793          	addi	a5,a5,-238 # 80000ad8 <forkret>
    80000bce:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80000bd0:	60bc                	ld	a5,64(s1)
    80000bd2:	6705                	lui	a4,0x1
    80000bd4:	97ba                	add	a5,a5,a4
    80000bd6:	f4bc                	sd	a5,104(s1)
}
    80000bd8:	8526                	mv	a0,s1
    80000bda:	60e2                	ld	ra,24(sp)
    80000bdc:	6442                	ld	s0,16(sp)
    80000bde:	64a2                	ld	s1,8(sp)
    80000be0:	6902                	ld	s2,0(sp)
    80000be2:	6105                	addi	sp,sp,32
    80000be4:	8082                	ret
  kfree((void*)p->kstack);
    80000be6:	60a8                	ld	a0,64(s1)
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	8be080e7          	jalr	-1858(ra) # 800004a6 <kfree>
  p->kstack = 0;
    80000bf0:	0404b023          	sd	zero,64(s1)
  p->sz = 0;
    80000bf4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000bf8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000bfc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000c00:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000c04:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000c08:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000c0c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000c10:	0004ac23          	sw	zero,24(s1)
    release(&p->lock);
    80000c14:	8526                	mv	a0,s1
    80000c16:	00000097          	auipc	ra,0x0
    80000c1a:	b32080e7          	jalr	-1230(ra) # 80000748 <release>
    return 0;
    80000c1e:	84ca                	mv	s1,s2
    80000c20:	bf65                	j	80000bd8 <allocproc+0x88>
  kfree((void*)p->kstack);
    80000c22:	60a8                	ld	a0,64(s1)
    80000c24:	00000097          	auipc	ra,0x0
    80000c28:	882080e7          	jalr	-1918(ra) # 800004a6 <kfree>
  p->kstack = 0;
    80000c2c:	0404b023          	sd	zero,64(s1)
  p->sz = 0;
    80000c30:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000c34:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000c38:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000c3c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000c40:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000c44:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000c48:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000c4c:	0004ac23          	sw	zero,24(s1)
    release(&p->lock);
    80000c50:	8526                	mv	a0,s1
    80000c52:	00000097          	auipc	ra,0x0
    80000c56:	af6080e7          	jalr	-1290(ra) # 80000748 <release>
    return 0;
    80000c5a:	84ca                	mv	s1,s2
    80000c5c:	bfb5                	j	80000bd8 <allocproc+0x88>

0000000080000c5e <growproc>:
{
    80000c5e:	1141                	addi	sp,sp,-16
    80000c60:	e406                	sd	ra,8(sp)
    80000c62:	e022                	sd	s0,0(sp)
    80000c64:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	e3a080e7          	jalr	-454(ra) # 80000aa0 <myproc>
}
    80000c6e:	4501                	li	a0,0
    80000c70:	60a2                	ld	ra,8(sp)
    80000c72:	6402                	ld	s0,0(sp)
    80000c74:	0141                	addi	sp,sp,16
    80000c76:	8082                	ret

0000000080000c78 <fork>:
{
    80000c78:	7139                	addi	sp,sp,-64
    80000c7a:	fc06                	sd	ra,56(sp)
    80000c7c:	f822                	sd	s0,48(sp)
    80000c7e:	f426                	sd	s1,40(sp)
    80000c80:	f04a                	sd	s2,32(sp)
    80000c82:	ec4e                	sd	s3,24(sp)
    80000c84:	e852                	sd	s4,16(sp)
    80000c86:	e456                	sd	s5,8(sp)
    80000c88:	e05a                	sd	s6,0(sp)
    80000c8a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80000c8c:	00000097          	auipc	ra,0x0
    80000c90:	e14080e7          	jalr	-492(ra) # 80000aa0 <myproc>
    80000c94:	8b2a                	mv	s6,a0
  if((np = allocproc()) == 0){
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	eba080e7          	jalr	-326(ra) # 80000b50 <allocproc>
    80000c9e:	c561                	beqz	a0,80000d66 <fork+0xee>
    80000ca0:	89aa                	mv	s3,a0
  np->sz = p->sz;
    80000ca2:	048b3783          	ld	a5,72(s6)
    80000ca6:	e53c                	sd	a5,72(a0)
  *(np->trapframe) = *(p->trapframe);
    80000ca8:	058b3683          	ld	a3,88(s6)
    80000cac:	87b6                	mv	a5,a3
    80000cae:	6d38                	ld	a4,88(a0)
    80000cb0:	12068693          	addi	a3,a3,288
    80000cb4:	0007b803          	ld	a6,0(a5)
    80000cb8:	6788                	ld	a0,8(a5)
    80000cba:	6b8c                	ld	a1,16(a5)
    80000cbc:	6f90                	ld	a2,24(a5)
    80000cbe:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80000cc2:	e708                	sd	a0,8(a4)
    80000cc4:	eb0c                	sd	a1,16(a4)
    80000cc6:	ef10                	sd	a2,24(a4)
    80000cc8:	02078793          	addi	a5,a5,32
    80000ccc:	02070713          	addi	a4,a4,32
    80000cd0:	fed792e3          	bne	a5,a3,80000cb4 <fork+0x3c>
  np->trapframe->a0 = 0;
    80000cd4:	0589b783          	ld	a5,88(s3)
    80000cd8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80000cdc:	0d0b0493          	addi	s1,s6,208
    80000ce0:	150b0913          	addi	s2,s6,336
  safestrcpy(np->name, p->name, sizeof(p->name));
    80000ce4:	158b0a93          	addi	s5,s6,344
    80000ce8:	15898a13          	addi	s4,s3,344
    80000cec:	a021                	j	80000cf4 <fork+0x7c>
  for(i = 0; i < NOFILE; i++)
    80000cee:	04a1                	addi	s1,s1,8
    80000cf0:	01248c63          	beq	s1,s2,80000d08 <fork+0x90>
    if(p->ofile[i])
    80000cf4:	609c                	ld	a5,0(s1)
    80000cf6:	dfe5                	beqz	a5,80000cee <fork+0x76>
  safestrcpy(np->name, p->name, sizeof(p->name));
    80000cf8:	4641                	li	a2,16
    80000cfa:	85d6                	mv	a1,s5
    80000cfc:	8552                	mv	a0,s4
    80000cfe:	00000097          	auipc	ra,0x0
    80000d02:	bdc080e7          	jalr	-1060(ra) # 800008da <safestrcpy>
    80000d06:	b7e5                	j	80000cee <fork+0x76>
  pid = np->pid;
    80000d08:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80000d0c:	854e                	mv	a0,s3
    80000d0e:	00000097          	auipc	ra,0x0
    80000d12:	a3a080e7          	jalr	-1478(ra) # 80000748 <release>
  acquire(&wait_lock);
    80000d16:	0000a497          	auipc	s1,0xa
    80000d1a:	80248493          	addi	s1,s1,-2046 # 8000a518 <wait_lock>
    80000d1e:	8526                	mv	a0,s1
    80000d20:	00000097          	auipc	ra,0x0
    80000d24:	974080e7          	jalr	-1676(ra) # 80000694 <acquire>
  np->parent = p;
    80000d28:	0369bc23          	sd	s6,56(s3)
  release(&wait_lock);
    80000d2c:	8526                	mv	a0,s1
    80000d2e:	00000097          	auipc	ra,0x0
    80000d32:	a1a080e7          	jalr	-1510(ra) # 80000748 <release>
  acquire(&np->lock);
    80000d36:	854e                	mv	a0,s3
    80000d38:	00000097          	auipc	ra,0x0
    80000d3c:	95c080e7          	jalr	-1700(ra) # 80000694 <acquire>
  np->state = RUNNABLE;
    80000d40:	478d                	li	a5,3
    80000d42:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80000d46:	854e                	mv	a0,s3
    80000d48:	00000097          	auipc	ra,0x0
    80000d4c:	a00080e7          	jalr	-1536(ra) # 80000748 <release>
}
    80000d50:	854a                	mv	a0,s2
    80000d52:	70e2                	ld	ra,56(sp)
    80000d54:	7442                	ld	s0,48(sp)
    80000d56:	74a2                	ld	s1,40(sp)
    80000d58:	7902                	ld	s2,32(sp)
    80000d5a:	69e2                	ld	s3,24(sp)
    80000d5c:	6a42                	ld	s4,16(sp)
    80000d5e:	6aa2                	ld	s5,8(sp)
    80000d60:	6b02                	ld	s6,0(sp)
    80000d62:	6121                	addi	sp,sp,64
    80000d64:	8082                	ret
    return -1;
    80000d66:	597d                	li	s2,-1
    80000d68:	b7e5                	j	80000d50 <fork+0xd8>

0000000080000d6a <scheduler>:
{
    80000d6a:	7139                	addi	sp,sp,-64
    80000d6c:	fc06                	sd	ra,56(sp)
    80000d6e:	f822                	sd	s0,48(sp)
    80000d70:	f426                	sd	s1,40(sp)
    80000d72:	f04a                	sd	s2,32(sp)
    80000d74:	ec4e                	sd	s3,24(sp)
    80000d76:	e852                	sd	s4,16(sp)
    80000d78:	e456                	sd	s5,8(sp)
    80000d7a:	e05a                	sd	s6,0(sp)
    80000d7c:	0080                	addi	s0,sp,64
    80000d7e:	8792                	mv	a5,tp
  int id = r_tp();
    80000d80:	2781                	sext.w	a5,a5
  c->proc = 0;
    80000d82:	00779a93          	slli	s5,a5,0x7
    80000d86:	00009717          	auipc	a4,0x9
    80000d8a:	77a70713          	addi	a4,a4,1914 # 8000a500 <pid_lock>
    80000d8e:	9756                	add	a4,a4,s5
    80000d90:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80000d94:	00009717          	auipc	a4,0x9
    80000d98:	7a470713          	addi	a4,a4,1956 # 8000a538 <cpus+0x8>
    80000d9c:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80000d9e:	498d                	li	s3,3
        p->state = RUNNING;
    80000da0:	4b11                	li	s6,4
        c->proc = p;
    80000da2:	079e                	slli	a5,a5,0x7
    80000da4:	00009a17          	auipc	s4,0x9
    80000da8:	75ca0a13          	addi	s4,s4,1884 # 8000a500 <pid_lock>
    80000dac:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80000dae:	0000f917          	auipc	s2,0xf
    80000db2:	58290913          	addi	s2,s2,1410 # 80010330 <end>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000db6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000dba:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000dbe:	10079073          	csrw	sstatus,a5
    80000dc2:	0000a497          	auipc	s1,0xa
    80000dc6:	b6e48493          	addi	s1,s1,-1170 # 8000a930 <proc>
    80000dca:	a811                	j	80000dde <scheduler+0x74>
      release(&p->lock);
    80000dcc:	8526                	mv	a0,s1
    80000dce:	00000097          	auipc	ra,0x0
    80000dd2:	97a080e7          	jalr	-1670(ra) # 80000748 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80000dd6:	16848493          	addi	s1,s1,360
    80000dda:	fd248ee3          	beq	s1,s2,80000db6 <scheduler+0x4c>
      acquire(&p->lock);
    80000dde:	8526                	mv	a0,s1
    80000de0:	00000097          	auipc	ra,0x0
    80000de4:	8b4080e7          	jalr	-1868(ra) # 80000694 <acquire>
      if(p->state == RUNNABLE) {
    80000de8:	4c9c                	lw	a5,24(s1)
    80000dea:	ff3791e3          	bne	a5,s3,80000dcc <scheduler+0x62>
        p->state = RUNNING;
    80000dee:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80000df2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80000df6:	06048593          	addi	a1,s1,96
    80000dfa:	8556                	mv	a0,s5
    80000dfc:	00000097          	auipc	ra,0x0
    80000e00:	672080e7          	jalr	1650(ra) # 8000146e <swtch>
        c->proc = 0;
    80000e04:	020a3823          	sd	zero,48(s4)
    80000e08:	b7d1                	j	80000dcc <scheduler+0x62>

0000000080000e0a <sched>:
{
    80000e0a:	7179                	addi	sp,sp,-48
    80000e0c:	f406                	sd	ra,40(sp)
    80000e0e:	f022                	sd	s0,32(sp)
    80000e10:	ec26                	sd	s1,24(sp)
    80000e12:	e84a                	sd	s2,16(sp)
    80000e14:	e44e                	sd	s3,8(sp)
    80000e16:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80000e18:	00000097          	auipc	ra,0x0
    80000e1c:	c88080e7          	jalr	-888(ra) # 80000aa0 <myproc>
    80000e20:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80000e22:	fffff097          	auipc	ra,0xfffff
    80000e26:	7f8080e7          	jalr	2040(ra) # 8000061a <holding>
    80000e2a:	c93d                	beqz	a0,80000ea0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e2c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80000e2e:	2781                	sext.w	a5,a5
    80000e30:	079e                	slli	a5,a5,0x7
    80000e32:	00009717          	auipc	a4,0x9
    80000e36:	6ce70713          	addi	a4,a4,1742 # 8000a500 <pid_lock>
    80000e3a:	97ba                	add	a5,a5,a4
    80000e3c:	0a87a703          	lw	a4,168(a5)
    80000e40:	4785                	li	a5,1
    80000e42:	06f71763          	bne	a4,a5,80000eb0 <sched+0xa6>
  if(p->state == RUNNING)
    80000e46:	4c98                	lw	a4,24(s1)
    80000e48:	4791                	li	a5,4
    80000e4a:	06f70b63          	beq	a4,a5,80000ec0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e54:	efb5                	bnez	a5,80000ed0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e56:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80000e58:	00009917          	auipc	s2,0x9
    80000e5c:	6a890913          	addi	s2,s2,1704 # 8000a500 <pid_lock>
    80000e60:	2781                	sext.w	a5,a5
    80000e62:	079e                	slli	a5,a5,0x7
    80000e64:	97ca                	add	a5,a5,s2
    80000e66:	0ac7a983          	lw	s3,172(a5)
    80000e6a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80000e6c:	2781                	sext.w	a5,a5
    80000e6e:	079e                	slli	a5,a5,0x7
    80000e70:	00009597          	auipc	a1,0x9
    80000e74:	6c858593          	addi	a1,a1,1736 # 8000a538 <cpus+0x8>
    80000e78:	95be                	add	a1,a1,a5
    80000e7a:	06048513          	addi	a0,s1,96
    80000e7e:	00000097          	auipc	ra,0x0
    80000e82:	5f0080e7          	jalr	1520(ra) # 8000146e <swtch>
    80000e86:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	079e                	slli	a5,a5,0x7
    80000e8c:	993e                	add	s2,s2,a5
    80000e8e:	0b392623          	sw	s3,172(s2)
}
    80000e92:	70a2                	ld	ra,40(sp)
    80000e94:	7402                	ld	s0,32(sp)
    80000e96:	64e2                	ld	s1,24(sp)
    80000e98:	6942                	ld	s2,16(sp)
    80000e9a:	69a2                	ld	s3,8(sp)
    80000e9c:	6145                	addi	sp,sp,48
    80000e9e:	8082                	ret
    panic("sched p->lock");
    80000ea0:	00001517          	auipc	a0,0x1
    80000ea4:	24850513          	addi	a0,a0,584 # 800020e8 <digits+0xb8>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	2ea080e7          	jalr	746(ra) # 80000192 <panic>
    panic("sched locks");
    80000eb0:	00001517          	auipc	a0,0x1
    80000eb4:	24850513          	addi	a0,a0,584 # 800020f8 <digits+0xc8>
    80000eb8:	fffff097          	auipc	ra,0xfffff
    80000ebc:	2da080e7          	jalr	730(ra) # 80000192 <panic>
    panic("sched running");
    80000ec0:	00001517          	auipc	a0,0x1
    80000ec4:	24850513          	addi	a0,a0,584 # 80002108 <digits+0xd8>
    80000ec8:	fffff097          	auipc	ra,0xfffff
    80000ecc:	2ca080e7          	jalr	714(ra) # 80000192 <panic>
    panic("sched interruptible");
    80000ed0:	00001517          	auipc	a0,0x1
    80000ed4:	24850513          	addi	a0,a0,584 # 80002118 <digits+0xe8>
    80000ed8:	fffff097          	auipc	ra,0xfffff
    80000edc:	2ba080e7          	jalr	698(ra) # 80000192 <panic>

0000000080000ee0 <yield>:
{
    80000ee0:	1101                	addi	sp,sp,-32
    80000ee2:	ec06                	sd	ra,24(sp)
    80000ee4:	e822                	sd	s0,16(sp)
    80000ee6:	e426                	sd	s1,8(sp)
    80000ee8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80000eea:	00000097          	auipc	ra,0x0
    80000eee:	bb6080e7          	jalr	-1098(ra) # 80000aa0 <myproc>
    80000ef2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80000ef4:	fffff097          	auipc	ra,0xfffff
    80000ef8:	7a0080e7          	jalr	1952(ra) # 80000694 <acquire>
  p->state = RUNNABLE;
    80000efc:	478d                	li	a5,3
    80000efe:	cc9c                	sw	a5,24(s1)
  sched();
    80000f00:	00000097          	auipc	ra,0x0
    80000f04:	f0a080e7          	jalr	-246(ra) # 80000e0a <sched>
  release(&p->lock);
    80000f08:	8526                	mv	a0,s1
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	83e080e7          	jalr	-1986(ra) # 80000748 <release>
}
    80000f12:	60e2                	ld	ra,24(sp)
    80000f14:	6442                	ld	s0,16(sp)
    80000f16:	64a2                	ld	s1,8(sp)
    80000f18:	6105                	addi	sp,sp,32
    80000f1a:	8082                	ret

0000000080000f1c <userinit>:

void
userinit(void)
{
    80000f1c:	7179                	addi	sp,sp,-48
    80000f1e:	f406                	sd	ra,40(sp)
    80000f20:	f022                	sd	s0,32(sp)
    80000f22:	ec26                	sd	s1,24(sp)
    80000f24:	e84a                	sd	s2,16(sp)
    80000f26:	e44e                	sd	s3,8(sp)
    80000f28:	e052                	sd	s4,0(sp)
    80000f2a:	1800                	addi	s0,sp,48
  // Thread 1
  struct proc *p;

  p = allocproc();
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	c24080e7          	jalr	-988(ra) # 80000b50 <allocproc>
    80000f34:	89aa                	mv	s3,a0
  initproc = p;
    80000f36:	00001a17          	auipc	s4,0x1
    80000f3a:	35aa0a13          	addi	s4,s4,858 # 80002290 <initproc>
    80000f3e:	00aa3023          	sd	a0,0(s4)

  // Thread 2
  struct proc *m;

  m = allocproc();
    80000f42:	00000097          	auipc	ra,0x0
    80000f46:	c0e080e7          	jalr	-1010(ra) # 80000b50 <allocproc>
    80000f4a:	892a                	mv	s2,a0
  initproc = m;
    80000f4c:	00aa3023          	sd	a0,0(s4)

  // Thread 3
  struct proc *b;

  b = allocproc();
    80000f50:	00000097          	auipc	ra,0x0
    80000f54:	c00080e7          	jalr	-1024(ra) # 80000b50 <allocproc>
    80000f58:	84aa                	mv	s1,a0
  initproc = b;
    80000f5a:	00aa3023          	sd	a0,0(s4)
  
  // allocate one user page and copy initcode's instructions
  // and data into it.
  p->sz = PGSIZE;
    80000f5e:	6785                	lui	a5,0x1
    80000f60:	04f9b423          	sd	a5,72(s3)
  m->sz = PGSIZE;
    80000f64:	04f93423          	sd	a5,72(s2)
  b->sz = PGSIZE;
    80000f68:	e53c                	sd	a5,72(a0)
  // prepare for the very first "return" from kernel to user.

  safestrcpy(p->name, "initcode", sizeof(p->name));
    80000f6a:	4641                	li	a2,16
    80000f6c:	00001597          	auipc	a1,0x1
    80000f70:	1c458593          	addi	a1,a1,452 # 80002130 <digits+0x100>
    80000f74:	15898513          	addi	a0,s3,344
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	962080e7          	jalr	-1694(ra) # 800008da <safestrcpy>
  safestrcpy(m->name, "initcode", sizeof(m->name));
    80000f80:	4641                	li	a2,16
    80000f82:	00001597          	auipc	a1,0x1
    80000f86:	1ae58593          	addi	a1,a1,430 # 80002130 <digits+0x100>
    80000f8a:	15890513          	addi	a0,s2,344
    80000f8e:	00000097          	auipc	ra,0x0
    80000f92:	94c080e7          	jalr	-1716(ra) # 800008da <safestrcpy>
  safestrcpy(b->name, "initcode", sizeof(b->name));
    80000f96:	4641                	li	a2,16
    80000f98:	00001597          	auipc	a1,0x1
    80000f9c:	19858593          	addi	a1,a1,408 # 80002130 <digits+0x100>
    80000fa0:	15848513          	addi	a0,s1,344
    80000fa4:	00000097          	auipc	ra,0x0
    80000fa8:	936080e7          	jalr	-1738(ra) # 800008da <safestrcpy>

  p->state = RUNNABLE;
    80000fac:	478d                	li	a5,3
    80000fae:	00f9ac23          	sw	a5,24(s3)
  m->state = RUNNABLE;
    80000fb2:	00f92c23          	sw	a5,24(s2)
  b->state = RUNNABLE;
    80000fb6:	cc9c                	sw	a5,24(s1)

  release(&p->lock);
    80000fb8:	854e                	mv	a0,s3
    80000fba:	fffff097          	auipc	ra,0xfffff
    80000fbe:	78e080e7          	jalr	1934(ra) # 80000748 <release>
  release(&m->lock);
    80000fc2:	854a                	mv	a0,s2
    80000fc4:	fffff097          	auipc	ra,0xfffff
    80000fc8:	784080e7          	jalr	1924(ra) # 80000748 <release>
  release(&b->lock);
    80000fcc:	8526                	mv	a0,s1
    80000fce:	fffff097          	auipc	ra,0xfffff
    80000fd2:	77a080e7          	jalr	1914(ra) # 80000748 <release>
}
    80000fd6:	70a2                	ld	ra,40(sp)
    80000fd8:	7402                	ld	s0,32(sp)
    80000fda:	64e2                	ld	s1,24(sp)
    80000fdc:	6942                	ld	s2,16(sp)
    80000fde:	69a2                	ld	s3,8(sp)
    80000fe0:	6a02                	ld	s4,0(sp)
    80000fe2:	6145                	addi	sp,sp,48
    80000fe4:	8082                	ret

0000000080000fe6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80000fe6:	7179                	addi	sp,sp,-48
    80000fe8:	f406                	sd	ra,40(sp)
    80000fea:	f022                	sd	s0,32(sp)
    80000fec:	ec26                	sd	s1,24(sp)
    80000fee:	e84a                	sd	s2,16(sp)
    80000ff0:	e44e                	sd	s3,8(sp)
    80000ff2:	1800                	addi	s0,sp,48
    80000ff4:	89aa                	mv	s3,a0
    80000ff6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80000ff8:	00000097          	auipc	ra,0x0
    80000ffc:	aa8080e7          	jalr	-1368(ra) # 80000aa0 <myproc>
    80001000:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001002:	fffff097          	auipc	ra,0xfffff
    80001006:	692080e7          	jalr	1682(ra) # 80000694 <acquire>
  release(lk);
    8000100a:	854a                	mv	a0,s2
    8000100c:	fffff097          	auipc	ra,0xfffff
    80001010:	73c080e7          	jalr	1852(ra) # 80000748 <release>

  // Go to sleep.
  p->chan = chan;
    80001014:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001018:	4789                	li	a5,2
    8000101a:	cc9c                	sw	a5,24(s1)

  sched();
    8000101c:	00000097          	auipc	ra,0x0
    80001020:	dee080e7          	jalr	-530(ra) # 80000e0a <sched>

  // Tidy up.
  p->chan = 0;
    80001024:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001028:	8526                	mv	a0,s1
    8000102a:	fffff097          	auipc	ra,0xfffff
    8000102e:	71e080e7          	jalr	1822(ra) # 80000748 <release>
  acquire(lk);
    80001032:	854a                	mv	a0,s2
    80001034:	fffff097          	auipc	ra,0xfffff
    80001038:	660080e7          	jalr	1632(ra) # 80000694 <acquire>
}
    8000103c:	70a2                	ld	ra,40(sp)
    8000103e:	7402                	ld	s0,32(sp)
    80001040:	64e2                	ld	s1,24(sp)
    80001042:	6942                	ld	s2,16(sp)
    80001044:	69a2                	ld	s3,8(sp)
    80001046:	6145                	addi	sp,sp,48
    80001048:	8082                	ret

000000008000104a <wait>:
{
    8000104a:	7139                	addi	sp,sp,-64
    8000104c:	fc06                	sd	ra,56(sp)
    8000104e:	f822                	sd	s0,48(sp)
    80001050:	f426                	sd	s1,40(sp)
    80001052:	f04a                	sd	s2,32(sp)
    80001054:	ec4e                	sd	s3,24(sp)
    80001056:	e852                	sd	s4,16(sp)
    80001058:	e456                	sd	s5,8(sp)
    8000105a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000105c:	00000097          	auipc	ra,0x0
    80001060:	a44080e7          	jalr	-1468(ra) # 80000aa0 <myproc>
    80001064:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001066:	00009517          	auipc	a0,0x9
    8000106a:	4b250513          	addi	a0,a0,1202 # 8000a518 <wait_lock>
    8000106e:	fffff097          	auipc	ra,0xfffff
    80001072:	626080e7          	jalr	1574(ra) # 80000694 <acquire>
        if(pp->state == ZOMBIE){
    80001076:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001078:	0000f997          	auipc	s3,0xf
    8000107c:	2b898993          	addi	s3,s3,696 # 80010330 <end>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001080:	00009a97          	auipc	s5,0x9
    80001084:	498a8a93          	addi	s5,s5,1176 # 8000a518 <wait_lock>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001088:	0000a497          	auipc	s1,0xa
    8000108c:	8a848493          	addi	s1,s1,-1880 # 8000a930 <proc>
    80001090:	a029                	j	8000109a <wait+0x50>
    80001092:	16848493          	addi	s1,s1,360
    80001096:	03348363          	beq	s1,s3,800010bc <wait+0x72>
      if(pp->parent == p){
    8000109a:	7c9c                	ld	a5,56(s1)
    8000109c:	ff279be3          	bne	a5,s2,80001092 <wait+0x48>
        acquire(&pp->lock);
    800010a0:	8526                	mv	a0,s1
    800010a2:	fffff097          	auipc	ra,0xfffff
    800010a6:	5f2080e7          	jalr	1522(ra) # 80000694 <acquire>
        if(pp->state == ZOMBIE){
    800010aa:	4c9c                	lw	a5,24(s1)
    800010ac:	01478f63          	beq	a5,s4,800010ca <wait+0x80>
        release(&pp->lock);
    800010b0:	8526                	mv	a0,s1
    800010b2:	fffff097          	auipc	ra,0xfffff
    800010b6:	696080e7          	jalr	1686(ra) # 80000748 <release>
    800010ba:	bfe1                	j	80001092 <wait+0x48>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800010bc:	85d6                	mv	a1,s5
    800010be:	854a                	mv	a0,s2
    800010c0:	00000097          	auipc	ra,0x0
    800010c4:	f26080e7          	jalr	-218(ra) # 80000fe6 <sleep>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800010c8:	b7c1                	j	80001088 <wait+0x3e>
            release(&pp->lock);
    800010ca:	8526                	mv	a0,s1
    800010cc:	fffff097          	auipc	ra,0xfffff
    800010d0:	67c080e7          	jalr	1660(ra) # 80000748 <release>
            release(&wait_lock);
    800010d4:	00009517          	auipc	a0,0x9
    800010d8:	44450513          	addi	a0,a0,1092 # 8000a518 <wait_lock>
    800010dc:	fffff097          	auipc	ra,0xfffff
    800010e0:	66c080e7          	jalr	1644(ra) # 80000748 <release>
}
    800010e4:	557d                	li	a0,-1
    800010e6:	70e2                	ld	ra,56(sp)
    800010e8:	7442                	ld	s0,48(sp)
    800010ea:	74a2                	ld	s1,40(sp)
    800010ec:	7902                	ld	s2,32(sp)
    800010ee:	69e2                	ld	s3,24(sp)
    800010f0:	6a42                	ld	s4,16(sp)
    800010f2:	6aa2                	ld	s5,8(sp)
    800010f4:	6121                	addi	sp,sp,64
    800010f6:	8082                	ret

00000000800010f8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800010f8:	7139                	addi	sp,sp,-64
    800010fa:	fc06                	sd	ra,56(sp)
    800010fc:	f822                	sd	s0,48(sp)
    800010fe:	f426                	sd	s1,40(sp)
    80001100:	f04a                	sd	s2,32(sp)
    80001102:	ec4e                	sd	s3,24(sp)
    80001104:	e852                	sd	s4,16(sp)
    80001106:	e456                	sd	s5,8(sp)
    80001108:	0080                	addi	s0,sp,64
    8000110a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000110c:	0000a497          	auipc	s1,0xa
    80001110:	82448493          	addi	s1,s1,-2012 # 8000a930 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001114:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001116:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001118:	0000f917          	auipc	s2,0xf
    8000111c:	21890913          	addi	s2,s2,536 # 80010330 <end>
    80001120:	a811                	j	80001134 <wakeup+0x3c>
      }
      release(&p->lock);
    80001122:	8526                	mv	a0,s1
    80001124:	fffff097          	auipc	ra,0xfffff
    80001128:	624080e7          	jalr	1572(ra) # 80000748 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000112c:	16848493          	addi	s1,s1,360
    80001130:	03248663          	beq	s1,s2,8000115c <wakeup+0x64>
    if(p != myproc()){
    80001134:	00000097          	auipc	ra,0x0
    80001138:	96c080e7          	jalr	-1684(ra) # 80000aa0 <myproc>
    8000113c:	fea488e3          	beq	s1,a0,8000112c <wakeup+0x34>
      acquire(&p->lock);
    80001140:	8526                	mv	a0,s1
    80001142:	fffff097          	auipc	ra,0xfffff
    80001146:	552080e7          	jalr	1362(ra) # 80000694 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000114a:	4c9c                	lw	a5,24(s1)
    8000114c:	fd379be3          	bne	a5,s3,80001122 <wakeup+0x2a>
    80001150:	709c                	ld	a5,32(s1)
    80001152:	fd4798e3          	bne	a5,s4,80001122 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001156:	0154ac23          	sw	s5,24(s1)
    8000115a:	b7e1                	j	80001122 <wakeup+0x2a>
    }
  }
}
    8000115c:	70e2                	ld	ra,56(sp)
    8000115e:	7442                	ld	s0,48(sp)
    80001160:	74a2                	ld	s1,40(sp)
    80001162:	7902                	ld	s2,32(sp)
    80001164:	69e2                	ld	s3,24(sp)
    80001166:	6a42                	ld	s4,16(sp)
    80001168:	6aa2                	ld	s5,8(sp)
    8000116a:	6121                	addi	sp,sp,64
    8000116c:	8082                	ret

000000008000116e <reparent>:
{
    8000116e:	7179                	addi	sp,sp,-48
    80001170:	f406                	sd	ra,40(sp)
    80001172:	f022                	sd	s0,32(sp)
    80001174:	ec26                	sd	s1,24(sp)
    80001176:	e84a                	sd	s2,16(sp)
    80001178:	e44e                	sd	s3,8(sp)
    8000117a:	e052                	sd	s4,0(sp)
    8000117c:	1800                	addi	s0,sp,48
    8000117e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001180:	00009497          	auipc	s1,0x9
    80001184:	7b048493          	addi	s1,s1,1968 # 8000a930 <proc>
      pp->parent = initproc;
    80001188:	00001a17          	auipc	s4,0x1
    8000118c:	108a0a13          	addi	s4,s4,264 # 80002290 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001190:	0000f997          	auipc	s3,0xf
    80001194:	1a098993          	addi	s3,s3,416 # 80010330 <end>
    80001198:	a029                	j	800011a2 <reparent+0x34>
    8000119a:	16848493          	addi	s1,s1,360
    8000119e:	01348d63          	beq	s1,s3,800011b8 <reparent+0x4a>
    if(pp->parent == p){
    800011a2:	7c9c                	ld	a5,56(s1)
    800011a4:	ff279be3          	bne	a5,s2,8000119a <reparent+0x2c>
      pp->parent = initproc;
    800011a8:	000a3503          	ld	a0,0(s4)
    800011ac:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f4a080e7          	jalr	-182(ra) # 800010f8 <wakeup>
    800011b6:	b7d5                	j	8000119a <reparent+0x2c>
}
    800011b8:	70a2                	ld	ra,40(sp)
    800011ba:	7402                	ld	s0,32(sp)
    800011bc:	64e2                	ld	s1,24(sp)
    800011be:	6942                	ld	s2,16(sp)
    800011c0:	69a2                	ld	s3,8(sp)
    800011c2:	6a02                	ld	s4,0(sp)
    800011c4:	6145                	addi	sp,sp,48
    800011c6:	8082                	ret

00000000800011c8 <exit>:
{
    800011c8:	7179                	addi	sp,sp,-48
    800011ca:	f406                	sd	ra,40(sp)
    800011cc:	f022                	sd	s0,32(sp)
    800011ce:	ec26                	sd	s1,24(sp)
    800011d0:	e84a                	sd	s2,16(sp)
    800011d2:	e44e                	sd	s3,8(sp)
    800011d4:	1800                	addi	s0,sp,48
    800011d6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800011d8:	00000097          	auipc	ra,0x0
    800011dc:	8c8080e7          	jalr	-1848(ra) # 80000aa0 <myproc>
    800011e0:	84aa                	mv	s1,a0
  if(p == initproc)
    800011e2:	00001717          	auipc	a4,0x1
    800011e6:	0ae73703          	ld	a4,174(a4) # 80002290 <initproc>
    800011ea:	0d050793          	addi	a5,a0,208
    800011ee:	15050693          	addi	a3,a0,336
    800011f2:	00a71d63          	bne	a4,a0,8000120c <exit+0x44>
    panic("init exiting");
    800011f6:	00001517          	auipc	a0,0x1
    800011fa:	f4a50513          	addi	a0,a0,-182 # 80002140 <digits+0x110>
    800011fe:	fffff097          	auipc	ra,0xfffff
    80001202:	f94080e7          	jalr	-108(ra) # 80000192 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80001206:	07a1                	addi	a5,a5,8 # 1008 <_entry-0x7fffeff8>
    80001208:	00d78763          	beq	a5,a3,80001216 <exit+0x4e>
    if(p->ofile[fd]){
    8000120c:	6398                	ld	a4,0(a5)
    8000120e:	df65                	beqz	a4,80001206 <exit+0x3e>
      p->ofile[fd] = 0;
    80001210:	0007b023          	sd	zero,0(a5)
    80001214:	bfcd                	j	80001206 <exit+0x3e>
  p->cwd = 0;
    80001216:	1404b823          	sd	zero,336(s1)
  acquire(&wait_lock);
    8000121a:	00009997          	auipc	s3,0x9
    8000121e:	2fe98993          	addi	s3,s3,766 # 8000a518 <wait_lock>
    80001222:	854e                	mv	a0,s3
    80001224:	fffff097          	auipc	ra,0xfffff
    80001228:	470080e7          	jalr	1136(ra) # 80000694 <acquire>
  reparent(p);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	f40080e7          	jalr	-192(ra) # 8000116e <reparent>
  wakeup(p->parent);
    80001236:	7c88                	ld	a0,56(s1)
    80001238:	00000097          	auipc	ra,0x0
    8000123c:	ec0080e7          	jalr	-320(ra) # 800010f8 <wakeup>
  acquire(&p->lock);
    80001240:	8526                	mv	a0,s1
    80001242:	fffff097          	auipc	ra,0xfffff
    80001246:	452080e7          	jalr	1106(ra) # 80000694 <acquire>
  p->xstate = status;
    8000124a:	0324a623          	sw	s2,44(s1)
  p->state = ZOMBIE;
    8000124e:	4795                	li	a5,5
    80001250:	cc9c                	sw	a5,24(s1)
  release(&wait_lock);
    80001252:	854e                	mv	a0,s3
    80001254:	fffff097          	auipc	ra,0xfffff
    80001258:	4f4080e7          	jalr	1268(ra) # 80000748 <release>
  sched();
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	bae080e7          	jalr	-1106(ra) # 80000e0a <sched>
  panic("zombie exit");
    80001264:	00001517          	auipc	a0,0x1
    80001268:	eec50513          	addi	a0,a0,-276 # 80002150 <digits+0x120>
    8000126c:	fffff097          	auipc	ra,0xfffff
    80001270:	f26080e7          	jalr	-218(ra) # 80000192 <panic>

0000000080001274 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001274:	7179                	addi	sp,sp,-48
    80001276:	f406                	sd	ra,40(sp)
    80001278:	f022                	sd	s0,32(sp)
    8000127a:	ec26                	sd	s1,24(sp)
    8000127c:	e84a                	sd	s2,16(sp)
    8000127e:	e44e                	sd	s3,8(sp)
    80001280:	1800                	addi	s0,sp,48
    80001282:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001284:	00009497          	auipc	s1,0x9
    80001288:	6ac48493          	addi	s1,s1,1708 # 8000a930 <proc>
    8000128c:	0000f997          	auipc	s3,0xf
    80001290:	0a498993          	addi	s3,s3,164 # 80010330 <end>
    acquire(&p->lock);
    80001294:	8526                	mv	a0,s1
    80001296:	fffff097          	auipc	ra,0xfffff
    8000129a:	3fe080e7          	jalr	1022(ra) # 80000694 <acquire>
    if(p->pid == pid){
    8000129e:	589c                	lw	a5,48(s1)
    800012a0:	01278d63          	beq	a5,s2,800012ba <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800012a4:	8526                	mv	a0,s1
    800012a6:	fffff097          	auipc	ra,0xfffff
    800012aa:	4a2080e7          	jalr	1186(ra) # 80000748 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800012ae:	16848493          	addi	s1,s1,360
    800012b2:	ff3491e3          	bne	s1,s3,80001294 <kill+0x20>
  }
  return -1;
    800012b6:	557d                	li	a0,-1
    800012b8:	a829                	j	800012d2 <kill+0x5e>
      p->killed = 1;
    800012ba:	4785                	li	a5,1
    800012bc:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800012be:	4c98                	lw	a4,24(s1)
    800012c0:	4789                	li	a5,2
    800012c2:	00f70f63          	beq	a4,a5,800012e0 <kill+0x6c>
      release(&p->lock);
    800012c6:	8526                	mv	a0,s1
    800012c8:	fffff097          	auipc	ra,0xfffff
    800012cc:	480080e7          	jalr	1152(ra) # 80000748 <release>
      return 0;
    800012d0:	4501                	li	a0,0
}
    800012d2:	70a2                	ld	ra,40(sp)
    800012d4:	7402                	ld	s0,32(sp)
    800012d6:	64e2                	ld	s1,24(sp)
    800012d8:	6942                	ld	s2,16(sp)
    800012da:	69a2                	ld	s3,8(sp)
    800012dc:	6145                	addi	sp,sp,48
    800012de:	8082                	ret
        p->state = RUNNABLE;
    800012e0:	478d                	li	a5,3
    800012e2:	cc9c                	sw	a5,24(s1)
    800012e4:	b7cd                	j	800012c6 <kill+0x52>

00000000800012e6 <setkilled>:

void
setkilled(struct proc *p)
{
    800012e6:	1101                	addi	sp,sp,-32
    800012e8:	ec06                	sd	ra,24(sp)
    800012ea:	e822                	sd	s0,16(sp)
    800012ec:	e426                	sd	s1,8(sp)
    800012ee:	1000                	addi	s0,sp,32
    800012f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	3a2080e7          	jalr	930(ra) # 80000694 <acquire>
  p->killed = 1;
    800012fa:	4785                	li	a5,1
    800012fc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800012fe:	8526                	mv	a0,s1
    80001300:	fffff097          	auipc	ra,0xfffff
    80001304:	448080e7          	jalr	1096(ra) # 80000748 <release>
}
    80001308:	60e2                	ld	ra,24(sp)
    8000130a:	6442                	ld	s0,16(sp)
    8000130c:	64a2                	ld	s1,8(sp)
    8000130e:	6105                	addi	sp,sp,32
    80001310:	8082                	ret

0000000080001312 <killed>:

int
killed(struct proc *p)
{
    80001312:	1101                	addi	sp,sp,-32
    80001314:	ec06                	sd	ra,24(sp)
    80001316:	e822                	sd	s0,16(sp)
    80001318:	e426                	sd	s1,8(sp)
    8000131a:	e04a                	sd	s2,0(sp)
    8000131c:	1000                	addi	s0,sp,32
    8000131e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001320:	fffff097          	auipc	ra,0xfffff
    80001324:	374080e7          	jalr	884(ra) # 80000694 <acquire>
  k = p->killed;
    80001328:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000132c:	8526                	mv	a0,s1
    8000132e:	fffff097          	auipc	ra,0xfffff
    80001332:	41a080e7          	jalr	1050(ra) # 80000748 <release>
  return k;
}
    80001336:	854a                	mv	a0,s2
    80001338:	60e2                	ld	ra,24(sp)
    8000133a:	6442                	ld	s0,16(sp)
    8000133c:	64a2                	ld	s1,8(sp)
    8000133e:	6902                	ld	s2,0(sp)
    80001340:	6105                	addi	sp,sp,32
    80001342:	8082                	ret

0000000080001344 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001344:	1141                	addi	sp,sp,-16
    80001346:	e406                	sd	ra,8(sp)
    80001348:	e022                	sd	s0,0(sp)
    8000134a:	0800                	addi	s0,sp,16
    8000134c:	852e                	mv	a0,a1
    8000134e:	85b2                	mv	a1,a2
  memmove((char *)dst, src, len);
    80001350:	0006861b          	sext.w	a2,a3
    80001354:	fffff097          	auipc	ra,0xfffff
    80001358:	498080e7          	jalr	1176(ra) # 800007ec <memmove>
  return 0;
}
    8000135c:	4501                	li	a0,0
    8000135e:	60a2                	ld	ra,8(sp)
    80001360:	6402                	ld	s0,0(sp)
    80001362:	0141                	addi	sp,sp,16
    80001364:	8082                	ret

0000000080001366 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001366:	1141                	addi	sp,sp,-16
    80001368:	e406                	sd	ra,8(sp)
    8000136a:	e022                	sd	s0,0(sp)
    8000136c:	0800                	addi	s0,sp,16
    8000136e:	85b2                	mv	a1,a2
  memmove(dst, (char*)src, len);
    80001370:	0006861b          	sext.w	a2,a3
    80001374:	fffff097          	auipc	ra,0xfffff
    80001378:	478080e7          	jalr	1144(ra) # 800007ec <memmove>
  return 0;
}
    8000137c:	4501                	li	a0,0
    8000137e:	60a2                	ld	ra,8(sp)
    80001380:	6402                	ld	s0,0(sp)
    80001382:	0141                	addi	sp,sp,16
    80001384:	8082                	ret

0000000080001386 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001386:	715d                	addi	sp,sp,-80
    80001388:	e486                	sd	ra,72(sp)
    8000138a:	e0a2                	sd	s0,64(sp)
    8000138c:	fc26                	sd	s1,56(sp)
    8000138e:	f84a                	sd	s2,48(sp)
    80001390:	f44e                	sd	s3,40(sp)
    80001392:	f052                	sd	s4,32(sp)
    80001394:	ec56                	sd	s5,24(sp)
    80001396:	e85a                	sd	s6,16(sp)
    80001398:	e45e                	sd	s7,8(sp)
    8000139a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000139c:	00001517          	auipc	a0,0x1
    800013a0:	d1c50513          	addi	a0,a0,-740 # 800020b8 <digits+0x88>
    800013a4:	fffff097          	auipc	ra,0xfffff
    800013a8:	e38080e7          	jalr	-456(ra) # 800001dc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800013ac:	00009497          	auipc	s1,0x9
    800013b0:	6dc48493          	addi	s1,s1,1756 # 8000aa88 <proc+0x158>
    800013b4:	0000f917          	auipc	s2,0xf
    800013b8:	0d490913          	addi	s2,s2,212 # 80010488 <end+0x158>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800013bc:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800013be:	00001997          	auipc	s3,0x1
    800013c2:	da298993          	addi	s3,s3,-606 # 80002160 <digits+0x130>
    printf("%d %s %s", p->pid, state, p->name);
    800013c6:	00001a97          	auipc	s5,0x1
    800013ca:	da2a8a93          	addi	s5,s5,-606 # 80002168 <digits+0x138>
    printf("\n");
    800013ce:	00001a17          	auipc	s4,0x1
    800013d2:	ceaa0a13          	addi	s4,s4,-790 # 800020b8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800013d6:	00001b97          	auipc	s7,0x1
    800013da:	df2b8b93          	addi	s7,s7,-526 # 800021c8 <states.0>
    800013de:	a00d                	j	80001400 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800013e0:	ed86a583          	lw	a1,-296(a3)
    800013e4:	8556                	mv	a0,s5
    800013e6:	fffff097          	auipc	ra,0xfffff
    800013ea:	df6080e7          	jalr	-522(ra) # 800001dc <printf>
    printf("\n");
    800013ee:	8552                	mv	a0,s4
    800013f0:	fffff097          	auipc	ra,0xfffff
    800013f4:	dec080e7          	jalr	-532(ra) # 800001dc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800013f8:	16848493          	addi	s1,s1,360
    800013fc:	03248263          	beq	s1,s2,80001420 <procdump+0x9a>
    if(p->state == UNUSED)
    80001400:	86a6                	mv	a3,s1
    80001402:	ec04a783          	lw	a5,-320(s1)
    80001406:	dbed                	beqz	a5,800013f8 <procdump+0x72>
      state = "???";
    80001408:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000140a:	fcfb6be3          	bltu	s6,a5,800013e0 <procdump+0x5a>
    8000140e:	02079713          	slli	a4,a5,0x20
    80001412:	01d75793          	srli	a5,a4,0x1d
    80001416:	97de                	add	a5,a5,s7
    80001418:	6390                	ld	a2,0(a5)
    8000141a:	f279                	bnez	a2,800013e0 <procdump+0x5a>
      state = "???";
    8000141c:	864e                	mv	a2,s3
    8000141e:	b7c9                	j	800013e0 <procdump+0x5a>
  }
}
    80001420:	60a6                	ld	ra,72(sp)
    80001422:	6406                	ld	s0,64(sp)
    80001424:	74e2                	ld	s1,56(sp)
    80001426:	7942                	ld	s2,48(sp)
    80001428:	79a2                	ld	s3,40(sp)
    8000142a:	7a02                	ld	s4,32(sp)
    8000142c:	6ae2                	ld	s5,24(sp)
    8000142e:	6b42                	ld	s6,16(sp)
    80001430:	6ba2                	ld	s7,8(sp)
    80001432:	6161                	addi	sp,sp,80
    80001434:	8082                	ret

0000000080001436 <do_my_bidding>:

void                                                                                                      
do_my_bidding(void)
{
    80001436:	1101                	addi	sp,sp,-32
    80001438:	ec06                	sd	ra,24(sp)
    8000143a:	e822                	sd	s0,16(sp)
    8000143c:	e426                	sd	s1,8(sp)
    8000143e:	e04a                	sd	s2,0(sp)
    80001440:	1000                	addi	s0,sp,32
    for (;;) {
        int cid = cpuid();                                                                                
        struct proc *proc = myproc();                                                                     
        printf("Running proc %d on cpu %d\n", proc->pid, cid);                                            
    80001442:	00001917          	auipc	s2,0x1
    80001446:	d3690913          	addi	s2,s2,-714 # 80002178 <digits+0x148>
    8000144a:	8492                	mv	s1,tp
        struct proc *proc = myproc();                                                                     
    8000144c:	fffff097          	auipc	ra,0xfffff
    80001450:	654080e7          	jalr	1620(ra) # 80000aa0 <myproc>
        printf("Running proc %d on cpu %d\n", proc->pid, cid);                                            
    80001454:	0004861b          	sext.w	a2,s1
    80001458:	590c                	lw	a1,48(a0)
    8000145a:	854a                	mv	a0,s2
    8000145c:	fffff097          	auipc	ra,0xfffff
    80001460:	d80080e7          	jalr	-640(ra) # 800001dc <printf>
        yield();                                                                                          
    80001464:	00000097          	auipc	ra,0x0
    80001468:	a7c080e7          	jalr	-1412(ra) # 80000ee0 <yield>
    for (;;) {
    8000146c:	bff9                	j	8000144a <do_my_bidding+0x14>

000000008000146e <swtch>:
    8000146e:	00153023          	sd	ra,0(a0)
    80001472:	00253423          	sd	sp,8(a0)
    80001476:	e900                	sd	s0,16(a0)
    80001478:	ed04                	sd	s1,24(a0)
    8000147a:	03253023          	sd	s2,32(a0)
    8000147e:	03353423          	sd	s3,40(a0)
    80001482:	03453823          	sd	s4,48(a0)
    80001486:	03553c23          	sd	s5,56(a0)
    8000148a:	05653023          	sd	s6,64(a0)
    8000148e:	05753423          	sd	s7,72(a0)
    80001492:	05853823          	sd	s8,80(a0)
    80001496:	05953c23          	sd	s9,88(a0)
    8000149a:	07a53023          	sd	s10,96(a0)
    8000149e:	07b53423          	sd	s11,104(a0)
    800014a2:	0005b083          	ld	ra,0(a1)
    800014a6:	0085b103          	ld	sp,8(a1)
    800014aa:	6980                	ld	s0,16(a1)
    800014ac:	6d84                	ld	s1,24(a1)
    800014ae:	0205b903          	ld	s2,32(a1)
    800014b2:	0285b983          	ld	s3,40(a1)
    800014b6:	0305ba03          	ld	s4,48(a1)
    800014ba:	0385ba83          	ld	s5,56(a1)
    800014be:	0405bb03          	ld	s6,64(a1)
    800014c2:	0485bb83          	ld	s7,72(a1)
    800014c6:	0505bc03          	ld	s8,80(a1)
    800014ca:	0585bc83          	ld	s9,88(a1)
    800014ce:	0605bd03          	ld	s10,96(a1)
    800014d2:	0685bd83          	ld	s11,104(a1)
    800014d6:	8082                	ret
	...
