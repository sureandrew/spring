; Script generated by the HM NIS Edit Script Wizard.

; Compiler-defines to generate different types of installers
;   SP_UPDATE - Only include changed files and no maps
;   SP_PATCH - Creates a very small patching file (typically from just latest version)

; Use the 7zip-like compressor
SetCompressor lzma

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "TA Spring"
!define PRODUCT_VERSION "0.70b2"
!define PRODUCT_PUBLISHER "The TA Spring team"
!define PRODUCT_WEB_SITE "http://taspring.clan-sy.com"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\SpringClient.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Licensepage
!insertmacro MUI_PAGE_LICENSE "gpl.txt"

!ifndef SP_PATCH
; Components page
!insertmacro MUI_PAGE_COMPONENTS
!endif

; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
;!define MUI_FINISHPAGE_RUN "$INSTDIR\spring.exe"

!ifndef SP_PATCH

!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\docs\main.html"
!define MUI_FINISHPAGE_TEXT "${PRODUCT_NAME} version ${PRODUCT_VERSION} has been successfully installed on your computer. It is recommended that you configure TA Spring settings now if this is a fresh installation, otherwise you may encounter problems."
!define MUI_FINISHPAGE_RUN "$INSTDIR\settings.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Configure ${PRODUCT_NAME} settings now"

!else

!define MUI_FINISHPAGE_TEXT "${PRODUCT_NAME} version ${PRODUCT_VERSION} has been successfully updated from a previous version."

!endif

!define MUI_FINISHPAGE_LINK "The TA Spring website"
!define MUI_FINISHPAGE_LINK_LOCATION "http://taspring.clan-sy.com"
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

; Determine a suitable output name
!define SP_BASENAME "taspring_${PRODUCT_VERSION}"

!ifdef SP_UPDATE
!define SP_OUTSUFFIX1 "_update"
!else
!ifdef SP_PATCH
!define SP_OUTSUFFIX1 "_patch"
!else
!define SP_OUTSUFFIX1 ""
!endif
!endif

;OutFile "Setup.exe"
OutFile "${SP_BASENAME}${SP_OUTSUFFIX1}.exe"
InstallDir "$PROGRAMFILES\TASpring"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

; !include checkdotnet.nsh

!include fileassoc.nsh

!ifndef SP_PATCH

; Used to make sure that the desktop icon to the battleroom cannot be installed without the battleroom itself
Function .onSelChange
  Push $0
  Push $1

  ; Determine which section to affect (since UPDATE do not have a map section)
!ifdef SP_UPDATE
  Push 3
!else
  Push 4
!endif
  Pop $1
  
  SectionGetFlags 1 $0
  IntOp $0 $0 & 1
  IntCmp $0 0 NoBattle Battle Battle
  
  ; Battleroom is enabled
  Battle:
    SectionGetFlags $1 $0
    IntOp $0 $0 & 15
    SectionSetFlags $1 $0
    
    Goto Done

  ; Battleroom is disabled
  NoBattle:
    SectionGetFlags $1 $0
    IntOp $0 $0 & 14
    IntOp $0 $0 | 16
    SectionSetFlags $1 $0
    Goto Done

  ; Done doing battleroom stuff
  Done:
  
  Pop $1
  Pop $0
FunctionEnd

Function .onInit
  Push $0

  ; The core cannot be deselected
  SectionGetFlags 0 $0
;  IntOp $0 $0 & 14
  IntOp $0 $0 | 16
  SectionSetFlags 0 $0
  
  Pop $0

FunctionEnd

Function CheckMaps
  FindFirst $0 $1 "$INSTDIR\maps\*.sm2"
  StrCmp $1 "" done

  MessageBox MB_ICONQUESTION|MB_YESNOCANCEL "The installer has detected old maps in the destination folder. This version of Spring uses a new and better, but incompatible, map format. This means that the old maps can no longer be used, and must be removed to prevent conflicts. Would you like to delete the current contents of your maps folder? If you answer no, the contents will be copied to a new folder called 'oldmaps' to prevent conflicts. You can then delete them manually later. Press cancel to abort the installation." IDYES delete IDNO rename
    Abort "Installation aborted"
    Goto done
  delete:
    Delete "$INSTDIR\maps\*.*"
    Goto done
  rename:
    CreateDirectory "$INSTDIR\oldmaps"
    CopyFiles "$INSTDIR\maps\*.*" "$INSTDIR\oldmaps"
    Delete "$INSTDIR\maps\*.*"
    Goto done
  done:
FunctionEnd

; Deletes spawn.txt if it is from an original installation
Function UpdateSpawn
  ClearErrors
  FileOpen $0 "$INSTDIR\spawn.txt" r
  IfErrors done
  FileSeek $0 0 END $1
  IntCmp $1 260 Eq Less Eq
  
Less:
  FileClose $0
  Delete "$INSTDIR\spawn.txt"
  Goto done
Eq:
  FileClose $0
  Goto done

Done:
FunctionEnd

; Deletes test.dll if it is from an original installation
Function UpdateTestDll
  ClearErrors
  FileOpen $0 "$INSTDIR\aidll\globalai\test.dll" r
  IfErrors done
  FileSeek $0 0 END $1
  IntCmp $1 188416 Eq
  Goto Neq

Eq:
  FileClose $0
  Delete "$INSTDIR\aidll\globalai\test.dll"
  Goto done

Neq:
  FileClose $0
  Goto done

Done:
FunctionEnd

; Deletes testscript.lua if it is from an original installation
Function UpdateTestscript
  ClearErrors
  FileOpen $0 "$INSTDIR\startscripts\testscript.lua" r
  IfErrors done
  FileSeek $0 0 END $1
  IntCmp $1 4215 Eq
  Goto Neq

Eq:
  FileClose $0
  Delete "$INSTDIR\startscripts\testscript.lua"
  Goto done

Neq:
  FileClose $0
  Goto done

Done:
FunctionEnd

; Only allow installation if spring.exe is from version 0.67bx
Function CheckVersion
  ClearErrors
  FileOpen $0 "$INSTDIR\spring.exe" r
  IfErrors done
  FileSeek $0 0 END $1
;  IntCmp $1 2637824 Done             ; 0.60b1
;  IntCmp $1 2650112 Done             ; 0.61b1
;  IntCmp $1 2670592 Done             ; 0.61b2
;  IntCmp $1 2678784 Done             ; 0.62b1
;  IntCmp $1 2682880 Done             ; 0.63b1 & 0.63b2
;  IntCmp $1 2703360 Done             ; 0.64b1
;  IntCmp $1 3006464 Done             ; 0.65b1
;  IntCmp $1 3014656 Done             ; 0.65b2
;  IntCmp $1 3031040 Done             ; 0.66b1
  IntCmp $1 3035136 Done             ; 0.67b1 & 0.67b2 & 0.67b3
  IntCmp $1 2633728 Done             ; 0.70b1

  MessageBox MB_ICONSTOP|MB_OK "This installer can only be used to upgrade a full installation of TA Spring 0.67bx or 0.70b1. Your current folder does not contain a spring.exe from any such version, so the installation will be aborted.. Please download the full installer instead and try again."
  Abort "Unable to upgrade, version 0.67bx or 0.70b1 not found.."
  Goto done

Done:
  FileClose $0

FunctionEnd

Section "Main application (req)" SEC_MAIN
  SetOutPath "$INSTDIR"
  
!ifdef SP_UPDATE
  Call CheckVersion
!endif
  Call CheckMaps
  Call UpdateSpawn
  Call UpdateTestDll
  Call UpdateTestscript
  
  ; Main stuff
  File "..\game\spring.exe"
;  File "..\game\armor.txt"
  Delete "$INSTDIR\armor.txt"
  Delete "$INSTDIR\bagge.fnt"
  Delete "$INSTDIR\hpiutil.dll"
  File "..\game\luxi.ttf"
  File "..\game\selectioneditor.exe"
  
  ; Can be nice and not overwrite these. or not
  SetOverWrite on
  File "..\game\selectkeys.txt"
  File "..\game\uikeys.txt"
  
  SetOverWrite on
  File "..\game\settings.exe"
;  File "..\game\zlib.dll"
  Delete "$INSTDIR\zlib.dll"
  File "..\game\zlibwapi.dll"
  ; File "..\game\7zxa.dll"
  Delete "$INSTDIR\7zxa.dll"
  File "..\game\crashrpt.dll"
  File "..\game\dbghelp.dll"
  File "..\game\devil.dll"
  File "..\game\SDL.dll"
  File "..\game\msvcp71.dll"
  File "..\game\msvcr71.dll"
;  File "..\game\tower.sdu"
  Delete "$INSTDIR\tower.sdu"
  File "..\game\palette.pal"
;  File "..\game\testscript.lua"
;  File "..\game\spawn.txt"
  
  ; Gamedata
  SetOutPath "$INSTDIR\gamedata"
  File "..\game\gamedata\resources.tdf"

  ; Bitmaps that are not from TA
 ; SetOutPath "$INSTDIR\bitmaps"
;  File "..\game\bitmaps\*.gif"
;  File "..\game\bitmaps\*.bmp"
;  File "..\game\bitmaps\*.jpg"
;  SetOutPath "$INSTDIR\bitmaps\smoke"
;  File "..\game\bitmaps\smoke\*.bmp"
  
;  SetOutPath "$INSTDIR\bitmaps\tracks"
;  File "..\game\bitmaps\tracks\*.bmp"
  
;  SetOutPath "$INSTDIR\bitmaps\terrain"
;  File "..\game\bitmaps\terrain\*.jpg"
  Delete "$INSTDIR\bitmaps\terrain\*.jpg"
  Rmdir "$INSTDIR\bitmaps\terrain"

  ; All bitmaps are now in archives
  Delete "$INSTDIR\bitmaps\*.bmp"
  Delete "$INSTDIR\bitmaps\*.jpg"
  Delete "$INSTDIR\bitmaps\*.gif"
  Delete "$INSTDIR\bitmaps\smoke\*.bmp"
  Delete "$INSTDIR\bitmaps\tracks\*.bmp"
  RmDir "$INSTDIR\bitmaps\smoke"
  RmDir "$INSTDIR\bitmaps\tracks"
  RmDir "$INSTDIR\bitmaps"

  SetOutPath "$INSTDIR\startscripts"
  File "..\game\startscripts\testscript.lua"

  SetOutPath "$INSTDIR\shaders"
  File "..\game\shaders\*.fp"
  File "..\game\shaders\*.vp"
  
  SetOutPath "$INSTDIR\aidll"
  File "..\game\aidll\centralbuild.dll"
  File "..\game\aidll\mmhandler.dll"
  File "..\game\aidll\simpleform.dll"
  
  SetOverWrite ifnewer
  SetOutPath "$INSTDIR\aidll\globalai"
  File "..\game\aidll\globalai\jcai.dll"
  File "..\game\aidll\globalai\emptyai.dll"
  File "..\game\aidll\globalai\ntai.dll"
  CreateDirectory "..\game\aidll\globalai\MEXCACHE"
  
  ; JCAI 0.20
  SetOutPath "$INSTDIR\aidll\globalai\jcai"
  File "..\game\aidll\globalai\jcai\*.cfg"
  File "..\game\aidll\globalai\jcai\readme.txt"
  Delete "$INSTDIR\aidll\globalai\jcai\xta_se_v065.cfg"
  
  SetOverWrite on
  ; XTA
;  File "..\game\taenheter.ccx"
  SetOutPath "$INSTDIR\base"

;  File "..\game\base\tatextures.sdz"
  Delete "$INSTDIR\base\tatextures.sdz"
  File "..\game\base\tatextures_v062.sdz"

;  File "..\game\base\tacontent.sdz"
  Delete "$INSTDIR\base\tacontent.sdz"

!ifndef SP_UPDATE
  File "..\game\base\otacontent.sdz"
  File "..\game\base\tacontent_v2.sdz"
  File "..\game\base\springcontent.sdz"

  SetOutPath "$INSTDIR\base\spring"
  File "..\game\base\spring\springbitmaps_v061.sdz"
;  File "..\game\base\spring\springdecals_v061.sdz"
  File "..\game\base\spring\springdecals_v062.sdz"
  File "..\game\base\spring\springloadpictures_v061.sdz"
  Delete "$INSTDIR\base\spring\springdecals_v061.sdz"
!endif

  SetOutPath "$INSTDIR\mods"
!ifndef SP_UPDATE
  File "..\game\mods\xta_se_v066.sdz"
!endif
  File "..\game\mods\xtapev3.sd7"

  Delete "$INSTDIR\mods\xta_se_v065.sdz"
  Delete "$INSTDIR\mods\xta_se_v064.sdz"
  Delete "$INSTDIR\mods\xta_se_v063.sdz"
  Delete "$INSTDIR\mods\xta_se_v062.sdz"
  Delete "$INSTDIR\mods\xta_se_v061.sdz"
  Delete "$INSTDIR\mods\xta_se_v060.sdz"
  
  ; Stuff to always clean up (from old versions etc)
  Delete "$INSTDIR\taenheter.ccx"
  Delete "$INSTDIR\Utility.dll"
  Delete "$INSTDIR\SpringClient.pdb"
  Delete "$INSTDIR\test.sdf"
  
  Delete "$INSTDIR\maps\*.pe"
  Delete "$INSTDIR\maps\*.pe2"
  
  Delete "$INSTDIR\ClientControls.dll"
  Delete "$INSTDIR\SpringClient.exe"

  !insertmacro APP_ASSOCIATE "sdf" "taspring.demofile" "TA Spring demo file" "$INSTDIR\spring.exe,0" "Open with Spring" "$INSTDIR\spring.exe %1"
  !insertmacro UPDATEFILEASSOC

SectionEnd

Section "Multiplayer battleroom" SEC_BATTLEROOM
  SetOutPath "$INSTDIR"

  ; The battleroom
;  File "..\game\ClientControls.dll"
  File "..\game\TASClient.exe"
;  File "..\game\SpringClient.pdb"
;  File "..\game\Utility.dll"
  File "..\game\Unitsync.dll"
  
  CreateDirectory "$INSTDIR\lobby\cache"
  CreateDirectory "$INSTDIR\lobby\var"
  CreateDirectory "$INSTDIR\lobby\logs"
  
;  SetOutPath "$INSTDIR\lobby\sidepics"
;  File "..\game\lobby\sidepics\arm.bmp"
;  File "..\game\lobby\sidepics\core.bmp"
;  File "..\game\lobby\sidepics\tll.bmp"
  Delete "$INSTDIR\lobby\sidepics\arm.bmp"
  Delete "$INSTDIR\lobby\sidepics\core.bmp"
  Delete "$INSTDIR\lobby\sidepics\tll.bmp"
  RmDir "$INSTDIR\lobby\sidepics"
  
SectionEnd

!ifndef SP_UPDATE
Section "Maps" SEC_MAPS
  SetOutPath "$INSTDIR\maps"

  File "..\game\maps\SmallDivide.sd7"
  File "..\game\maps\Mars.sd7"

SectionEnd
!endif

Section "Start menu shortcuts" SEC_START
  SetOutPath "$INSTDIR"

  ; Main shortcuts
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
;  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\TA Spring.lnk" "$INSTDIR\spring.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\TA Spring battleroom.lnk" "$INSTDIR\TASClient.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Selectionkeys editor.lnk" "$INSTDIR\SelectionEditor.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Settings.lnk" "$INSTDIR\Settings.exe"

  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section /o "Desktop shortcut" SEC_DESKTOP
  SetOutPath "$INSTDIR"

  CreateShortCut "$DESKTOP\TA Spring battleroom.lnk" "$INSTDIR\TASClient.exe"
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MAIN} "The core components required to run TA Spring. This includes the configuration utilities.$\n$\nNote: This section is required and cannot be deselected."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_BATTLEROOM} "The multiplayer battleroom used to set up multiplayer games and find opponents."

!ifndef SP_UPDATE
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MAPS} "Includes two maps to play TA Spring with.$\n$\nThese maps are called Small Divide and Mars."
!endif

  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_START} "This creates shortcuts on the start menu to all the applications provided."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_DESKTOP} "This creates a shortcut on the desktop to the multiplayer battleroom for quick access to multiplayer games."

!insertmacro MUI_FUNCTION_DESCRIPTION_END


!else ; SP_PATCH

; Only allow installation if spring.exe is from version 0.70b1
Function CheckVersion
  ClearErrors
  FileOpen $0 "$INSTDIR\tasclient.exe" r
  IfErrors done
  FileSeek $0 0 END $1
;  IntCmp $1 3035136 Done             ; 0.67b1 &0.67b2
;  IntCmp $1 2277888 Done             ; 0.67b2 (tasclient 0.19)
  IntCmp $1 2640896 Done              ; 0.70b1 (tasclient 0.20)

  MessageBox MB_ICONSTOP|MB_OK "This installer can only be used to patch a full installation of TA Spring 0.70b1. Your current folder does not contain a tasclient.exe from this version, so the installation will be aborted.. Please download the full or updating installer instead and try again."
  Abort "Unable to upgrade, version 0.70b1 not found.."
  Goto done

Done:
  FileClose $0

FunctionEnd

!include "VPatchLib.nsh"

Section -Patch
  SetOutPath "$INSTDIR"
  Call CheckVersion
  
  !insertmacro VPatchFile "tasclient070b2.pat" "$INSTDIR\TASClient.exe" "$TEMP\TASClient.tmp"
  IfErrors PatchError
  !insertmacro VPatchFile "spring070b2.pat" "$INSTDIR\spring.exe" "$TEMP\spring.tmp"
  IfErrors PatchError
  !insertmacro VPatchFile "unitsync070b2.pat" "$INSTDIR\unitsync.dll" "$TEMP\unitsync.tmp"
  IfErrors PatchError
  !insertmacro VPatchFile "sdl070b2.pat" "$INSTDIR\sdl.dll" "$TEMP\sdl.tmp"
  IfErrors PatchError

;  !insertmacro VPatchFile "unitsync067b2.pat" "$INSTDIR\unitsync.dll" "$TEMP\unitsync.tmp"
;  IfErrors PatchError

  Goto Done

PatchError:
  MessageBox MB_ICONSTOP|MB_OK "The patching process could not be completed. Please download the full or updating installer instead and install one of them instead."
  Abort "Error encountered during patching.."
  
Done:

SectionEnd

!endif ; SP_PATCH

Section -Documentation
  SetOutPath "$INSTDIR\docs"

;  File "..\readme.html"
  Delete "$INSTDIR\docs\readme.html"
  File "..\license.html"
  File "..\Documentation\changelog.txt"
  File "..\Documentation\xtachanges.txt"

  File "..\Documentation\userdocs\Q&A.html"
  File "..\Documentation\userdocs\Getting Started.html"
  File "..\Documentation\userdocs\Legal.html"
  File "..\Documentation\userdocs\main.html"
  File "..\Documentation\userdocs\More Info.html"

SectionEnd


Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\springclient.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\spring.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall

  ; Main files
  Delete "$INSTDIR\spring.exe"
;  Delete "$INSTDIR\armor.txt"
  Delete "$INSTDIR\bagge.fnt"
  Delete "$INSTDIR\hpiutil.dll"
  Delete "$INSTDIR\luxi.ttf"
  Delete "$INSTDIR\palette.pal"
  Delete "$INSTDIR\selectioneditor.exe"
  Delete "$INSTDIR\selectkeys.txt"
  Delete "$INSTDIR\uikeys.txt"
  Delete "$INSTDIR\settings.exe"
;  Delete "$INSTDIR\zlib.dll"
  Delete "$INSTDIR\zlibwapi.dll"
;  Delete "$INSTDIR\7zxa.dll"
  Delete "$INSTDIR\crashrpt.dll"
  Delete "$INSTDIR\dbghelp.dll"
  Delete "$INSTDIR\devil.dll"
  Delete "$INSTDIR\SDL.dll"
  Delete "$INSTDIR\MSVCP71.dll"
  Delete "$INSTDIR\MSVCR71.dll"
  Delete "$INSTDIR\tower.sdu"
  Delete "$INSTDIR\palette.pal"
;  Delete "$INSTDIR\spawn.txt"

  ; Shaders
  Delete "$INSTDIR\shaders\*.fp"
  Delete "$INSTDIR\shaders\*.vp"
  RMDir "$INSTDIR\shaders"
  
  ; AI-dll's
  Delete "$INSTDIR\aidll\globalai\jcai\*.cfg"
  Delete "$INSTDIR\aidll\globalai\jcai\*.modcache"
  Delete "$INSTDIR\aidll\globalai\jcai\readme.txt"
  RmDir "$INSTDIR\aidll\globalai\jcai"
  Delete "$INSTDIR\aidll\globalai\jcai.dll"
  Delete "$INSTDIR\aidll\globalai\emptyai.dll"
  Delete "$INSTDIR\aidll\globalai\ntai.dll"
  Delete "$INSTDIR\aidll\globalai\mexcache\*.*"
  RmDir "$INSTDIR\aidll\globalai"
  Delete "$INSTDIR\aidll\centralbuild.dll"
  Delete "$INSTDIR\aidll\mmhandler.dll"
  Delete "$INSTDIR\aidll\simpleform.dll"
  RMDir "$INSTDIR\aidll"
  
  ; Gamedata
  Delete "$INSTDIR\gamedata\resources.tdf"
  RmDir "$INSTDIR\gamedata"

  ; Startscript
  Delete "$INSTDIR\startscripts\testscript.lua"
  RmDir "$INSTDIR\startscripts"

  ; The battleroom
  Delete "$INSTDIR\TASClient.exe"
  Delete "$INSTDIR\Unitsync.dll"
  Delete "$INSTDIR\lobby\sidepics\arm.bmp"
  Delete "$INSTDIR\lobby\sidepics\core.bmp"
  Delete "$INSTDIR\lobby\sidepics\tll.bmp"

  ; Maps
  Delete "$INSTDIR\maps\paths\SmallDivide.*"
  ; Delete "$INSTDIR\maps\paths\FloodedDesert.*"
  Delete "$INSTDIR\maps\paths\Mars.*"
  Delete "$INSTDIR\maps\SmallDivide.*"
  Delete "$INSTDIR\maps\FloodedDesert.*"
  Delete "$INSTDIR\maps\Mars.*"
  RmDir "$INSTDIR\maps\paths"
  RMDir "$INSTDIR\maps"

  ; XTA + content
  Delete "$INSTDIR\base\tatextures_v062.sdz"
  Delete "$INSTDIR\base\tacontent_v2.sdz"
  Delete "$INSTDIR\base\otacontent.sdz"
  Delete "$INSTDIR\base\springcontent.sdz"
  Delete "$INSTDIR\mods\xta_se_v066.sdz"
  Delete "$INSTDIR\mods\xtapev3.sd7"
  Delete "$INSTDIR\base\spring\springbitmaps_v061.sdz"
  Delete "$INSTDIR\base\spring\springdecals_v062.sdz"
  Delete "$INSTDIR\base\spring\springloadpictures_v061.sdz"
  
  RmDir "$INSTDIR\base\spring"
  RmDir "$INSTDIR\base"
  RmDir "$INSTDIR\mods"

; Generated stuff from the installer
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  
  ; Generated stuff from running spring
  Delete "$INSTDIR\infolog.txt"
  Delete "$INSTDIR\ext.txt"
;  Delete "$INSTDIR\config.dat"

  ; Documentation
  Delete "$INSTDIR\docs\readme.html"
  Delete "$INSTDIR\docs\license.html"
  Delete "$INSTDIR\docs\changelog.txt"
  Delete "$INSTDIR\docs\xtachanges.txt"
  Delete "$INSTDIR\docs\Q&A.html"
  Delete "$INSTDIR\docs\Getting Started.html"
  Delete "$INSTDIR\docs\Legal.html"
  Delete "$INSTDIR\docs\main.html"
  Delete "$INSTDIR\docs\More Info.html"
  RMDir "$INSTDIR\docs"
  
  ; Shortcuts
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk"
;  Delete "$SMPROGRAMS\${PRODUCT_NAME}\TA Spring.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\TA Spring battleroom.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Selectionkeys editor.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Settings.lnk"
  RMDir "$SMPROGRAMS\${PRODUCT_NAME}"

  Delete "$DESKTOP\TA Spring battleroom.lnk"

  ; All done
  RMDir "$INSTDIR"

  !insertmacro APP_UNASSOCIATE "sdf" "taspring.demofile"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
