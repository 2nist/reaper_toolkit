-- Debug script to test font manager loading
print("=== Font Manager Loading Debug ===")

-- Test different require paths
local paths_to_test = {
    'modules/font_manager_v2',
    'modules.font_manager_v2',
    'font_manager_v2',
    './modules/font_manager_v2'
}

for i, path in ipairs(paths_to_test) do
    print("\n" .. i .. ". Testing path: " .. path)
    local ok, result = pcall(require, path)
    if ok then
        print("   ✅ SUCCESS: Loaded font manager")
        print("   Type:", type(result))
        if type(result) == "table" then
            print("   Functions available:")
            for k, v in pairs(result) do
                if type(v) == "function" then
                    print("     - " .. k .. "()")
                end
            end
            
            -- Test init function
            if result.init then
                print("   Testing init()...")
                local init_ok, init_err = pcall(result.init)
                if init_ok then
                    print("   ✅ Init successful")
                else
                    print("   ❌ Init failed:", init_err)
                end
            end
        end
        break
    else
        print("   ❌ FAILED:", result)
    end
end

print("\n=== Current package.path ===")
print(package.path)

print("\n=== Current working directory ===")
print(debug.getinfo(1,'S').source:match("@?(.*)"))
