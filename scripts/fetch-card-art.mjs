import { readFile, access, rename, unlink } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import path from 'node:path';

const directory = fileURLToPath(new URL('../CreditCardRecord/CardArt/', import.meta.url));
const entries = JSON.parse(await readFile(path.join(directory, 'manifest.json'), 'utf8'));
const hosts = new Set(['www.hsbc.com.hk', 'www.citibank.com.hk', 'www.hangseng.com', 'www.dbs.com.hk', 'www.cathaybk.com.tw', 'www.esunbank.com', 'www.easycard.com.tw']);
for (const entry of entries) {
  if (!/^[a-z0-9-]+\.(png|jpg)$/.test(entry.file) || !hosts.has(new URL(entry.url).hostname) || !entry.url.startsWith('https://')) {
    throw new Error(`Invalid card artwork entry: ${entry.id}`);
  }
  const destination = path.join(directory, entry.file);
  try { await access(destination); continue; } catch {}
  const temporary = destination + '.download';
  const result = spawnSync('curl', ['--fail', '--silent', '--show-error', '--location', '--proto', '=https', '--proto-redir', '=https', '--max-time', '30', '--retry', '1', '--output', temporary, entry.url], { stdio: 'inherit' });
  if (result.status !== 0) {
    await unlink(temporary).catch(() => {});
    throw new Error(`Download failed: ${entry.id}`);
  }
  const bytes = await readFile(temporary);
  const png = bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]));
  const jpeg = bytes[0] === 255 && bytes[1] === 216;
  if (!(png || jpeg) || bytes.length > 5_000_000) {
    await unlink(temporary);
    throw new Error(`Unexpected image data: ${entry.id}`);
  }
  await rename(temporary, destination);
  console.log(`Downloaded ${entry.id}: ${bytes.length} bytes`);
}
