-- Client-facing English/Arabic text for the wallet and tool shop.
-- Pure module: no Roblox services, safe to test with standalone Luau.
local Locale = {}
local strings = {
    en = {
        shop = "Shop", coins = "Coins", xp = "XP", caught = "Caught",
        buy = "Buy", equip = "Equip", equipped = "Equipped",
        catches = "catches", companion = "Companion", switch = "Tap to switch",
        catchFirst = "Catch a cloud to unlock companion",
        train = "Train Range", maxRange = "Range Training MAX",
        purchased = "Purchased!", level = "Lv", max = "MAX",
    },
    ar = {
        shop = "المتجر", coins = "عملات", xp = "خبرة", caught = "تم صيدها",
        buy = "شراء", equip = "تجهيز", equipped = "مجهّز",
        catches = "سحابة", companion = "الرفيق", switch = "اضغط للتغيير",
        catchFirst = "اصطد سحابة لفتح الرفيق",
        train = "تطوير المدى", maxRange = "المدى في أقصى مستوى",
        purchased = "تم الشراء!", level = "مستوى", max = "الأقصى",
    },
}
function Locale.normalize(value)
    return value == "ar" and "ar" or "en"
end
function Locale.text(language, key)
    local code = Locale.normalize(language)
    return strings[code][key] or strings.en[key] or tostring(key)
end
function Locale.number(value)
    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
        return "0"
    end
    local sign = value < 0 and "-" or ""
    local n = math.floor(math.abs(value))
    if n < 1000 then return sign .. tostring(n) end
    local units = { {1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"} }
    for _, unit in ipairs(units) do
        if n >= unit[1] then
            local scaled = math.floor(n / unit[1] * 10) / 10
            return sign .. string.format("%.1f%s", scaled, unit[2])
        end
    end
    return "0"
end
return table.freeze(Locale)
