local W, F, E, L = unpack(select(2, ...))
local S = W:GetModule("Skins")

local _G = _G

function S:Blizzard_GuildUI()
    if not self:CheckDB("guild") then
        return
    end

    self:CreateShadow(_G.GuildFrame)

    for i = 1, 5 do
        self:ReskinTab(_G["GuildFrameTab" .. i])
    end
end

S:AddCallbackForAddon("Blizzard_GuildUI")
