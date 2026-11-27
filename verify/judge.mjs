// Officina — giudice. Gira in un job SENZA codice candidato: confronta gli output prodotti
// dal candidato con gli attesi letti dalla copia fidata (o dal repository di accettazione).
// Non legge mai dichiarazioni di esito del candidato: ricalcola tutto dai dati grezzi.
// Uso: node judge.mjs <dir_output_candidato> <dir_attesi_fidati>
import { readdirSync, readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';
const [out, expectedDir] = process.argv.slice(2);
const cases = readdirSync(expectedDir).filter(f => f.endsWith('.json')).sort();
if (cases.length === 0) { console.log('JUDGE: FAIL nessun caso atteso'); process.exit(1); }
let fail = 0;
for (const c of cases) {
  const exp = JSON.parse(readFileSync(join(expectedDir, c), 'utf8'));
  const p = join(out, c);
  if (!existsSync(p)) { console.log(`FAIL ${c}: output mancante (NOT RUN)`); fail++; continue; }
  let got; try { got = JSON.parse(readFileSync(p, 'utf8')); } catch { console.log(`FAIL ${c}: output non valido`); fail++; continue; }
  const ok = JSON.stringify(got) === JSON.stringify(exp);
  console.log(`${ok ? 'PASS' : 'FAIL'} ${c}${ok ? '' : ` atteso=${JSON.stringify(exp)} osservato=${JSON.stringify(got)}`}`);
  if (!ok) fail++;
}
console.log(`JUDGE: ${fail ? 'FAIL' : 'PASS'} casi=${cases.length} falliti=${fail}`);
process.exit(fail ? 1 : 0);
