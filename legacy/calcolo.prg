* Calcolo colli packing list (legacy, sintetico)
PROCEDURE TotColli
LPARAMETERS tcAlias
LOCAL lnTot
lnTot = 0
SELECT (tcAlias)
SCAN FOR qta > 0
  lnTot = lnTot + CEILING(qta / percollo)
ENDSCAN
RETURN lnTot
ENDPROC
