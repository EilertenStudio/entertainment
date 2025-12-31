import { resolveConfigurationFile } from "../configuration/index.js";
export class StreamingContext {
    configFile = resolveConfigurationFile("streaming", "config.toml");
}
export const StreamingManager = new StreamingContext();
//# sourceMappingURL=index.js.map