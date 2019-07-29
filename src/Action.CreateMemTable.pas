unit Action.CreateMemTable;

interface

uses
  System.Classes, System.Types, System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client;

type
  TCreateMemTableAction = class(TComponent)
  private
    FCode: TStrings;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;
    function CreateFDMemTable(dataSet: TDataSet): TFDMemTable;
    procedure GenerateCode(dataSet: TDataSet);
    property Code: TStrings read FCode write FCode;
  end;

implementation

constructor TCreateMemTableAction.Create(AOwner: TComponent);
begin
  inherited;
  FCode := TStringList.Create;
end;

destructor TCreateMemTableAction.Destroy;
begin
  FCode.Free;
end;

function TCreateMemTableAction.CreateFDMemTable(dataSet: TDataSet): TFDMemTable;
var
  fld: TField;
begin
  dataSet.Open;
  Result := TFDMemTable.Create(Self);
  for fld in dataSet.Fields do
  begin
    if fld.DataType in [ftAutoInc, ftInteger, ftWord, ftSmallint, ftLargeint,
      ftBoolean, ftFloat, ftCurrency, ftDate, ftTime, ftDateTime] then
      Result.FieldDefs.Add(fld.FieldName, fld.DataType)
    else if (fld.DataType in [ftString, ftWideString]) and (fld.Size > 9999)
    then
      Result.FieldDefs.Add(fld.FieldName, fld.DataType, 100)
    else if (fld.DataType in [ftString, ftWideString]) then
      Result.FieldDefs.Add(fld.FieldName, fld.DataType, fld.DataSize)
    else
      Result.FieldDefs.Add(fld.FieldName, fld.DataType, fld.DataSize);
  end;
  Result.CreateDataSet;
  dataSet.DisableControls;
  dataSet.First;
  while not dataSet.Eof do
  begin
    Result.Insert;
    for fld in dataSet.Fields do
    begin
      Result.FieldByName(fld.FieldName).Value :=
        dataSet.FieldByName(fld.FieldName).Value;
    end;
    Result.Post;
    dataSet.Next;
  end;
  Result.First;
  dataSet.EnableControls;
end;

procedure TCreateMemTableAction.GenerateCode(dataSet: TDataSet);
var
  sl: TStringList;
begin
  With Code do
  begin
    Clear;
    Add('ds := TFDMemTable.Create(AOwner);');
    Add('with ds do');
    Add('begin');
    Add('  FieldDefs.Add(''id'', ftInteger);');
    Add('  FieldDefs.Add(''text1'', ftWideString, 30);');
    Add('  CreateDataSet;');
    Add('end;');
  end;
end;

end.
