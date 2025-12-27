local Library = {}
Library.__index = Library

-- =========================
-- Window
-- =========================
function Library:CreateWindow(cfg)
    local Window = {
        Title = cfg.Title or "UI",
        Subtitle = cfg.Subtitle or "",
        Size = cfg.Size,
        Tabs = {},
        SidebarIcons = {},
        Accent = Color3.fromRGB(127,194,65)
    }

    function Window:AddSidebarIcon(data)
        local icon = {
            Icon = data.Icon,
            Tooltip = data.Tooltip,
            Active = false
        }

        function icon:SetActive(state)
            icon.Active = state
        end

        table.insert(Window.SidebarIcons, icon)
        return icon
    end

    function Window:CreateTab(data)
        local Tab = {
            Name = data.Name,
            Groupboxes = {}
        }

        function Tab:CreateGroupbox(data)
            local Group = {
                Name = data.Name,
                Side = data.Side or "Left",
                Items = {}
            }

            function Group:AddLabel(text)
                table.insert(Group.Items, {Type="Label", Text=text})
            end

            function Group:AddCheckbox(data)
                table.insert(Group.Items, {
                    Type="Checkbox",
                    Text=data.Text,
                    Value=data.Default or false,
                    Callback=data.Callback,
                    ColorPicker=data.ColorPicker
                })
            end

            function Group:AddSlider(data)
                table.insert(Group.Items, {
                    Type="Slider",
                    Text=data.Text,
                    Min=data.Min,
                    Max=data.Max,
                    Value=data.Default,
                    Suffix=data.Suffix,
                    Callback=data.Callback
                })
            end

            function Group:AddDropdown(data)
                table.insert(Group.Items, {
                    Type="Dropdown",
                    Text=data.Text,
                    Options=data.Options,
                    Value=data.Default,
                    Callback=data.Callback
                })
            end

            function Group:AddButton(data)
                table.insert(Group.Items, {
                    Type="Button",
                    Text=data.Text,
                    Callback=data.Callback
                })
            end

            function Group:AddTextbox(data)
                table.insert(Group.Items, {
                    Type="Textbox",
                    Text=data.Text,
                    Placeholder=data.Placeholder,
                    Callback=data.Callback
                })
            end

            function Group:AddKeybind(data)
                table.insert(Group.Items, {
                    Type="Keybind",
                    Text=data.Text,
                    Value=data.Default,
                    Callback=data.Callback,
                    ChangedCallback=data.ChangedCallback
                })
            end

            table.insert(Tab.Groupboxes, Group)
            return Group
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    function Window:SetAccent(color)
        Window.Accent = color
    end

    function Window:Destroy()
        Window.Destroyed = true
    end

    return Window
end

return setmetatable({}, Library)
