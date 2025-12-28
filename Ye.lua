-- gamesense-style UI library (visual-focused)
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Library = {}
Library.__index = Library

local function create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do
        obj[k] = v
    end
    return obj
end

function Library:CreateWindow(cfg)
    local gui = create("ScreenGui", {
        Name = "GamesenseUI",
        ResetOnSpawn = false,
        Parent = LP:WaitForChild("PlayerGui")
    })

    local main = create("Frame", {
        Size = cfg.Size or UDim2.fromOffset(900,520),
        Position = UDim2.fromScale(0.5,0.5),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Color3.fromRGB(20,20,20),
        BorderSizePixel = 0,
        Parent = gui
    })

    create("UICorner",{CornerRadius=UDim.new(0,6),Parent=main})
    create("UIStroke",{Color=Color3.fromRGB(60,60,60),Parent=main})

    -- LEFT SIDEBAR
    local sidebar = create("Frame",{
        Size=UDim2.fromOffset(60,_toggle),
        BackgroundColor3=Color3.fromRGB(16,16,16),
        BorderSizePixel=0,
        Parent=main
    })
    sidebar.Size = UDim2.new(0,60,1,0)

    create("UIStroke",{Color=Color3.fromRGB(45,45,45),Parent=sidebar})

    local tabs = {}
    local pages = {}

    function tabs:AddIcon(iconText)
        local btn = create("TextButton",{
            Size=UDim2.fromOffset(40,40),
            Position=UDim2.new(0.5,0,0,10 + (#sidebar:GetChildren()*45)),
            AnchorPoint=Vector2.new(0.5,0),
            BackgroundColor3=Color3.fromRGB(22,22,22),
            Text=iconText,
            TextColor3=Color3.fromRGB(200,200,200),
            Font=Enum.Font.GothamBold,
            TextSize=18,
            BorderSizePixel=0,
            Parent=sidebar
        })
        create("UICorner",{CornerRadius=UDim.new(0,6),Parent=btn})
        return btn
    end

    local content = create("Frame",{
        Position=UDim2.fromOffset(70,10),
        Size=UDim2.new(1,-80,1,-20),
        BackgroundTransparency=1,
        Parent=main
    })

    function tabs:CreatePage()
        local page = create("Frame",{
            Size=UDim2.fromScale(1,1),
            BackgroundTransparency=1,
            Visible=false,
            Parent=content
        })

        local left = create("Frame",{
            Size=UDim2.new(0.48,0,1,0),
            BackgroundTransparency=1,
            Parent=page
        })

        local right = create("Frame",{
            Position=UDim2.new(0.52,0,0,0),
            Size=UDim2.new(0.48,0,1,0),
            BackgroundTransparency=1,
            Parent=page
        })

        function page:AddGroup(title, side)
            local parent = side=="Right" and right or left
            local box = create("Frame",{
                Size=UDim2.fromOffset(0,260),
                AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=Color3.fromRGB(24,24,24),
                BorderSizePixel=0,
                Parent=parent
            })
            box.Size = UDim2.new(1,0,0,0)
            create("UICorner",{CornerRadius=UDim.new(0,6),Parent=box})
            create("UIStroke",{Color=Color3.fromRGB(55,55,55),Parent=box})

            local titleLbl = create("TextLabel",{
                Text=title,
                Font=Enum.Font.GothamBold,
                TextSize=13,
                TextColor3=Color3.fromRGB(230,230,230),
                BackgroundTransparency=1,
                Size=UDim2.fromOffset(200,20),
                Position=UDim2.fromOffset(8,4),
                Parent=box
            })

            local layout = create("UIListLayout",{
                Padding=UDim.new(0,6),
                Parent=box
            })
            layout.HorizontalAlignment=Left
            layout.VerticalAlignment=Top

            local pad = create("UIPadding",{
                PaddingTop=UDim.new(0,26),
                PaddingLeft=UDim.new(0,8),
                PaddingRight=UDim.new(0,8),
                PaddingBottom=UDim.new(0,8),
                Parent=box
            })

            local group = {}

            function group:AddToggle(text)
                local t = create("Frame",{
                    Size=UDim2.fromOffset(0,20),
                    BackgroundTransparency=1,
                    Parent=box
                })
                t.Size=UDim2.new(1,0,0,20)

                local cb = create("Frame",{
                    Size=UDim2.fromOffset(12,12),
                    Position=UDim2.fromOffset(0,4),
                    BackgroundColor3=Color3.fromRGB(35,35,35),
                    BorderSizePixel=0,
                    Parent=t
                })
                create("UIStroke",{Color=Color3.fromRGB(80,160,80),Parent=cb})

                create("TextLabel",{
                    Text=text,
                    Font=Enum.Font.Gotham,
                    TextSize=12,
                    TextColor3=Color3.fromRGB(220,220,220),
                    BackgroundTransparency=1,
                    Position=UDim2.fromOffset(18,0),
                    Size=UDim2.new(1,-18,1,0),
                    Parent=t
                })
            end

            return group
        end

        table.insert(pages,page)
        return page
    end

    return tabs
end

return Library
