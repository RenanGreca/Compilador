program comandowhile (input, output);
    var n, k: integer;
        f1, f2, f3: integer;
begin
    read(n);
    f1:=0; f2:=1; k:=1;
    while(k<n)
    begin
        f3:=f2+f1;
        f1:=f2;
        f2:=f3;
        f1:=k+1;
    end;
    write(n, k);
end.