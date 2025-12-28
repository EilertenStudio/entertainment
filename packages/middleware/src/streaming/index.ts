import {resolveConfigurationFile} from "../configuration/index.js";

export class StreamingConfiguration {

  config = resolveConfigurationFile("streaming", "config.toml")

}

export const StreamingManager = new StreamingConfiguration();