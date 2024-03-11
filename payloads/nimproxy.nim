import winim, ptr_math, strutils, strformat, cligen

type
    Addresses = object
     Names: PDWORD
     Functions: PDWORD
     Ordinals: PWORD
     NumberOfNames: DWORD

proc getImgBase(dllname: string): PVOID =
    return cast[PVOID](LoadLibraryA(dllname))

proc hex(vr: auto): string =
    return "0x" & repr(cast[PVOID](vr)).toLower()

proc getNecessaryAddresses(pe: DWORD_PTR): Addresses =
    let dosHeader = cast[PIMAGE_DOS_HEADER](pe)
    let ntHeader = cast[PIMAGE_NT_HEADERS](pe + dosHeader.elfanew)
    let optHeader = ntHeader.OptionalHeader
    var eat: PIMAGE_DATA_DIRECTORY = cast[PIMAGE_DATA_DIRECTORY](&(optHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT]))
    var eatDir: PIMAGE_EXPORT_DIRECTORY = cast[PIMAGE_EXPORT_DIRECTORY](pe + eat.VirtualAddress)
    var names: PDWORD = cast[PDWORD](pe + eatDir.AddressOfNames)
    var functions: PDWORD = cast[PDWORD](pe + eatDir.AddressOfFunctions)
    var ordinals: PWORD = cast[PWORD](pe + eatDir.AddressOfNameOrdinals)
    var numNames: DWORD = eatDir.NumberOfNames
    return Addresses(
        Names: names,
        Functions: functions,
        Ordinals: ordinals,
        NumberOfNames: numNames
        )

proc main*(dll, output, special_add: string) =
    echo("""
  _   _ _           ____                      ____  
 | \ | (_)_ __ ___ |  _ \ _ __ _____  ___   _|___ \ 
 |  \| | | '_ ` _ \| |_) | '__/ _ \ \/ / | | | __) |
 | |\  | | | | | | |  __/| | | (_) >  <| |_| |/ __/ 
 |_| \_|_|_| |_| |_|_|   |_|  \___/_/\_\\__, |_____|
                                        |___/  
                                     
""")
    let base = getImgBase(dll)
    if base == nil:
        echo("[-] Failed to Fetch Image Base.")
        quit(-1)
    echo("[+] Fetched Image Base Successfully.")

    let pe = cast[DWORD_PTR](base)
    let addresses = getNecessaryAddresses(pe)
    var names = addresses.Names
    var functions = addresses.Functions
    var ordinals = addresses.Ordinals
    var numNames = addresses.NumberOfNames
    let file = open(output,fmAppend)
    for i in 0..numNames - 1:
        var name = cast[LPCSTR](pe + names[i])
        var ordinal = cast[DWORD](ordinals[i])
        var function = cast[PVOID](pe + ordinal)
        echo(fmt"[*] Proxying [{$name}] -> {function.hex} {{{ordinal}}}")
        let valid_path = dll.replace(".dll","").replace(r"\",r"\\")
        file.write($"""#pragma comment(linker , "/export:""" & $name & "=" & valid_path & special_add & "." & $name & """")""" & "\n")
when isMainModule:
    dispatch main
