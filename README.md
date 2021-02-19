# Salsa20_delphi
This is an implementation of the Salsa20 stream cipher

```delphi
procedure teststream;
var
  salsa: TSalsa20;
  clean_string: ansistring;
  dec_string: ansistring;
  enc_string: ansistring;
  Len: integer;
begin
  randomize();
  Len := 123001;

  clean_string := random_string(Len);

  setlength(dec_string, Len);
  FillChar(pointer(@dec_string[1])^, Len, #0);

  setlength(enc_string, Len);
  FillChar(pointer(@enc_string[1])^, Len, #0);

  salsa := TSalsa20.Create('139ff6934a2148e6ee032b92af058aa1');
  salsa.encodestring_stream(clean_string, enc_string);
  salsa.Destroy;

  salsa := TSalsa20.Create('139ff6934a2148e6ee032b92af058aa1');
  salsa.decodestring_stream(enc_string, dec_string);
  salsa.Destroy;

  if clean_string = dec_string then
    Showmessage('ok');
end;

procedure testblock;
var
  salsa: TSalsa20;
  clean_buff: ansistring;
  dec_buff: ansistring;
  enc_buff: ansistring;
  Len: integer;
begin
  randomize();
  Len := 64 * 1024;
  clean_buff := random_string(Len);

  setlength(dec_buff, Len);
  FillChar(pointer(@dec_buff[1])^, Len, #0);

  setlength(enc_buff, Len);
  FillChar(pointer(@enc_buff[1])^, Len, #0);

  salsa := TSalsa20.Create('139ff6934a2148e6ee032b92af058aa1');
  salsa.encodebuffer_ECB(@clean_buff[1], @enc_buff[1], Len);
  salsa.Destroy;

  salsa := TSalsa20.Create('139ff6934a2148e6ee032b92af058aa1');
  salsa.decodebuffer_ECB(@enc_buff[1], @dec_buff[1], Len);
  salsa.Destroy;

  if clean_buff = dec_buff then
    Showmessage('ok');
end;
```delphi
