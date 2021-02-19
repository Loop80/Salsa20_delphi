unit salsa20unit;

interface

uses Windows, SysUtils, classes;

const
  VECTOR_SIZE = 16;
  BLOCK_SIZE = 64;
  KEY_SIZE = 32;
  IV_SIZE = 8;
  IV_OFFSET = 32;

type

  TSalsa20 = Class(TObject)
  private
    vector_: array [0 .. VECTOR_SIZE - 1] of Integer;

    function rotate(value: Integer; numBits: Integer): Integer;
    procedure convert(value: Integer; data: PAnsiChar);
    function convert_2(data: PAnsiChar): Integer;
    procedure setKey(key: PAnsiChar);
    procedure setIv(iv: PAnsiChar);
    procedure generateKeyStream(output: PAnsiChar);
    procedure processBlocks(input: PAnsiChar; output: PAnsiChar;
      numBlocks: Integer);
    procedure processBytes(input: PAnsiChar; output: PAnsiChar;
      numBytes: Integer);
  protected

  public
    procedure encodestring_stream(var input: ansistring;
      var output: ansistring);
    procedure decodestring_stream(var input: ansistring;
      var output: ansistring);

    procedure encodebuffer_ECB(input: PAnsiChar; output: PAnsiChar;
      buffer_length: Integer);
    procedure decodebuffer_ECB(input: PAnsiChar; output: PAnsiChar;
      buffer_length: Integer);

    constructor Create(key: ansistring);

  published

  end;

implementation

constructor TSalsa20.Create(key: ansistring);
begin
  FillChar(pointer(@vector_[0])^, sizeof(vector_), 0);
  key := key + '00000000';
  setKey(@key[1]);
  setIv(@key[IV_OFFSET]);
end;

function TSalsa20.rotate(value: Integer; numBits: Integer): Integer;
begin
  result := (value shl numBits) or (value shr (32 - numBits));
end;

procedure TSalsa20.convert(value: Integer; data: PAnsiChar);
begin
  data[0] := ansichar(value shr 0);
  data[1] := ansichar(value shr 8);
  data[2] := ansichar(value shr 16);
  data[3] := ansichar(value shr 24);
end;

function TSalsa20.convert_2(data: PAnsiChar): Integer;
begin
  result := ((Integer(data[0]) shl 0) or (Integer(data[1]) shl 8) or
    (Integer(data[2]) shl 16) or (Integer(data[3]) shl 24));
end;

const
  constants = 'expand 32-byte k';

procedure TSalsa20.setKey(key: PAnsiChar);
begin
  vector_[0] := convert_2(@constants[1]);
  vector_[1] := convert_2(@key[0]);
  vector_[2] := convert_2(@key[4]);
  vector_[3] := convert_2(@key[8]);
  vector_[4] := convert_2(@key[12]);
  vector_[5] := convert_2(@constants[4]);

  FillChar(pointer(@vector_[6])^, 16, 0);

  vector_[10] := convert_2(@constants[8]);
  vector_[11] := convert_2(@key[16]);
  vector_[12] := convert_2(@key[20]);
  vector_[13] := convert_2(@key[24]);
  vector_[14] := convert_2(@key[28]);
  vector_[15] := convert_2(@constants[12]);
end;

procedure TSalsa20.setIv(iv: PAnsiChar);
begin
  vector_[6] := convert_2(@iv[0]);
  vector_[7] := convert_2(@iv[4]);
  vector_[8] := 0;
  vector_[9] := 0;
end;

procedure TSalsa20.generateKeyStream(output: PAnsiChar);
var
  x: array [0 .. VECTOR_SIZE - 1] of Integer;
  i: Integer;
begin
  CopyMemory(@x[0], @vector_[0], sizeof(vector_));
  i := 20;
  while i > 0 do
  begin
    x[4] := x[4] xor rotate(Integer(x[0] + x[12]), 7);
    x[8] := x[8] xor rotate(Integer(x[4] + x[0]), 9);
    x[12] := x[12] xor rotate(Integer(x[8] + x[4]), 13);
    x[0] := x[0] xor rotate(Integer(x[12] + x[8]), 18);
    x[9] := x[9] xor rotate(Integer(x[5] + x[1]), 7);
    x[13] := x[13] xor rotate(Integer(x[9] + x[5]), 9);
    x[1] := x[1] xor rotate(Integer(x[13] + x[9]), 13);
    x[5] := x[5] xor rotate(Integer(x[1] + x[13]), 18);
    x[14] := x[14] xor rotate(Integer(x[10] + x[6]), 7);
    x[2] := x[2] xor rotate(Integer(x[14] + x[10]), 9);
    x[6] := x[6] xor rotate(Integer(x[2] + x[14]), 13);
    x[10] := x[10] xor rotate(Integer(x[6] + x[2]), 18);
    x[3] := x[3] xor rotate(Integer(x[15] + x[11]), 7);
    x[7] := x[7] xor rotate(Integer(x[3] + x[15]), 9);
    x[11] := x[11] xor rotate(Integer(x[7] + x[3]), 13);
    x[15] := x[15] xor rotate(Integer(x[11] + x[7]), 18);
    x[1] := x[1] xor rotate(Integer(x[0] + x[3]), 7);
    x[2] := x[2] xor rotate(Integer(x[1] + x[0]), 9);
    x[3] := x[3] xor rotate(Integer(x[2] + x[1]), 13);
    x[0] := x[0] xor rotate(Integer(x[3] + x[2]), 18);
    x[6] := x[6] xor rotate(Integer(x[5] + x[4]), 7);
    x[7] := x[7] xor rotate(Integer(x[6] + x[5]), 9);
    x[4] := x[4] xor rotate(Integer(x[7] + x[6]), 13);
    x[5] := x[5] xor rotate(Integer(x[4] + x[7]), 18);
    x[11] := x[11] xor rotate(Integer(x[10] + x[9]), 7);
    x[8] := x[8] xor rotate(Integer(x[11] + x[10]), 9);
    x[9] := x[9] xor rotate(Integer(x[8] + x[11]), 13);
    x[10] := x[10] xor rotate(Integer(x[9] + x[8]), 18);
    x[12] := x[12] xor rotate(Integer(x[15] + x[14]), 7);
    x[13] := x[13] xor rotate(Integer(x[12] + x[15]), 9);
    x[14] := x[14] xor rotate(Integer(x[13] + x[12]), 13);
    x[15] := x[15] xor rotate(Integer(x[14] + x[13]), 18);
    i := i - 2;
  end;

  for i := 0 to VECTOR_SIZE - 1 do
  begin
    x[i] := x[i] + vector_[i];
    convert(x[i], @output[4 * i]);
  end;
  vector_[8] := vector_[8] + 1;
  if vector_[8] = 0 then
    vector_[9] := vector_[9] + 1;
end;

procedure TSalsa20.processBlocks(input: PAnsiChar; output: PAnsiChar;
  numBlocks: Integer);
var
  keyStream: array [0 .. BLOCK_SIZE - 1] of byte;
  i, j, block: Integer;
  pkeyStream: pointer;
begin
  block := 0;
  for i := 1 to numBlocks do
  begin
    generateKeyStream(@keyStream[0]);

    for j := 0 to BLOCK_SIZE - 1 do
    begin
      output[j + block] := ansichar(keyStream[j] xor byte(input[j + block]));
    end;
    block := block + BLOCK_SIZE;
  end;
end;

procedure TSalsa20.processBytes(input: PAnsiChar; output: PAnsiChar;
  numBytes: Integer);
var
  keyStream: array [0 .. BLOCK_SIZE - 1] of byte;
  i, j: Integer;
  numBytesToProcess: Integer;
begin
  j := 0;
  while (numBytes <> 0) do
  begin
    generateKeyStream(@keyStream[0]);

    if numBytes >= BLOCK_SIZE then
      numBytesToProcess := BLOCK_SIZE
    else if numBytes < BLOCK_SIZE then
      numBytesToProcess := numBytes;

    for i := 0 to numBytesToProcess - 1 do
    begin
      numBytes := numBytes - 1;

      output[j] := ansichar(keyStream[i] xor byte(input[j]));
      Inc(j);
    end;
  end;
end;

procedure TSalsa20.encodestring_stream(var input: ansistring;
  var output: ansistring);
var
  i, iter: Integer;
begin
  if length(input) <> length(output) then
    exit;

  processBytes(@input[1], @output[1], length(input));
end;

procedure TSalsa20.decodestring_stream(var input: ansistring;
  var output: ansistring);
begin
  if length(input) <> length(output) then
    exit;

  processBytes(@input[1], @output[1], length(input));
end;

procedure TSalsa20.encodebuffer_ECB(input: PAnsiChar; output: PAnsiChar;
  buffer_length: Integer);
var
  i, iter: Integer;
begin
  if buffer_length mod BLOCK_SIZE <> 0 then
    exit;

  iter := buffer_length div BLOCK_SIZE;
  processBlocks(@input[0], @output[0], iter);
end;

procedure TSalsa20.decodebuffer_ECB(input: PAnsiChar; output: PAnsiChar;
  buffer_length: Integer);
var
  i, iter: Integer;
begin
  if buffer_length mod BLOCK_SIZE <> 0 then
    exit;

  iter := buffer_length div BLOCK_SIZE;
  processBlocks(@input[0], @output[0], iter);
end;

end.
