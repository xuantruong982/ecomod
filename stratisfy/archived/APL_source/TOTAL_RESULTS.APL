R刄NITS TOTAL_RESULTS DATA;varindex;avgindex;I

varindex刟vgindexﭬ

:FOR I :IN 冀DATA[;6]
    :IF 协�(淒ATA[I;6])[1;1]
    :ELSEIF 1=喗�(DATA)[I;6]
        avgindex刟vgindex,I
    :ELSE
        avgindex刟vgindex,I
        varindex剉arindex,I
    :ENDIF
:ENDFOR

variance劰+/DATA[varindex;3]    

� TOTAL                TOTALVAR      MEAN                                                      MEANVARIANCE                       NESTED DATA     
R�(�+/TMP[avgindex;2]) (variance)    (�+/(UNITS[avgindex]�+/UNITS[avgindex])譊ATA[avgindex;4]) (variance�((+/UNITS[varindex])*2)) DATA 