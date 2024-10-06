            INCLUDE 'ROMTools/Globals.s'
            INCLUDE 'ROMTools/CommonConst.s'
            INCLUDE 'ROMTools/TrapMacros.s'
            INCLUDE 'ROMTools/Hardware/SE.s'



            macro BigLea
                lea (\1-*).l,\2
                lea (*-6,PC,\2.l),\2
            endm

            macro BSR6
                lea .\@,A6
                jmp (\1,PC)
            .\@:
            endm

            org     BaseOfROM
ROMChecksum dc.l    $B2E362A8
StartPC     dc.l    ResetEntry
ROMVersion  dc.w    $276
            jmp     StartBoot
            jmp     StartBoot
            dc.b    0
            dc.b    0
            dc.b    0
            dc.b    0
            dc.w    0
            dc.w    0
            dc.l    $1AF1C
            jmp     DoEject
            dc.l    $1AA9C
            jmp     CritErr
ResetEntry:
            jmp     StartBoot
            dc.w    0
            dc.l    $B22351
            dc.l    $BF7673
            dc.l    0
            dc.l    0
StartBoot:
            move    #$2700,SR
            jmp     StartTest1
StartInit1:
            bsr.w   InitVIA
            bsr.w   InitSCC
.OB_InitPatch:
            bsr.w   InitIWMGlobals
            bsr.w   InitSCSI
            bsr.w   WhichCPU
            movea.l A6,A1
            movea.l A6,A0
            suba.w  #$5900,A0
            jsr     FUN_401D3E
            moveq   #$28,D0
            bsr.w   BootBeep
            movea.l SP,A0
            movea.l #$40000,A1
            cmpa.l  A1,A6
            bcc.b   .L1
            movea.l A6,A1
.L1:
            cmpi.l  #wmStConst,WarmStart
            beq.b   .L2
            jsr     FUN_401D3E
.L2:
            movea.l A1,SP
            move.l  WarmStart,-(SP)
            lea     MonkeyLives,A0
            lea     HeapStart,A1
            bsr.w   FillWithOnes
            move.l  (SP)+,WarmStart
            move.b  D7,CPUFlag
            move.l  A6,MemTop
            BSR6    SysErrInit
            bsr.w   SetupTimeK
            bsr.w   VIATimerEnables
            movem.l $F80080,D0/A0
            cmpi.l  #TROMCode,D0
            bne.b   .NoDiagROM
            lea     BootRetry,A1
            jmp     (A0)
.NoDiagROM:
.OB_BootPatchSE:
            bsr.w   InitHiMemGlobals
BootRetry:
            move    #$2700,SR
.OB_BootRetryPatch:
            bsr.w   InitGlobalVars
            bsr.w   InitXVectTables
            bsr.w   InitDispatcher
            bsr.w   GetPRAM
            bsr.w   InitMemMgr
            bsr.w   SetupSysAppZone
            bsr.w   InitSwitcherTable
            bsr.w   InitRsrcMgr
            bsr.w   InitTimerMgr
            bsr.w   InitADBVars
.OB_BootRetryPatch2:
            move    #$2000,SR
            jsr     InitADB
            bsr.w   InitVidGlobals
            movea.l SP,A0
            movea.l BufPtr,A1
            movea.l MemTop,A6
            cmpi.l  #wmStConst,WarmStart
            beq.b   .L1
            jsr     FUN_401D3E
.L1:
            bsr.w   CompBootStack
            movea.l A0,SP
            suba.w  #$2000,A0
            _SetApplLimit
            lea     DrvQHdr,A1
            jsr     InitQueue
            jsr     InitSCSIMgr
            bsr.w   InitIOMgr
            bsr.w   InitCrsrMgr
            movea.l SysZone,A0
            movea.l (A0),A0
            adda.w  #$4000,A0
            _SetApplBase
            move.l  SysZone,TheZone
            lea     ($400,SP),A6
            lea     ($190,SP),A5
            bsr.w   DrawBeepScreen
            move.l  #wmStConst,WarmStart
            bra.w   BootMe
JmpTblInit:
            move.l  A0,D0
.JmpTbl2:
            moveq   #0,D2
            move.w  (A0)+,D2
            add.l   D0,D2
            move.l  D2,(A1)+
            dbf     D1,.JmpTbl2
            rts
FillWithOnes:
            move.l  A1,D0
            sub.l   A0,D0
            lsr.l   #2,D0
            moveq   #-1,D1
.L1:
            move.l  D1,(A0)+
            subq.l  #1,D0
            bne.b   .L1
            rts
CompBootStack:
            move.l  MemTop,D0
            lsr.l   #1,D0
            movea.l D0,A0
            suba.w  #$400,A0
            rts
SetupSysAppZone:
            lea     .L2,A0
.OB_SetupSysAppZonePatch:
            _InitZone
            move.l  TheZone,SysZone
            move.l  SysZone,RAMBase
            movea.l SysZone,A0
            move.l  A0,ApplZone
            movea.l (A0),A0
            move.l  A0,HeapEnd
            bsr.b   CompBootStack
            cmpa.l  SP,A0
            bls.b   .L1
            movea.l SP,A0
.L1:
            suba.w  #$2000,A0
            _SetApplLimit
            rts
.L2:
            dc.l    HeapStart
            dc.l    $2E00
            dc.l    $400000
            dc.b    0,0
DrawBeepScreen:
            pea     (-4,A5)
            _InitGraf
            pea     (-$200,A6)
            _OpenPort
            movea.l (A5),A2
            pea     (-$6C,A2)
            _SetCursor
            lea     (-$74,A2),A0
            move.l  A0,-(SP)
            lea     Scratch8,A1
            move.l  A1,-(SP)
            move.l  A1,-(SP)
            move.l  (A0)+,(A1)+
            move.l  (A0),(A1)
            move.l  #$FFFDFFFD,-(SP)
            _InsetRect
            move.l  #$30003,-(SP)
            _PenSize
            move.l  #$160016,-(SP)
            _FrameRoundRect
            _PenNormal
            move.l  #$10010,-(SP)
            pea     (-$18,A2)
            _FillRoundRect
            rts
InitADBVars:
            move.w  #$172,D0
            _NewPtrSysClear
            move.l  A0,ADBBase
            lea     FDBShiftInt,A0
            move.l  A0,(Lvl1DT+8)
            rts
InitHiMemGlobals:
            move.w  #-1,PWMValue
            movea.l MemTop,A0
            suba.w  #$2FF,A0
            move.l  A0,PWMBuf1
            subq.w  #1,A0
            move.l  A0,SoundBase
            suba.w  #$5600,A0
            move.l  A0,BufPtr
            rts
InitGlobalVars:
            move.l  #BaseOfROM,ROMBase
            move.b  #$7F,ROM85
            move.w  #$C400,HWCfgFlags
            move.l  #$10001,OneOne
            moveq   #-1,D0
            move.l  D0,MinusOne
            bsr.w   InitSCCGlobals
            bsr.w   InitIWMGlobals
            bsr.w   InitVIAGlobals
            bsr.w   InitSCSIGlobals
            clr.l   DSAlertTab
            move.w  MinusOne,FSFCBLen
            BigLea  FSIODNETbl,A0
            lea     JFetch,A1
            moveq   #2,D1
            bsr.w   JmpTblInit
            clr.b   DskVerify
            clr.b   LoadTrap
            clr.b   MmInOK
            clr.w   SysEvtMask
            clr.l   JKybdTask
            clr.l   StkLowPt
            lea     VBLQueue,A1
            jsr     InitQueue
            clr.l   Ticks
            move.b  #$80,MBState
            clr.l   MBTicks
            clr.l   SysFontFam
            clr.l   WidthTabHandle
            clr.w   TESysJust
            clr.b   WordRedraw
            jsr     InitCrsrVars
            clr.w   SysVersion
            bclr.b  #0,AlarmState
            lea     GNEFilter,A0
            move.l  A0,JGNEFilter
            clr.l   IAZNotify
            move.w  #$FF7F,FlEvtMask
            rts
SwitchGoodies:

InitSwitcherTable:
            moveq   #$34,D0
            _NewPtrSysClear
            movea.l A0,A1
            lea     SwitchGoodies,A0
            moveq   #$34,D0
            _BlockMove
            move.l  A1,SwitcherTPtr
            rts
GetPRAM:
.OB_GetPRAMSEPatch:
            _InitUtil
            moveq   #0,D1
            move.b  SPKbd,D1
            moveq   #$F,D0
            and.w   D1,D0
            bne.b   .L1
            moveq   #$48,D0
.L1:
            add.w   D0,D0
            move.w  D0,KeyRepThresh
            lsr.w   #4,D1
            bne.b   .L2
            move.w  #$1FFF,D1
.L2:
            lsl.w   #2,D1
            move.w  D1,KeyThresh
            move.b  SPClikCaret,D1
            moveq   #$F,D0
            and.b   D1,D0
            lsl.b   #2,D0
            move.l  D0,CaretTime
            lsr.b   #2,D1
            moveq   #$3C,D0
            and.b   D1,D0
            move.l  D0,DoubleTime
            rts
InitXVectTables:
            lea     Lvl1DT,A0
            lea     Lvl1RTS,A1
            movea.l A0,A2
            moveq   #$F,D0
.L1:
            move.l  A1,(A0)+
            dbf     D0,.L1


