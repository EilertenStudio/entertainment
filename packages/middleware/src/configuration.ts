import dotenv from "dotenv";

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