program comandowhile (input, output);
    var n, K: integer;
        f1, f2, f3: integer;
	a, b: char;
	x, y: boolean;
	l, r: string;
begin
    read(n);
    f1:=0; f2:=1; K:=1;
    while(K<n+1)
    begin
        f3:=f2+f1;
        f1:=f2;
        f2:=f3;
        f1:=K+1;
    end;
    write(n, K);
end.
