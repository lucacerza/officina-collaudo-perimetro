// Officina (esempio di progetto) — produttore: esegue il codice candidato sugli INPUT fidati
// e scrive solo output grezzi. Non conosce gli attesi. Uso (cwd = copia candidata): node produce.mjs <dir_out>
import { readdirSync, readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
const out = resolve(process.argv[2]); mkdirSync(out, { recursive: true });
const trustedCases = join(dirname(fileURLToPath(import.meta.url)), '..', 'acceptance', 'cases');
const { totaleColli } = await import(pathToFileURL(resolve('src/packing.mjs')).href);
for (const c of readdirSync(trustedCases).filter(f => f.endsWith('.json'))) {
  const input = JSON.parse(readFileSync(join(trustedCases, c), 'utf8'));
  writeFileSync(join(out, c), JSON.stringify({ colli: totaleColli(input.righe) }));
}
