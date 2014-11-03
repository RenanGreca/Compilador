program proc2(input, output);
    var x,y: integer;
    function p(t:integer): integer;
        var z:integer;
        begin
            if (t>1)
                then
                        p:=1
                else
                y:=1;
            z:=y;
            y:=z*t;
        end;
    begin
        read(x);
        p(x);
        write(x,y);
    end.
