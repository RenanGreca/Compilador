for D in `find PgmasTeste/ -type d`;
do
	./compilador ${D}/pgma.pas > saida
	cp MEPA ${D}/MEPA.out
	diff ${D}/MEPA ${D}/MEPA.out > ${D}/MEPA.diff

	echo "${D}"
	cat ${D}/MEPA.diff
done
