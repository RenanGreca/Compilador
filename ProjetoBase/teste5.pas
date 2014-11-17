program proc2(input, output);
    var x,y: integer;
    label 1213,2345235;
    label 1234;
    function p(var t:integer): integer;
        var z:integer;
        begin
            if (t>1)
            then
                p:=1
            else
                y:=1;
            z:=y;
            1213:y:=z*t;
        end;
    begin
    1234:read(x);
        p(x);
        write(x,y);
        goto(1234);
    end.
