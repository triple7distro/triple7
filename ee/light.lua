local lgbt_1 = game:GetService("Lighting")

lgbt_1.GlobalShadows = false
lgbt_1.Ambient = Color3.new(1, 1, 1)

if lgbt_1:FindFirstChild("Bloom") then
    lgbt_1.Bloom.Enabled = false
    lgbt_1.Bloom.Intensity = 0
end
if lgbt_1:FindFirstChild("Blur") then
    lgbt_1.Blur.Enabled = false
    lgbt_1.Blur.Size = 0
end
if lgbt_1:FindFirstChild("ColorCorrection") then
    lgbt_1.ColorCorrection.Enabled = false
end
if lgbt_1:FindFirstChild("SunRays") then
    lgbt_1.SunRays.Enabled = false
end
if lgbt_1:FindFirstChild("Sky") then
    lgbt_1.Sky.Enabled = false
end

lgbt_1.FogEnd = 100000
lgbt_1.FogStart = 100000
lgbt_1.FogColor = Color3.new(0, 0, 0)

lgbt_1.ExposureCompensation = 0
