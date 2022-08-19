local PANEL = {}
PANEL.Changes = {}
function PANEL:Init()

    NebulaWeapons.Panel = self

    self:SetTitle("Weapon Editor")
    self:SetSize(900, 700)
    self:Center()
    self:MakePopup()

    local side = vgui.Create("Panel", self)
    side:Dock(RIGHT)
    side:SetWide(350)

    self.SearchWeapon = vgui.Create("nebula.textentry", side)
    self.SearchWeapon:Dock(TOP)
    self.SearchWeapon:DockMargin(0, 0, 0, 8)
    self.SearchWeapon.OnValueChange = function()
        self:FillWeapons()
    end

    self.List = vgui.Create("DListView", side)
    self.List:Dock(FILL)
    self.List:AddColumn("Class")
    self.List:AddColumn("Name")
    self.List.OnRowSelected = function(_, _, line)
        self.SelectedID = line:GetValue(1)
        self.Changes = {}
        self:WriteFields(line:GetValue(1))
    end

    local main = vgui.Create("Panel", self)
    main:Dock(FILL)
    main:DockMargin(0, 0, 8, 0)

    self.Upload = vgui.Create("nebula.button", main)
    self.Upload:Dock(BOTTOM)
    self.Upload:DockMargin(0, 8, 0, 0)
    self.Upload:SetTall(32)
    self.Upload:SetText("Upload")
    self.Upload.DoClick = function()
        self:UploadData()
    end

    self.Delete = vgui.Create("nebula.button", main)
    self.Delete:Dock(BOTTOM)
    self.Delete:DockMargin(0, 8, 0, 0)
    self.Delete:SetTall(32)
    self.Delete:SetText("Delete")
    self.Delete.DoClick = function()
        Derma_Query("Are you sure do you want to delete " .. self.SelectedID .. " modifications?", "Delete?", "Yes", function()
            net.Start("NebulaWeapons:DeleteWeapon")
            net.WriteString(self.SelectedID)
            net.SendToServer()
        end)
    end

    self.Search = vgui.Create("nebula.textentry", main)
    self.Search:Dock(TOP)
    self.Search.OnValueChange = function()
        self:WriteFields(self.SelectedID)
    end

    self.Main = vgui.Create("DScrollPanel", main)
    self.Main:Dock(FILL)

    self:FillWeapons()
end

local components = {
    [true] = {"x", "y", "z"},
    [false] = {"p", "y", "r"},
}

function PANEL:UploadData()
    local tosend = {}
    local wep = weapons.GetStored(self.SelectedID)
    for key, val in pairs(self.Changes) do
        if (istable(val)) then
            tosend[key] = {}
            for i, sub in pairs(val) do
                if (wep[key][i] != self.Changes[key][i]) then
                    tosend[key][i] = self.Changes[key][i]
                end
            end
        elseif (wep[key] != val) then
            tosend[key] = self.Changes[key]
        end
    end

    for k, v in pairs(tosend) do
        if (istable(v) and table.IsEmpty(v)) then
            tosend[k] = nil
        end
    end

    PrintTable(tosend)
    net.Start("NebulaWeapons:UpdateWeapon")
    net.WriteString(self.SelectedID)
    net.WriteTable(tosend)
    net.SendToServer()
end

function PANEL:WriteFields(id)
    local filter = self.Search:GetText()
    self.Main:GetCanvas():Clear()

    local data = weapons.GetStored(id)

    if not data then return end

    for k, v in pairs(data) do
        if (filter and filter != "" and not string.find(string.lower(k), string.lower(filter))) then continue end

        if not self.Changes[k] then
            self.Changes[k] = {}
        end

        if istable(v) then
            local line = vgui.Create("DLabel", self.Main)
            line:Dock(TOP)
            line:SetText(k)
            line:SetMouseInputEnabled(true)
            line:SetFont(NebulaUI:Font(20))
            line:SetContentAlignment(7)
            line:DockMargin(0, 0, 4, 4)
            line:SetTall(table.Count(v) * 24 + 24)
            line:DockPadding(32, 24, 0, 0)
            line:SetContentAlignment(7)
            self.Changes[k] = {}
            for sub, data in pairs(v) do
                if not self.Changes[k][sub] then
                    self.Changes[k][sub] = data
                end
                local lbl = vgui.Create("DPanel", line)
                lbl:Dock(TOP)
                lbl:SetMouseInputEnabled(true)
                lbl:SetKeyBoardInputEnabled(true)
                lbl:SetTall(24)
                lbl.Paint = function(s, w, h)
                    draw.SimpleText(sub, NebulaUI:Font(20), 4, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                self:AddLine(sub, data, lbl, k)
            end
        else
            local line = vgui.Create("Panel", self.Main)
            line:Dock(TOP)
            line:DockMargin(0, 0, 4, 4)
            line:SetTall(24)
            local lbl = vgui.Create("DLabel", line)
            lbl:Dock(LEFT)
            lbl:SetMouseInputEnabled(false)
            lbl:SetText(k)
            lbl:SetWide(272)
            lbl:SetFont(NebulaUI:Font(20))
            self:AddLine(k, v, line)
        end
    end
end

function PANEL:AddLine(field, v, line, parent)

    if (isstring(v) or isnumber(v)) then
        local txt = vgui.Create("nebula.textentry", line)
        txt:Dock(RIGHT)
        txt:SetWide(256)
        txt:SetText(v)
        txt:SetMouseInputEnabled(true)
        txt:SetNumeric(isnumber(v))
        txt.parent = parent
        txt.OnValueChange = function(s, val)
            if (s.parent) then
                self.Changes[s.parent][field] = isnumber(v) and tonumber(val) or val
                MsgN("Table value")
            else
                self.Changes[field] = isnumber(v) and tonumber(val) or val
            end
        end
    end

    if (isvector(v) or isangle(v)) then
        local obj = {}
        for k = 1, 3 do
            local component = vgui.Create("nebula.textentry", line)
            component:Dock(RIGHT)
            component:SetWide(70)
            component:DockMargin(4, 0, 0, 0)
            component:SetNumeric(true)
            component.parent = parent
            component:SetText(v[components[isvector(v)][k]])
            obj[k] = component
            component.OnValueChange = function(s, val)
                local result =  isvector(v) and
                Vector(tonumber(obj[1]:GetText()),
                        tonumber(obj[2]:GetText()),
                        tonumber(obj[3]:GetText())) or
                Angle(tonumber(obj[1]:GetText()),
                        tonumber(obj[2]:GetText()),
                        tonumber(obj[3]:GetText()))
 
                if (s.parent) then
                    self.Changes[s.parent][field] = result
                else
                    self.Changes[field] = result
                end
            end
        end
    end

    if (isbool(v)) then
        local checkbox = vgui.Create("nebula.checkbox", line)
        checkbox:Dock(RIGHT)
        if (v) then
            checkbox:DoClick(v)
        end
        checkbox:SetWide(24)
        checkbox.parent = parent
        checkbox.OnValueChange = function(s, val)
            if (s.parent) then
                self.Changes[s.parent][field] = val
            else
                self.Changes[field] = val
            end
        end
    end
end

function PANEL:FillWeapons()
    local filter = self.SearchWeapon:GetText()
    self.List:Clear()

    for k, v in pairs(weapons.GetList()) do
        if (filter and filter != "") then
            if (string.find(string.lower(v.ClassName), string.lower(filter)) or string.find(string.lower(v.PrintName or ""), string.lower(filter))) then
                self.List:AddLine(v.ClassName, v.PrintName)
            end
        else
            self.List:AddLine(v.ClassName, v.PrintName)
        end
    end
end

vgui.Register("nebula.weaponeditor", PANEL, "nebula.frame")

concommand.Add("nebula_weaponeditor", function()
    NebulaWeapons.Panel = vgui.Create("nebula.weaponeditor")
end)

if IsValid(NebulaWeapons.Panel) then
    NebulaWeapons.Panel:Remove()
end

//NebulaWeapons.Panel = vgui.Create("nebula.weaponeditor")
