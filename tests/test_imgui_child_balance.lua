-- Static test to ensure ImGui.BeginChild/ImGui.EndChild calls are balanced
-- and wrapped in if statements. Run via run_all_tests.lua or individually with
-- the EnviREAment virtual REAPER environment.

local files = {
    './main.lua',
}

local function check_file(path)
    local begin_count, end_count = 0, 0
    local line_num = 0
    for line in io.lines(path) do
        line_num = line_num + 1
        if not line:match('^%s*--') then -- Ignore comments
            local b = select(2, line:gsub('ImGui%.BeginChild', ''))
            local e = select(2, line:gsub('ImGui%.EndChild', ''))
            begin_count = begin_count + b
            end_count = end_count + e

            if b > 0 then
                -- verify the call is inside an if statement on the same line
                if not line:match('^%s*if%s+ImGui%.BeginChild') then
                    error(path .. ':' .. line_num .. ' ImGui.BeginChild must be wrapped in an if statement')
                end
            end
        end
    end
    assert(begin_count == end_count,
        string.format('%s: mismatched BeginChild (%d) and EndChild (%d)', path, begin_count, end_count))
end

for _, f in ipairs(files) do
    check_file(f)
end

print('ImGui BeginChild/EndChild pairing test passed.')
