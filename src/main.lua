local TAG = "main"

--
-- global
--
traceBack = function()
    print(debug.traceback("", 2))
end

safelyCall = function(fn, ...)
    if (type(fn) == "function") then
        return true, fn(...)
    end
    return false
end

initTableSafely = function(t)
    if (type(t) == "table") then
        return t
    end
    return {}
end

tCore = {}
tCore.director = cc.Director:getInstance()
tCore.winSize = tCore.director:getWinSize()
tCore.fileUtils = cc.FileUtils:getInstance()
tCore.writePath = cc.FileUtils:getInstance():getWritablePath() .. "tidyoux-luarun/"
tCore.userData = cc.UserDefault:getInstance()

-- code file
tCore.codeFile = {}

local tUserDataKey = {
    file_id = "file_id",
    files = "code_files",
}
tCore.codeFile.nextId = function()
    local ret = tCore.userData:getIntegerForKey(tUserDataKey.file_id, 0) + 1
    tCore.userData:setIntegerForKey(tUserDataKey.file_id, ret)
    return ret
end

local tCodeFiles = {}
tCore.codeFile.load = function()
    local contentStr = tCore.userData:getStringForKey(tUserDataKey.files)
    if string.len(contentStr) > 0 then
        local t = json.decode(contentStr)
        if t then
            for _, v in pairs(t) do
                tCodeFiles[v.id] = v
            end
        else
            print("load code_files failed.")
            print(contentStr)
        end
    end
end

tCore.codeFile.save = function()
    if next(tCodeFiles) then
        tCore.userData:setStringForKey(tUserDataKey.files, json.encode(tCodeFiles))
    end
end

tCore.codeFile.getAll = function()
    local ret = {}
    for _, v in pairs(tCodeFiles) do
        table.insert(ret, v)
    end
    table.sort(ret, function(v1, v2)
        return v1.id < v2.id
    end)
    return ret
end

tCore.codeFile.set = function(id, name, content)
    local file = tCodeFiles[id] or {id = id}
    if name ~= file.name or content ~= file.content then
        file.name = name
        file.content = content
        tCodeFiles[id] = file
        tCore.codeFile.save()
    end
end

tCore.codeFile.delete = function(id)
    if tCodeFiles[id] then
        tCodeFiles[id] = nil
        tCore.codeFile.save()
    end
end

tCore.codeFile.import = function(id)
    local codeFile = tCodeFiles[id]
    if not(codeFile) then
        print("Error: codeFile.import, invalid id:" .. id)
        return nil
    end

    local f = loadstring(codeFile.content)
    if f then
        return f()
    end
    print("Error: codeFile.import, invalid code.")
    return nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local tSrcSearchPath = {
    "src/",
    tCore.writePath .. "src/",
}
local addSrcSearchPath = function()
    local searchPaths = package.path
    for k, v in ipairs(tSrcSearchPath) do
        searchPaths = v .. "?.lua;" .. searchPaths
    end
    package.path = searchPaths
end

--
--
--
local tResSearchPath = {
	"",
}
local addResSearchPath = function()
    local fileUtils = cc.FileUtils:getInstance()
    local searchPaths = fileUtils:getSearchPaths()

    local addPath = function(head)
        head = head or ""
        for k, v in pairs(tResSearchPath) do
            table.insert(searchPaths, head .. v)
        end
    end

    addPath(tCore.writePath)
    addPath()

    fileUtils:setSearchPaths(searchPaths)
end

--
--
--
local initGameByConfig = function()
	-- screen on
	cc.Device:setKeepScreenOn(true)

    --
    require("cocos.init")

    --
    local scene = cc.Scene:create()
    local Panel = require("panel.main_panel")
    scene:addChild(Panel.new())
    tCore.director:runWithScene(scene)
    tCore.codeFile.load()
end

--
--
--
local main = function()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    math.randomseed(os.time())

    -- add src search path
    addSrcSearchPath()

    -- add res search path
    addResSearchPath()

    -- init game
    initGameByConfig()
end

main()
