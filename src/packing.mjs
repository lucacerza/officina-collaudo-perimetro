// Packing list: il totale colli somma i colli delle righe.
export function totaleColli(righe) {
  let tot = 0;
  for (const r of righe) if (r.quantita > 0) tot += Math.ceil(r.quantita / r.perCollo);
  return tot;
}
