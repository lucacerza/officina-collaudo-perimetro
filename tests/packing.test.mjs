import test from 'node:test'; import assert from 'node:assert/strict';
import { totaleColli } from '../src/packing.mjs';
test('righe intere', () => assert.equal(totaleColli([{ quantita: 24, perCollo: 12 }, { quantita: 5, perCollo: 5 }]), 3));
test('riga a quantita zero non conta colli', () => assert.equal(totaleColli([{ quantita: 0, perCollo: 6 }]), 0));
