local TAG = "files_panel"

local files_panel = class("files_panel",
	function()
		return cc.Node:create()
	end)

function files_panel:ctor(selectedCallback)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(
        function(touch, event)
            return true
        end,
        cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    self.mSelectedCallback = selectedCallback
    self.mCurIndex = 0
    self.mFiles = tCore.codeFile.getAll()
    self.mListView = nil
    self:initUI()
    self:setCurIndex(0)
end

function files_panel:initUI()
    local winSize = tCore.winSize

    local bkg = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
	self:addChild(bkg)

    local ListViewWidth = winSize.width - 100
    local listView = ccui.ListView:create()
    listView:setContentSize(cc.size(ListViewWidth, winSize.height))
    listView:setAnchorPoint(cc.p(0, 0))
    listView:setPosition(cc.p(10, 0))
    self:addChild(listView)
    self.mListView = listView

    for k, v in ipairs(self.mFiles) do
        local item = ccui.Button:create()
        item:setTitleText("<" .. v.name .. ">")
        item:setTitleFontSize(30)
        item:addClickEventListener(function()
            self:setCurIndex(k - 1)
        end)
        listView:pushBackCustomItem(item)
    end

    -- menu
    local deleteBtn = ccui.Button:create()
    deleteBtn:setTitleText("[Delete]")
    deleteBtn:setTitleFontSize(32)
    deleteBtn:addClickEventListener(function()
        self:delete()
    end)
    deleteBtn:setAnchorPoint(cc.p(1, 1))
    deleteBtn:setPosition(cc.p(winSize.width, winSize.height - 10))
    self:addChild(deleteBtn)

    local openBtn = ccui.Button:create()
    openBtn:setTitleText("[Open]")
    openBtn:setTitleFontSize(32)
    openBtn:addClickEventListener(function()
        self:open()
    end)
    openBtn:setAnchorPoint(cc.p(1, 0))
    openBtn:setPosition(cc.p(winSize.width, 110))
    self:addChild(openBtn)

    local backBtn = ccui.Button:create()
    backBtn:setTitleText("[Back]")
    backBtn:setTitleFontSize(32)
    backBtn:addClickEventListener(function()
        self:removeFromParent()
    end)
    backBtn:setAnchorPoint(cc.p(1, 0))
    backBtn:setPosition(cc.p(winSize.width, 10))
    self:addChild(backBtn)
end

function files_panel:delete()
    local file = self.mFiles[self.mCurIndex + 1]
    if file then
        tCore.codeFile.delete(file.id)
        self.mListView:removeItem(self.mCurIndex)
    end
    self:setCurIndex(0)
end

function files_panel:open()
    if self.mSelectedCallback then
        local file = self.mFiles[self.mCurIndex + 1]
        if file then
            self.mSelectedCallback(file)
        end
    end
    self:removeFromParent()
end

function files_panel:setCurIndex(index)
    local item = self.mListView:getItem(index)
    if item then
        item:setTitleColor(cc.c3b(0, 255, 0))
    end

    if index ~= self.mCurIndex then
        item = self.mListView:getItem(self.mCurIndex)
        if item then
            item:setTitleColor(cc.c3b(255, 255, 255))
        end
        self.mCurIndex = index
    end
end

return files_panel