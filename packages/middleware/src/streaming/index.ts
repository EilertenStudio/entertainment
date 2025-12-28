import {resolveConfigurationFile} from "../configuration/index.js";

export class StreamingContext {

  config = resolveConfigurationFile("streaming", "config.toml")

}

export const StreamingManager = new StreamingContext();