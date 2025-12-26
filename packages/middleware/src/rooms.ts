import * as toml from 'smol-toml';
import * as fs from 'node:fs';

export function register_room(){
  const data = { title: "Settings", version: 2 };

  try {
    fs.writeFileSync('./config.toml', toml.stringify(data), 'utf8');
  } catch (err) {
    console.error(err);
  }
}