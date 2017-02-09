﻿// ***************************************************************************
//
// Delphi MVC Framework
//
// Copyright (c) 2010-2017 Daniele Teti and the DMVCFramework Team
//
// https://github.com/danieleteti/delphimvcframework
//
// ***************************************************************************
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// *************************************************************************** }

unit SerializationFrameworkTestsU;

interface


uses
  TestFramework,
  MVCFramework.Router,
  System.Generics.Collections,
  MVCFramework, Data.DB, System.SysUtils, MVCFramework.JWT,
  MVCFramework.TypesAliases, MVCFramework.Serializer.Intf, FrameworkTestsU;

type
  TTestJSONSerializer = class(TMVCSerUnSerTestCase)
  protected
    procedure SetUp; override;
  published
    procedure TestSerUnSerObject; override;
    procedure TestSerUnSerObjectList; override;
    procedure TestSerUnSerObjectWithStream; override;
    procedure TestSerUnSerObjectListWithStream; override;
    procedure TestSerUnSerObjectWithTValue; override;
    procedure TestSerUnSerObjectListWithTValue; override;
    procedure TestSerUnSerObjectStrict; override;
    procedure TestSerUnSerObjectBuiltInCustomTypes; override;
  end;

implementation

{$WARN SYMBOL_DEPRECATED OFF}


uses BOs, MVCFramework.Serializer.JSON, MVCFramework.DuckTyping,
  System.Classes, Winapi.Windows;

function GetMyObjectWithCustomType: TObjectWithCustomType;
begin
  Result := TObjectWithCustomType.Create;
  Result.PropStringList.Add('item 1');
  Result.PropStringList.Add('item 2');
  Result.PropStringList.Add('item 3');
  Result.PropStringList.Add('item 4');
end;

{ TTestJSONSerializer }

procedure TTestJSONSerializer.SetUp;
begin
  SetSerializer(TMVCJSONSerUnSer.Create);
end;

procedure TTestJSONSerializer.TestSerUnSerObject;
var
  Obj: TMyObject;
  JSON: string;
  Obj2: TMyObject;
begin
  Obj := GetMyObject;
  try
    JSON := Serializer.SerializeObject(Obj, []);
    Obj2 := TMyObject.Create;
    try
      Serializer.DeserializeObject(JSON, Obj2);
      CheckTrue(Obj.Equals(Obj2));
    finally
      Obj2.Free;
    end;
  finally
    Obj.Free;
  end;
end;

procedure TTestJSONSerializer.TestSerUnSerObjectBuiltInCustomTypes;
var
  Obj: TObjectWithCustomType;
  JSON: string;
  Obj2: TObjectWithCustomType;
begin
  Obj := GetMyObjectWithCustomType;
  try
    JSON := Serializer.SerializeObject(Obj, []);
    Obj2 := TObjectWithCustomType.Create;
    try
      Serializer.DeserializeObject(JSON, Obj2);
      CheckTrue(Obj.Equals(Obj2));
    finally
      Obj2.Free;
    end;
  finally
    Obj.Free;
  end;
end;

procedure TTestJSONSerializer.TestSerUnSerObjectList;
var
  ObjList, Obj2List: TObjectList<TMyObject>;
  lJSON: String;
  I: Integer;
begin
  ObjList := GetObjectsList;
  try
    lJSON := Serializer.SerializeCollection(ObjList, []);
    Obj2List := TObjectList<TMyObject>.Create(True);
    try
      Serializer.DeserializeCollection(lJSON, WrapAsList(Obj2List), TMyObject);
      CheckEquals(ObjList.Count, Obj2List.Count);
      for I := 0 to 9 do
      begin
        CheckTrue(Obj2List[I].Equals(ObjList[I]));
      end;
    finally
      Obj2List.Free;
    end;
  finally
    ObjList.Free;
  end;
end;

procedure TTestJSONSerializer.TestSerUnSerObjectListWithStream;
var
  ObjList, Obj2List: TObjectList<TMyStreamObject>;
  lJSON: String;
  I: Integer;
begin
  ObjList := GetObjectsWithStreamsList;
  try
    lJSON := Serializer.SerializeCollection(ObjList, []);
    Obj2List := TObjectList<TMyStreamObject>.Create(True);
    try
      Serializer.DeserializeCollection(lJSON, WrapAsList(Obj2List), TMyStreamObject);
      CheckEquals(ObjList.Count, Obj2List.Count);
      for I := 0 to 9 do
      begin
        CheckTrue(Obj2List[I].Equals(ObjList[I]), 'TMyStreamObject instances are not equal');
      end;
    finally
      Obj2List.Free;
    end;
  finally
    ObjList.Free;
  end;
end;

procedure TTestJSONSerializer.TestSerUnSerObjectListWithTValue;
var
  ObjList, Obj2List: TObjectList<TMyObjectWithTValue>;
  lJSON: String;
  I: Integer;
begin
  ObjList := GetObjectsWithTValueList;
  try
    lJSON := Serializer.SerializeCollection(ObjList, []);
    Obj2List := TObjectList<TMyObjectWithTValue>.Create(True);
    try
      Serializer.DeserializeCollection(lJSON, WrapAsList(Obj2List), TMyObjectWithTValue);
      CheckEquals(ObjList.Count, Obj2List.Count);
      for I := 0 to 9 do
      begin
        CheckTrue(Obj2List[I].Equals(ObjList[I]));
      end;
    finally
      Obj2List.Free;
    end;
  finally
    ObjList.Free;
  end;
end;

procedure TTestJSONSerializer.TestSerUnSerObjectStrict;
var
  Obj: TMyObject;
  JSON: string;
  Obj2: TMyObject;
begin
  Obj := GetMyObject;
  try
    JSON := Serializer.SerializeObjectStrict(Obj);
    Obj2 := TMyObject.Create;
    try
      Serializer.DeserializeObjectStrict(JSON, Obj2);
      CheckTrue(Obj.Equals(Obj2));
    finally
      Obj2.Free;
    end;
  finally
    Obj.Free;
  end;
end;

procedure TTestJSONSerializer.TestSerUnSerObjectWithStream;
var
  Obj: TMyStreamObject;
  JSON: String;
  Obj2: TMyStreamObject;
  Buff: TBytes;
begin
  // ARRANGE
  Obj := GetMyObjectWithStream;
  try
    // ACT
    JSON := Serializer.SerializeObject(Obj, []);
    Obj2 := TMyStreamObject.Create;
    try
      Serializer.DeserializeObject(JSON, Obj2);
      // ASSERT
      CheckEquals('This is an UTF16 String', TStringStream(Obj2.PropStream).DataString);
      CheckEquals('This is an UTF8 String', TStringStream(Obj2.Prop8Stream).DataString);
      CheckEquals(BASE64_STRING, TEncoding.ANSI.GetString(TMemoryStream(Obj2.ImageStream).Memory, 0,
        Length(BASE64_STRING)));
    finally
      Obj2.Free;
    end;
  finally
    Obj.Free;
  end;
end;

procedure TTestJSONSerializer.TestSerUnSerObjectWithTValue;
var
  lObj: TMyObjectWithTValue;
  JSON: string;
  Obj2: TMyObjectWithTValue;
begin
  lObj := GetMyObjectWithTValue;
  try
    JSON := Serializer.SerializeObject(lObj, []);
    Obj2 := TMyObjectWithTValue.Create;
    try
      Serializer.DeserializeObject(JSON, Obj2);
      CheckTrue(lObj.Equals(Obj2));
    finally
      Obj2.Free;
    end;
  finally
    lObj.Free;
  end;
end;

initialization

RegisterTest(TTestJSONSerializer.suite);

finalization

end.
