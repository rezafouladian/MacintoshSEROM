; Values of the SE_ link labels in rom_SE.s, for the Outbound EEPROM sources.
; Generated from rom_SE.s; do not edit.

            ; \1 is \2: a macro, so the editor goes to the label in rom_SE.s
SELabel:    MACRO
\1          EQU     \2
            ENDM

            SELabel     SE_StartInit1,$400048
            SELabel     SE_InitIWMCall,$400050
            SELabel     SE_AfterWhichCPU,$40005C
            SELabel     SE_CallInitHiMem,$4000CE
            SELabel     SE_BootRetry,$4000D2
            SELabel     SE_BootRetryCont,$4000D6
            SELabel     SE_BootRetryInts,$4000FE
            SELabel     SE_InitSysZone,$4001A0
            SELabel     SE_DrawBeepScreen,$4001DA
            SELabel     SE_GetPRAM,$400358
            SELabel     SE_WhichCPU,$4003EE
            SELabel     SE_InitSCSI,$4004CE
            SELabel     SE_OpenSony,$400786
            SELabel     SE_AfterSonyOpen,$400790
            SELabel     SE_BootCopyBits,$4008EE
            SELabel     SE_EjectFailed,$400A6A
            SELabel     SE_SkipDrive,$400CBE
            SELabel     SE_GetDefault,$400D08
            SELabel     SE_GotDefault,$400D0A
            SELabel     SE_ShowSuccess,$400E72
            SELabel     SE_HappyMacIcon,$400E74
            SELabel     SE_PlotDiskHide,$400F3A
            SELabel     SE_DiskIcon,$400FB2
            SELabel     SE_MacIcon,$4011F8
            SELabel     SE_HappyFace,$40125C
            SELabel     SE_GenTrace,$40137A
            SELabel     SE_DSDrawIcon,$4014BC
            SELabel     SE_DSDrawText,$401538
            SELabel     SE_DSDrawBox,$401592
            SELabel     SE_DiagReturn,$401C04
            SELabel     SE_CallROMCheck,$401C68
            SELabel     SE_CallRAMTest,$401CC0
            SELabel     SE_CallMemSize,$401CEC
            SELabel     SE_TestCopyLoop,$401D10
            SELabel     SE_SizeTableLoop,$402602
            SELabel     SE_ROMCheck,$4026C8
            SELabel     SE_RAMTest,$4026F0
            SELabel     SE_BeepFill,$4029F8
            SELabel     SE_BeepLoop,$402A42
            SELabel     SE_OneSecInt,$402BBA
            SELabel     SE_VBLTasks,$402C1E
            SELabel     SE_KBDMngr,$403306
            SELabel     SE_KbdVIASetup,$40331E
            SELabel     SE_KBDMngrCont,$403366
            SELabel     SE_KbdComplete,$40339C
            SELabel     SE_DefaultPRAM,$40A0F8
