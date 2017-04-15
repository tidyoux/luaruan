local TAG = "main_panel"

local main_panel = class("main_panel",
	function()
		return cc.Node:create()
	end)

function main_panel:ctor()
    self.mCurFileId = 0
    self.mListView = nil
    self.mNameBox = nil
    self.mContentBox = nil
    self:initUI()
    self:newFile()
end

function main_panel:initUI()
	local winSize = tCore.winSize

    local ListViewWidth = winSize.width - 100
    local listView = ccui.ListView:create()
    listView:setContentSize(cc.size(ListViewWidth, winSize.height))
    listView:setAnchorPoint(cc.p(0, 0))
    listView:setPosition(cc.p(10, 0))
    self:addChild(listView)
    self.mListView = listView

    local nameBox = ccui.EditBox:create(cc.size(ListViewWidth, 30), "")
    nameBox:setFontSize(24)
    nameBox:setFontColor(cc.c3b(255, 255, 255))
    listView:pushBackCustomItem(nameBox)
    self.mNameBox = nameBox

    local lineLabel1 = ccui.Text:create()
    lineLabel1:setString("------------------------------")
    lineLabel1:setFontSize(16)
    listView:pushBackCustomItem(lineLabel1)

    local contentBox = ccui.EditBox:create(cc.size(ListViewWidth, winSize.height - 100), "")
    contentBox:setFontSize(24)
    contentBox:setFontColor(cc.c3b(255, 255, 255))
    listView:pushBackCustomItem(contentBox)
    self.mContentBox = contentBox

    local lineLabel2 = ccui.Text:create()
    lineLabel2:setString("------------------------------")
    lineLabel2:setFontSize(16)
    listView:pushBackCustomItem(lineLabel2)

    local logLabel = ccui.Text:create()
    logLabel:setFontSize(18)
    logLabel:setTextAreaSize(cc.size(ListViewWidth, 0));
    listView:pushBackCustomItem(logLabel)
    self.mLogLabel = logLabel
    
    -- redefine print
    print = function(...)
        local s = "> "
        for _, v in ipairs({...}) do
            s = s .. " " .. tostring(v)
        end
        s = s .. "\n"
        logLabel:setString(logLabel:getString() .. s)
        listView:refreshView()
    end

    -- menu
    local newBtn = ccui.Button:create()
    newBtn:setTitleText("[New]")
    newBtn:setTitleFontSize(32)
    newBtn:addClickEventListener(function()
        self:newFile()
    end)
    newBtn:setAnchorPoint(cc.p(1, 0))
    newBtn:setPosition(cc.p(winSize.width, 410))
    self:addChild(newBtn)

    local filesBtn = ccui.Button:create()
    filesBtn:setTitleText("[Files]")
    filesBtn:setTitleFontSize(32)
    filesBtn:addClickEventListener(function()
        self:files()
    end)
    filesBtn:setAnchorPoint(cc.p(1, 0))
    filesBtn:setPosition(cc.p(winSize.width, 210))
    self:addChild(filesBtn)

    local saveBtn = ccui.Button:create()
    saveBtn:setTitleText("[Save]")
    saveBtn:setTitleFontSize(32)
    saveBtn:addClickEventListener(function()
        self:save()
    end)
    saveBtn:setAnchorPoint(cc.p(1, 0))
    saveBtn:setPosition(cc.p(winSize.width, 110))
    self:addChild(saveBtn)

    local runBtn = ccui.Button:create()
    runBtn:setTitleText("[Run]")
    runBtn:setTitleFontSize(32)
    runBtn:addClickEventListener(function()
        self:run()
    end)
    runBtn:setAnchorPoint(cc.p(1, 0))
    runBtn:setPosition(cc.p(winSize.width, 10))
    self:addChild(runBtn)
end

function main_panel:newFile()
    self.mCurFileId = tCore.codeFile.nextId()
    self.mNameBox:setText("new_file")
    self.mContentBox:setText("")
end

function main_panel:files()
    local Panel = require("panel.files_panel")
    self:addChild(Panel.new(function(file)
        self.mCurFileId = file.id
        self.mNameBox:setText(file.name)
        self.mContentBox:setText(file.content)
    end), 1)
end

function main_panel:save()
    tCore.codeFile.set(self.mCurFileId, self.mNameBox:getText(), self.mContentBox:getText())
end

function main_panel:run()
    local code = self.mContentBox:getText()
    if string.len(code) > 0 then
        self.mLogLabel:setString("")

        local f = loadstring(code)
        if f then
            f()
        else
            print("Error: invalid code.")
        end
    end
end

return main_panel