
        IFND OutboundBuild
            INCLUDE 'ROMTools/Include.s'
            INCLUDE 'ROMTools/Globals.s'
            INCLUDE 'ROMTools/CommonConst.s'
            INCLUDE 'ROMTools/TrapMacros.s'
            INCLUDE 'ROMTools/Hardware/SE.s'
        ENDIF



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
.L2:
            lea     OneSecInt,A0
.L3:
            move.l  A0,(A2)+
            lea     VBLINT,A0
            move.l  A0,(A2)
            lea     Lvl2DT,A2
            lea     EXTBINT,A0
            move.l  A0,(A2)
            lea     EXTAINT,A0
            move.l  A0,($10,A2)
            lea     ExtStsDT,A2
            lea     OneSecInt\.done,A0
            move.l  A0,(A2)+
            move.l  A0,(A2)+
            move.l  A0,(A2)+
            move.l  A0,(A2)
            lea     Lev1AutoVector,A2
            lea     LVL1INT,A0
            move.l  A0,(A2)+
            lea     LVL2INT,A0
            move.l  A0,(A2)+
            lea     SPURIOUS,A0
            move.l  A0,(A2)
            rts
WhichCPU:
            lea     IllegalInstructionVector,A1
            move.l  (A1),-(SP)
            lea     .L1,A0
            move.l  A0,(A1)
            movea.l SP,A0
            clr.w   -(SP)
            moveq   #2,D1
            moveq   #1,D0
            movec   D0,CACR
            bra     .L2
.L1:
            moveq   #1,D1
            cmpi.w  #$10,($6,SP)
            beq.b   .L2
            moveq   #0,D1
.L2:
            movea.l A0,SP
            move.l  (SP)+,(A1)
            move.b  D1,D7
            rts
SetupTimeK:
            move    SR,-(SP)
            move.l  Lev1AutoVector,-(SP)
            movea.l #VBase,A1
            bclr.b  #5,(vACR,A1)
            move.b  #$FF,(vT2CH,A1)
            move.b  #$A0,(vIER,A1)
            andi    #$F8FF,SR
            move.l  SP,D1
            lea     .L4,A0
            move.l  A0,Lev1AutoVector
            moveq   #-1,D0
            bra.b   .L3
.L1:
            move.b  #$F,(vT2C,A1)
            move.b  #$3,(vT2CH,A1)
.L2:
            dbf     D0,.L2
            bra.b   .L4
.L3:
            bra.b   .L1
.L4:
            tst.b   (vT2C,A1)
            not.w   D0
            move.w  D0,TimeDBRA
            movea.l D1,SP
            andi    #$F8FF,SR
            lea     .L8,A0
            move.l  A0,Lev1AutoVector
            movea.l #$9FFFF8,A0
            moveq   #-1,D0
            bra.b   .L7
.L5:
            move.b  #$F,(vT2C,A1)
            move.b  #$3,(vT2CH,A1)
.L6:
            btst.b  #0,(A0)
            dbf     D0,.L6
            bra.b   .L8
.L7:
            bra.b   .L5
.L8:
            tst.b   (vT2C,A1)
            not.w   D0
            move.w  D0,TimeSCCDB
            movea.l D1,SP
            move.b  #$20,(vIER,A1)
            move.l  (SP)+,Lev1AutoVector
            move    (SP)+,SR
            rts
InitSCSIGlobals:
            move.l  #MacSCSIBase,SCSIBase
            move.l  #MacSCSIDMA,SCSIDMA
            move.l  #MacSCSIHsk,SCSIHsk
            rts
InitSCSI:
            lea     SCSIWr,A0
            clr.b   (sICR,A0)                       ; Clear Initiator Command Register
            clr.b   (sMR,A0)                        ; Clear Mode Register
            clr.b   (sTCR,A0)                       ; Clear Target Command Register
            clr.b   (sSER,A0)                       ; Clear Select Enable Register
            rts
InitIWMGlobals:
            move.l  #DBase,IWM
            rts
InitIWM:
            movea.l DBase,A0
            moveq   #17,D0
.L1:
            tst.b   (mtrOff,A0)
            tst.b   (q6H,A0)
            move.b  (q7L,A0),D2
            btst.l  #5,D2
            bne.b   .L1
            and.b   D0,D2
            cmp.b   D0,D2
            beq.b   .L2
            move.b  D0,(q7H,A0)
            tst.b   (q7L,A0)
            bra.b   .L1
.L2:
            tst.b   (q6L,A0)
            rts
InitVIAGlobals:
            move.l  VBase,VIA
            rts
InitVIA:
            movea.l #VBase,A0
            move.b  #$69,(vBufA,A0)
            move.b  #$7F,(vDIRA,A0)
            move.b  #$C7,(vBufB,A0)
            move.b  #$C7,(vDIRB,A0)
            move.b  #$7F,(vIER,A0)
            rts
VIATimerEnables:
            movea.l #VBase,A0
            andi.b  #$F0,(vPCR,A0)
            move.b  #$83,(vIER,A0)
            rts
InitSCCGlobals:
            move.l  #SCCWBase,SCCWr
            move.l  #SCCRBase,SCCRd
            clr.l   PollProc
            rts
Gary:
            dc.l    $940044C
            dc.l    $20003C0
            dc.l    $F080010
            dc.l    $100101
            dc.l    $980044C
            dc.l    $3C00F08
            dc.l    $100010
            dc.l    $101090A
InitSCC:
            movea.l SCCWBase,A0
            movea.l SCCRBase,A1
            tst.b   (-1,A1)
            lea     Gary,A2
            moveq   #$10,D1
            bsr.b   WriteSCC
            addq.l  #2,A0
            addq.l  #2,A1
            moveq   #$10,D1
            bsr.b   WriteSCC
            rts
WriteSCC:
            move.b  (A1),D2
            bra.b   .L2
.L1:
            move.l  (SP),(SP)
            move.l  (SP),(SP)
            move.b  (A2)+,(A0)
.L2:
            dbf     D1,.L1
            rts
InitVidGlobals:
            move.l  BufPtr,ScrnBase
            move.w  #64,ScreenRow
            move.w  #60,VertRRate
            move.l  #$480048,ScrVRes
            rts
InitCrsrVars:
            lea     GrafBegin,A0
            lea     GrafEnd,A1
.L1:
            clr.w   (A0)+
            cmpa.l  A1,A0
            bcs.b   .L1
            rts
InitCrsrMgr:
            move.l  #$F000F,D0
                

