program testebool(input, output);

var b : boolean;
    a : integer;

function f(b1 : boolean; var b2:boolean):boolean;
var b3 :  boolean;
begin
   if (b1 = b2) then
      b3:=true
   else
      b3:=false;
   f := b3
end;

begin
   read(a);
   b := a>10;
   b := f (true, b); (*  b := true=b; *)
   b := f (a>10, b); (*  b := (a>10)=b; *)
   while (b) do
      if (b) then
         b:=false;
   b:= true > false;
   b:= true > 10 (* Erro a ser detectado*)
end.

