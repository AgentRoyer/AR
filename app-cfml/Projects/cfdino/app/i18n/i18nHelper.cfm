<cfscript>
function i18nNormalizeLanguage(string lang = "en") {
    var normalized = lCase(trim(arguments.lang));
    return listFindNoCase("en,fr", normalized) ? normalized : "en";
}

function getMessages(required string lang, string prefix = "") {
    var locale = i18nNormalizeLanguage(arguments.lang);
    var fileName = len(arguments.prefix) ? arguments.prefix & "-" & locale & ".json" : locale & ".json";
    var filePath = expandPath("/app/i18n/" & fileName);

    if (!fileExists(filePath)) {
        return {};
    }

    try {
        return deserializeJSON(fileRead(filePath));
    } catch (any exception) {
        return {};
    }
}

function t(required string key, required struct messages, required struct fallbackMessages) {
    var keyParts = listToArray(arguments.key, ".");
    var selectedValue = i18nLookup(arguments.messages, keyParts);
    var fallbackValue = i18nLookup(arguments.fallbackMessages, keyParts);

    if (isSimpleValue(selectedValue) AND len(trim(selectedValue))) {
        return selectedValue;
    }

    return isSimpleValue(fallbackValue) ? fallbackValue : "";
}

function i18nLookup(required struct messages, required array keyParts) {
    var value = arguments.messages;

    for (var keyPart in arguments.keyParts) {
        if (!isStruct(value) OR !structKeyExists(value, keyPart)) {
            return "";
        }
        value = value[keyPart];
    }

    return value;
}
</cfscript>