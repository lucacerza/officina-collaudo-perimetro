// Packing list: il totale colli somma i colli delle righe.
export function totaleColli(righe) {
  let tot = 0;
  for (const r of righe) tot += Math.ceil(r.quantita / r.perCollo) || 1;
  return tot;
}
