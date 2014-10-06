program comandoIf(input, output);
    var i, j: integer;
begin
    read(j);
    i:=0;
    while (i<j)
    begin
        if (i / 2 * 2 = i) then
	begin
            write (i,0);
	end else
	begin
            write (i,1);
	end;
        i := i + 1;
    end;
end.
