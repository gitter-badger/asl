{$g-}
       unit hex;

interface

       function hexnibble(b:byte):char;

       function hexbyte(b:byte):string;

       function hexword(b:word):string;



implementation

       function hexnibble;
begin
   b:=b and 15;
   if b<10 then hexnibble:=chr(b+48)
   else hexnibble:=chr(b+55);
end;

       function hexbyte;
begin
   hexbyte:=hexnibble(b shr 4)+hexnibble(b and 15);
end;

       function hexword;
begin
   hexword:=hexbyte(hi(b))+hexbyte(lo(b));
end;

begin
end. 