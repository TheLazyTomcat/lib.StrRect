{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  StrRect - String rectification utility

    Main aim of this library is to simplify conversions in Lazarus when passing
    strings to RTL or WinAPI - mainly to ensure the same code can be used in all
    compilers (Delphi, FPC 2.x.x, FPC 3.x.x) without a need for symbol checks.

    It also provides set of functions for string comparison that encapsulates
    some of the intricacies given by different approach in different compilers.

    For details about encodings refer to file encoding_notes.txt distributed
    with this library.

    Library was tested in following IDE/compilers:

      Delphi 7 Personal (non-unicode, Windows)
      Delphi 10.1 Berlin Personal (unicode, Windows)
      Lazarus 1.4.4 - FPC 2.6.4 (non-unicode, Windows)
      Lazarus 2.0.8 - FPC 3.0.4 (non-unicode, Windows)
      Lazarus 2.0.8 - FPC 3.0.4 (non-unicode, Linux)
      Lazarus 2.0.8 - FPC 3.0.4 (unicode, Windows)
      Lazarus 2.0.8 - FPC 3.0.4 (unicode, Linux)

    Compatible FPC modes:
    
      Delphi, DelphiUnicode, FPC (default), ObjFPC, TurboPascal

  Version 1.3.0 (2020-08-02)

  Last change (2020-08-02)

  ©2017-2020 František Milt

  Contacts:
    František Milt: frantisek.milt@gmail.com

  Support:
    If you find this code useful, please consider supporting its author(s) by
    making a small donation using the following link(s):

      https://www.paypal.me/FMilt

  Changelog:
    For detailed changelog and history please refer to this git repository:

      github.com/TheLazyTomcat/Lib.StrRect

  Dependencies:
    none

===============================================================================}
{
  I do not have any good information on non-windows Delphi, therefore this
  entire unit is marked as platform in there as a warning.
}
unit StrRect{$IF not Defined(FPC) and not(Defined(WINDOWS) or Defined(MSWINDOWS))} platform{$IFEND};

{$IF Defined(WINDOWS) or Defined(MSWINDOWS)}
  {$DEFINE Windows}
{$IFEND}

{$IFDEF FPC}
  // do not set $MODE, leave the unit mode-agnostic
  {$MODESWITCH RESULT+}
  {$INLINE ON}
  {$DEFINE CanInline}
  {
    Activate symbol BARE_FPC if you want to compile this unit outside of
    Lazarus.
    Has effect only in very old FPC (prior version 2.7.1). Non-unicode default
    strings are assumed to be encoded using current CP when defined, otherwise
    they are assumed to be UTF8-encoded.

    Not defined by default.
  }
  {.$DEFINE BARE_FPC}
  {$IFDEF LCL}  // clearly not bare FPC...
    {$UNDEF BARE_FPC}
  {$ENDIF}
{$ELSE}
  {$IF CompilerVersion >= 17 then}  // Delphi 2005+
    {$DEFINE CanInline}
  {$ELSE}
    {$UNDEF CanInline}
  {$IFEND}
{$ENDIF}
{$H+} // explicitly activate long strings

// do not touch following
{$IF Defined(FPC) and Defined(Windows) and (FPC_FULLVERSION < 20701)}
  {$IFDEF BARE_FPC}
    {$DEFINE FPC_OLD_WIN_BARE}
  {$ELSE}
    {$DEFINE FPC_OLD_WIN_LAZ}
  {$ENDIF}
{$IFEND}

interface

type
{$IF not Declared(UnicodeString)}
  UnicodeString = WideString;
{$ELSE}
  // don't ask, it must be here
  UnicodeString = System.UnicodeString;
{$IFEND}

{===============================================================================
    auxiliary public functions
===============================================================================}
{
  Following two functions are present in newer Delphi where they replace
  deprecated UTF8Decode/UTF8Encode.
  They are here for use in older compilers.
}
{$IF not Declared(UTF8ToString)}
Function UTF8ToString(const Str: UTF8String): UnicodeString;{$IFDEF CanInline} inline; {$ENDIF}
{$DEFINE Implement_UTF8ToString}
{$IFEND}
{$IF not Declared(StringToUTF8)}
Function StringToUTF8(const Str: UnicodeString): UTF8String;{$IFDEF CanInline} inline; {$ENDIF}
{$DEFINE Implement_StringToUTF8}
{$IFEND}

{===============================================================================
    default string <-> explicit string conversion
===============================================================================}
type
{$IF Defined(FPC) and Defined(Unicode)}
  TRTLString = AnsiString;
{$ELSE}
  TRTLString = String;
{$IFEND}
{$IF not Defined(FPC) and Defined(Windows) and Defined(Unicode)}
  TWinString = WideString;
  TSysString = WideString;
{$ELSE}
  TWinString = AnsiString;
  TSysString = AnsiString;
{$IFEND}
{$IF not Defined(FPC) and Defined(Unicode)}
  TGUIString = UnicodeString;
{$ELSE}
  TGUIString = AnsiString;
{$IFEND}
{$IF Defined(FPC) and not Defined(Windows) and Defined(Unicode)}
  TCSLSTring = AnsiString;
{$ELSE}
  TCSLString = String;
{$IFEND}

Function StrToShort(const Str: String): ShortString;{$IFDEF CanInline} inline; {$ENDIF}
Function ShortToStr(const Str: ShortString): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToAnsi(const Str: String): AnsiString;{$IFDEF CanInline} inline; {$ENDIF}
Function AnsiToStr(const Str: AnsiString): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToUTF8(const Str: String): UTF8String;{$IFDEF CanInline} inline; {$ENDIF}
Function UTF8ToStr(const Str: UTF8String): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToWide(const Str: String): WideString;{$IFDEF CanInline} inline; {$ENDIF}
Function WideToStr(const Str: WideString): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToUnicode(const Str: String): UnicodeString;{$IFDEF CanInline} inline; {$ENDIF}
Function UnicodeToStr(const Str: UnicodeString): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToRTL(const Str: String): TRTLString;{$IFDEF CanInline} inline; {$ENDIF}
Function RTLToStr(const Str: TRTLString): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToGUI(const Str: String): TGUIString;{$IFDEF CanInline} inline; {$ENDIF}
Function GUIToStr(const Str: TGUIString): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToWinA(const Str: String): AnsiString;{$IFDEF CanInline} inline; {$ENDIF}
Function WinAToStr(const Str: AnsiString): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToWinW(const Str: String): WideString;{$IFDEF CanInline} inline; {$ENDIF}
Function WinWToStr(const Str: WideString): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToWin(const Str: String): TWinString;{$IFDEF CanInline} inline; {$ENDIF}
Function WinToStr(const Str: TWinString): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToCsl(const Str: String): TCSLSTring;{$IFDEF CanInline} inline; {$ENDIF}
Function CslToStr(const Str: TCSLSTring): String;{$IFDEF CanInline} inline; {$ENDIF}

Function StrToSys(const Str: String): TSysString;{$IFDEF CanInline} inline; {$ENDIF}
Function SysToStr(const Str: TSysString): String;{$IFDEF CanInline} inline; {$ENDIF}

{===============================================================================
    explicit string comparison
===============================================================================}

Function ShortStringCompare(const A,B: ShortString; CaseSensitive: Boolean): Integer;
Function AnsiStringCompare(const A,B: AnsiString; CaseSensitive: Boolean): Integer;
Function UTF8StringCompare(const A,B: UTF8String; CaseSensitive: Boolean): Integer;
Function WideStringCompare(const A,B: WideString; CaseSensitive: Boolean): Integer;
Function UnicodeStringCompare(const A,B: UnicodeString; CaseSensitive: Boolean): Integer;
Function StringCompare(const A,B: String; CaseSensitive: Boolean): Integer;

implementation

uses
  SysUtils
{$IF not Defined(FPC) and (CompilerVersion >= 20)}(* Delphi2009+ *)
  , AnsiStrings
{$IFEND}
{$IFDEF Windows}
  , Windows
{$ENDIF}
{$IF Defined(FPC) and Defined(Windows) and not Defined(BARE_FPC)}
(*
  If compiler raises and error that LazUTF8 unit cannot be found, you have to
  add LazUtils to required packages (Project > Project Inspector).
  Works only in Lazarus, if you are compiling in bare FPC, define (uncomment)
  symbol BARE_FPC (see defines at the beginning of this unit).
*)
  , LazUTF8
{$IFEND};

{===============================================================================
    auxiliary public functions
===============================================================================}

{$IFDEF Implement_UTF8ToString}
Function UTF8ToString(const Str: UTF8String): UnicodeString;
begin
Result := UTF8Decode(Str);
end;
{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF Implement_StringToUTF8}
Function StringToUTF8(const Str: UnicodeString): UTF8String;
begin
Result := UTF8Encode(Str);
end;
{$ENDIF}

{===============================================================================
    default string <-> explicit string conversion
===============================================================================}

{-------------------------------------------------------------------------------
    internal functions
-------------------------------------------------------------------------------}

{$IF Defined(FPC) and Defined(Windows)}

Function UnicodeToWinCP(const Str: UnicodeString; CodePage: UINT): AnsiString;
begin
If Length (Str) > 0 then
  begin
    SetLength(Result,WideCharToMultiByte(CodePage,0,PUnicodeChar(Str),Length(Str),nil,0,nil,nil));
    WideCharToMultiByte(CodePage,0,PUnicodeChar(Str),Length(Str),PAnsiChar(Result),Length(Result) * SizeOf(AnsiChar),nil,nil);
  {$IF Defined(FPC) and (FPC_FULLVERSION >= 20701)}
    SetCodePage(RawByteString(Result),CodePage,False);
  {$IFEND}
  end
else Result := '';
end;

//------------------------------------------------------------------------------

Function WinCPToUnicode(const Str: AnsiString; CodePage: UINT): UnicodeString;
const
  ExclCodePages: array[0..19] of Word = (50220,50221,50222,50225,50227,50229,52936,
    54936,57002,57003,57004,57005,57006,57007,57008,57009,57010,57011,65000,42);
var
  i:      Integer;
  Flags:  DWORD;
begin
If Length (Str) > 0 then
  begin
    Flags := MB_PRECOMPOSED;
    For i := Low(ExclCodePages) to High(ExclCodePages) do
      If CodePage = ExclCodePages[i] then
        begin
          Flags := 0;
          Break{For i};
        end;
    SetLength(Result,MultiByteToWideChar(CodePage,Flags,PAnsiChar(Str),Length(Str) * SizeOf(AnsiChar),nil,0));
    MultiByteToWideChar(CodePage,Flags,PAnsiChar(Str),Length(Str) * SizeOf(AnsiChar),PUnicodeChar(Result),Length(Result));
  end
else Result := '';
end;

{$IFEND}

//------------------------------------------------------------------------------

{$IF Defined(Windows) and not Defined(Unicode)}

Function AnsiToConsole(const Str: AnsiString): AnsiString;
begin
If Length (Str) > 0 then
  begin
    Result := StrToWinA(Str);
    UniqueString(Result);
    If not CharToOEMBuff(PAnsiChar(Result),PAnsiChar(Result),Length(Result)) then
      Result := '';
  end
else Result := '';
end;

//------------------------------------------------------------------------------

Function ConsoleToAnsi(const Str: AnsiString): AnsiString;
begin
If Length (Str) > 0 then
  begin
    Result := Str;
    UniqueString(Result);
    If OEMToCharBuff(PAnsiChar(Result),PAnsiChar(Result),Length(Result)) then
      Result := WinAToStr(Result)
    else
      Result := '';
  end
else Result := '';
end;

{$IFEND}

{-------------------------------------------------------------------------------
    public functions
-------------------------------------------------------------------------------}

Function StrToShort(const Str: String): ShortString;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := ShortString(StringToUTF8(Str));
    {$ELSE}
      // non-unicode FPC on Windows
      Result := ShortString({$IFDEF FPC_OLD_WIN_LAZ}UTF8ToWinCP{$ENDIF}(Str));
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := ShortString(StringToUTF8(Str));
    {$ELSE}
      // non-unicode FPC on Linux
      Result := ShortString(Str);
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := ShortString(Str);
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := ShortString(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := ShortString(StringToUTF8(Str));
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := ShortString(Str);
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function ShortToStr(const Str: ShortString): String;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := String(UTF8Decode(Str));
    {$ELSE}
      // non-unicode FPC on Windows
      Result := String({$IFDEF FPC_OLD_WIN_LAZ}WinCPToUTF8{$ENDIF}(Str));
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := String(UTF8Decode(Str));
    {$ELSE}
      // non-unicode FPC on Linux
      Result := String(Str);
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := String(Str);
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := String(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := String(UTF8ToString(Str));
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := String(Str);
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StrToAnsi(const Str: String): AnsiString;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := UnicodeToWinCP(Str,CP_ACP);
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFNDEF FPC_OLD_WIN_BARE}UnicodeToWinCP(UTF8Decode(Str),CP_ACP){$ELSE}Str{$ENDIF};
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := UTF8Encode(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := AnsiString(Str);
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := Str;
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := StringToUTF8(Str);
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function AnsiToStr(const Str: AnsiString): String;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := WinCPToUnicode(Str,CP_ACP);
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFNDEF FPC_OLD_WIN_BARE}UTF8Encode(WinCPToUnicode(Str,CP_ACP)){$ELSE}Str{$ENDIF};
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := UTF8Decode(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := String(Str);
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := Str;
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := UTF8ToString(Str);
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StrToUTF8(const Str: String): UTF8String;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := UTF8Encode(Str);
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFDEF FPC_OLD_WIN_BARE}AnsiToUTF8{$ENDIF}(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := UTF8Encode(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := StringToUTF8(Str);
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := AnsiToUTF8(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := StringToUTF8(Str);
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function UTF8ToStr(const Str: UTF8String): String;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := UTF8Decode(Str);
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFDEF FPC_OLD_WIN_BARE}UTF8ToAnsi{$ENDIF}(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := UTF8Decode(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := UTF8ToString(Str);
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := UTF8ToAnsi(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := UTF8ToString(Str);
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StrToWide(const Str: String): WideString;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := Str;
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFDEF FPC_OLD_WIN_BARE}WideString{$ELSE}UTF8ToString{$ENDIF}(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := Str; 
    {$ELSE}
      // non-unicode FPC on Linux
      Result := UTF8ToString(Str);
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;  
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := WideString(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := Str;  
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := UTF8ToString(Str);
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function WideToStr(const Str: WideString): String;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := Str;
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFDEF FPC_OLD_WIN_BARE}String{$ELSE}StringtoUTF8{$ENDIF}(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := Str;
    {$ELSE}
      // non-unicode FPC on Linux
      Result := StringtoUTF8(Str);
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := String(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := StringtoUTF8(Str);
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StrToUnicode(const Str: String): UnicodeString;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := Str;
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFDEF FPC_OLD_WIN_BARE}UnicodeString{$ELSE}UTF8ToString{$ENDIF}(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := Str;
    {$ELSE}
      // non-unicode FPC on Linux
      Result := UTF8ToString(Str);
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := UnicodeString(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := UTF8ToString(Str);
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function UnicodeToStr(const Str: UnicodeString): String;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := Str;
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFDEF FPC_OLD_WIN_BARE}String{$ELSE}StringtoUTF8{$ENDIF}(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := Str;
    {$ELSE}
      // non-unicode FPC on Linux
      Result := StringtoUTF8(Str);
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := String(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := StringtoUTF8(Str);
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StrToRTL(const Str: String): TRTLString;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := StringtoUTF8(Str);
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFDEF FPC_OLD_WIN_LAZ}UTF8ToWinCP{$ENDIF}(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := StringtoUTF8(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := Str;
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function RTLToStr(const Str: TRTLString): String;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := UTF8ToString(Str);
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFDEF FPC_OLD_WIN_LAZ}WinCPToUTF8{$ENDIF}(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := UTF8ToString(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := Str;
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StrToGUI(const Str: String): TGUIString;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := StringToUTF8(Str);
    {$ELSE}
      // non-unicode FPC on Windows
      Result := Str;
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := StringToUTF8(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := Str;
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function GUIToStr(const Str: TGUIString): String;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := UTF8ToString(Str);
    {$ELSE}
      // non-unicode FPC on Windows
      Result := Str;
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := UTF8ToString(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := Str;
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StrToWinA(const Str: String): AnsiString;
begin
Result := StrToAnsi(Str);
end;

//------------------------------------------------------------------------------

Function WinAToStr(const Str: AnsiString): String;
begin
Result := AnsitoStr(Str);
end;

//------------------------------------------------------------------------------

Function StrToWinW(const Str: String): WideString;
begin
Result := StrToWide(Str);
end;

//------------------------------------------------------------------------------

Function WinWToStr(const Str: WideString): String;
begin
Result := WideToStr(Str);
end;

//------------------------------------------------------------------------------

Function StrToWin(const Str: String): TWinString;
begin
Result := StrToSys(Str);
end;

//------------------------------------------------------------------------------

Function WinToStr(const Str: TWinString): String;
begin
Result := SysToStr(Str);
end;

//------------------------------------------------------------------------------

Function StrToCsl(const Str: String): TCSLSTring;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := Str;
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFDEF FPC_OLD_WIN_BARE}AnsiToConsole(Str)
        {$ELSE}UnicodeToWinCP(UTF8Decode(Str),CP_OEMCP){$ENDIF};
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := StringToUTF8(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := AnsiToConsole(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function CslToStr(const Str: TCSLSTring): String;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := Str;
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFDEF FPC_OLD_WIN_BARE}ConsoleToAnsi(Str)
        {$ELSE}UTF8Encode(WinCPToUnicode(Str,CP_OEMCP)){$ENDIF};
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := UTF8ToString(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := ConsoleToAnsi(Str);
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StrToSys(const Str: String): TSysString;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := UnicodeToWinCP(Str,CP_ACP);
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFNDEF FPC_OLD_WIN_BARE}UnicodeToWinCP(UTF8Decode(Str),CP_ACP){$ELSE}Str{$ENDIF};
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := StringToUTF8(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := Str;
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := StringToUTF8(Str);
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function SysToStr(const Str: TSysString): String;
begin
{$IFDEF FPC}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode FPC on Windows
      Result := WinCPToUnicode(Str,CP_ACP);
    {$ELSE}
      // non-unicode FPC on Windows
      Result := {$IFNDEF FPC_OLD_WIN_BARE}UTF8Encode(WinCPToUnicode(Str,CP_ACP)){$ELSE}Str{$ENDIF};
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode FPC on Linux
      Result := UTF8ToString(Str);
    {$ELSE}
      // non-unicode FPC on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF Windows}
    {$IFDEF Unicode}
      // unicode Delphi on Windows
      Result := Str;
    {$ELSE}
      // non-unicode Delphi on Windows
      Result := Str;
    {$ENDIF}
  {$ELSE}
    {$IFDEF Unicode}
      // unicode Delphi on Linux
      Result := UTF8ToString(Str);
    {$ELSE}
      // non-unicode Delphi on Linux
      Result := Str;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

{===============================================================================
    explicit string comparison
===============================================================================}

Function ShortStringCompare(const A,B: ShortString; CaseSensitive: Boolean): Integer;
begin
If CaseSensitive then
{$IF Defined(FPC) and Defined(Unicode)}
  Result := SysUtils.UnicodeCompareStr(ShortToStr(A),ShortToStr(B))
else
  Result := SysUtils.UnicodeCompareText(ShortToStr(A),ShortToStr(B));
{$ELSE}
  Result := SysUtils.AnsiCompareStr(ShortToStr(A),ShortToStr(B))
else
  Result := SysUtils.AnsiCompareText(ShortToStr(A),ShortToStr(B));
{$IFEND}
end;

//------------------------------------------------------------------------------

Function AnsiStringCompare(const A,B: AnsiString; CaseSensitive: Boolean): Integer;
begin
If CaseSensitive then
{$IFDEF FPC}
  Result := SysUtils.AnsiCompareStr(A,B)
else
  Result := SysUtils.AnsiCompareText(A,B)
{$ELSE}
{$IF Declared(AnsiStrings)}
  Result := AnsiStrings.AnsiCompareStr(A,B)
else
  Result := AnsiStrings.AnsiCompareText(A,B)
{$ELSE}
  Result := SysUtils.AnsiCompareStr(A,B)
else
  Result := SysUtils.AnsiCompareText(A,B)
{$IFEND}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function UTF8StringCompare(const A,B: UTF8String; CaseSensitive: Boolean): Integer;
begin
If CaseSensitive then
{$IFDEF FPC}
  Result := SysUtils.UnicodeCompareStr(UTF8ToString(A),UTF8ToString(B))
else
  Result := SysUtils.UnicodeCompareText(UTF8ToString(A),UTF8ToString(B))
{$ELSE}
{$IFDEF Unicode}
  Result := SysUtils.AnsiCompareStr(UTF8ToString(A),UTF8ToString(B))
else
  Result := SysUtils.AnsiCompareText(UTF8ToString(A),UTF8ToString(B))
{$ELSE}
  Result := SysUtils.WideCompareStr(UTF8ToString(A),UTF8ToString(B))
else
  Result := SysUtils.WideCompareText(UTF8ToString(A),UTF8ToString(B))
{$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function WideStringCompare(const A,B: WideString; CaseSensitive: Boolean): Integer;
begin
If CaseSensitive then
  Result := SysUtils.WideCompareStr(A,B)
else
  Result := SysUtils.WideCompareText(A,B)
end;

//------------------------------------------------------------------------------

Function UnicodeStringCompare(const A,B: UnicodeString; CaseSensitive: Boolean): Integer;
begin
If CaseSensitive then
{$IFDEF FPC}
  Result := SysUtils.UnicodeCompareStr(A,B)
else
  Result := SysUtils.UnicodeCompareText(A,B)
{$ELSE}
{$IFDEF Unicode}
  Result := SysUtils.AnsiCompareStr(A,B)
else
  Result := SysUtils.AnsiCompareText(A,B)
{$ELSE}
  Result := SysUtils.WideCompareStr(A,B)
else
  Result := SysUtils.WideCompareText(A,B)
{$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StringCompare(const A,B: String; CaseSensitive: Boolean): Integer;
begin
If CaseSensitive then
{$IF Defined(FPC) and Defined(Unicode)}
  Result := SysUtils.UnicodeCompareStr(A,B)
else
  Result := SysUtils.UnicodeCompareText(A,B)
{$ELSE}
  Result := SysUtils.AnsiCompareStr(A,B)
else
  Result := SysUtils.AnsiCompareText(A,B)
{$IFEND}
end;

end.
