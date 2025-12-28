import dotenv from "dotenv";
import fs from "node:fs";
import path from "node:path";
import * as toml from "smol-toml";
import {mergeDeep} from "../../utils.js";

export function loadSettings() {
  dotenv.config()
}

export function loadCredentials() {
  if (process.env['CREDENTIALS_FILE']) {
    dotenv.config({
      path: process.env['CREDENTIALS_FILE']
    });
  } else {
    throw new Error("Credentials not provided! Use CREDENTIALS_FILE env var.");
  }
}

export function resolveConfigurationFile(...paths: string[]) : SyncConfigurationFile {
  return new SyncConfigurationFile({
    path: path.join(...paths),
    data: {}
  });
}

export interface ConfigurationFile {
  path: string,
  data: object
}

export class SyncConfigurationFile implements ConfigurationFile {

  constructor(props: ConfigurationFile) {
    this.path = path.resolve(process.env.STORAGE_DIR || path.join('storage'), props.path);

    let parentPath = path.dirname(this.path);

    if (!fs.existsSync(parentPath)) {
      fs.mkdirSync(parentPath, { recursive: true });
    }
    if(!fs.existsSync(this.path)) {
      this._data = props.data;
    }
    else {
      this.load();
    }
  }

  path: string;
  _data: object = {};

  public get data(): object {
    if(!this._data) {
      this.load();
    }
    return this._data!;
  }

  public set data(value: object) {
    this._data = value;
    this.save();
  }

  public load() {
    this._data = toml.parse(
      fs.readFileSync(this.path, {encoding: 'utf-8'})
    );
    // console.log(`[ConfigurationFile ${path.basename(path.dirname(this.path))}]`, '[load]', this._data)
    return this._data;
  }

  public save() {
    // console.log(`[ConfigurationFile ${path.basename(path.dirname(this.path))}]`, '[save]', this._data)
    fs.writeFileSync(this.path, toml.stringify(this._data), {encoding: 'utf-8'});
  }

}