import org.gradle.plugins.ide.idea.model.IdeaLanguageLevel

plugins {
    // IDE
    // ------------------------------------------------------------------------
    id("idea")
}

idea {
    project {
        languageLevel = IdeaLanguageLevel(extra["jdk.language.level"])
    }
    module {
        isDownloadJavadoc = true
        isDownloadSources = true
    }
}
