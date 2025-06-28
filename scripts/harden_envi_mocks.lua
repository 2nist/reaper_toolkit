-- scripts/harden_envi_mocks.lua
-- Reads C++ API definitions from the reaimgui source and the existing
-- mock file to generate "hardened" mocks with strict argument and type checking.
-- This improves the accuracy of the mock environment by ensuring that
-- tests fail when functions are called with incorrect parameters.

print("Harden Mocks script starting...")

local api_dir = 'docs/reaimgui-master 3/api/'
local mock_file_path = 'EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua'

-- Type mapping from C++ to Lua
local type_map = {
  ['const char*'] = 'string',
  ['char*'] = 'string',
  ['double'] = 'number',
  ['float'] = 'number',
  ['int'] = 'number',
  ['unsigned int'] = 'number',
  ['bool'] = 'boolean',
  ['Context*'] = 'table',
  ['ImGuiContext*'] = 'table',
  ['ImPlotContext*'] = 'table',
  -- Pointers can be tables or light userdata, so 'any' is safer
  ['const double*'] = 'any',
  ['const float*'] = 'any',
  ['const int*'] = 'any',
  ['double*'] = 'any',
  ['float*'] = 'any',
  ['int*'] = 'any',
  ['ImVec2*'] = 'table',
  ['ImVec4*'] = 'table',
  ['ImPlotPoint*'] = 'table',
  ['DrawListProxy*'] = 'table',
  ['ViewportProxy*'] = 'table',
  -- ReaImGui-specific wrappers
  ['RO<double*>'] = 'number',
  ['RO<float*>'] = 'number',
  ['RO<int*>'] = 'number',
}

-- Function to list all files in a directory
local function list_files(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    if pfile then
        for filename in pfile:lines() do
            if filename ~= '.' and filename ~= '..' then
                t[#t+1] = filename
            end
        end
        pfile:close()
    end
    return t
end

-- Function to parse API_FUNC macros from C++ source content
local function parse_api_functions(content)
  local functions = {}
  -- This pattern correctly captures the entire API_FUNC macro definition, including the body.
  for def in content:gmatch("API_FUNC%b()%s*%b{}") do
    -- Extract just the signature part inside the first parentheses.
    local signature = def:match("API_FUNC%((.*)%)%s*%b{}")

    if signature then
      -- Linearize the signature to make parsing easier.
      signature = signature:gsub('\n', ' '):gsub('\r', ' ')

      -- Extract the core components: return type, name, and the full argument string.
      local _, _, ret_type, name, args_part = signature:find("0_1,([%w%s%*&<>:]+),%s*(%w+),%s*(.*)")

      if name then
        local func_info = {
          name = "ImGui_" .. name,
          ret_type = ret_type:match("^%s*(.-)%s*$"),
          args = {}
        }

        -- Isolate the actual arguments, removing the context and the final description string.
        local args_str = args_part:match('%(Context%*,ctx%)(.*),%s*".*"%s*$') or ""

        -- Iterate over each argument block, which is enclosed in parentheses.
        for arg_def in args_str:gmatch("%b()") do
          local arg_content = arg_def:match("%((.*)%)")
          local arg_type, arg_name, default_val = arg_content:match("([%w%s%*&<>:]+),%s*([%w_]+)(,.*)?")

          if arg_type and arg_name then
            table.insert(func_info.args, {
              type = arg_type:match("^%s*(.-)%s*$"),
              name = arg_name,
              optional = default_val ~= nil and #default_val > 0
            })
          end
        end
        functions[func_info.name] = func_info
      end
    end
  end
  return functions
end

local function generate_hardened_function(func_info)
  local arg_names = {}
  for i, arg in ipairs(func_info.args) do
    table.insert(arg_names, arg.name)
  end

  local new_func = {string.format("function reaper.%s(%s)", func_info.name, table.concat(arg_names, ", "))}

  -- Generate argument checks
  for i, arg in ipairs(func_info.args) do
    local lua_type = type_map[arg.type] or 'any'
    if lua_type ~= 'any' and not arg.optional then
      table.insert(new_func, string.format("  assert(type(%s) == '%s', 'bad argument #%d to `%s` (%s expected, got ' .. type(%s) .. ')')", arg.name, lua_type, i, func_info.name, lua_type, arg.name))
    end
  end

  table.insert(new_func, string.format("  reaper.ShowConsoleMsg('[MOCK] Called %s...\n')", func_info.name))

  -- Default return values based on C++ type
  if func_info.ret_type == 'bool' then
    table.insert(new_func, "  return false")
  elseif func_info.ret_type == 'int' or func_info.ret_type == 'double' then
    table.insert(new_func, "  return 0")
  elseif func_info.ret_type == 'const char*' then
    table.insert(new_func, "  return ''")
  else
    -- No return for void or unknown types
  end

  table.insert(new_func, "end")
  return table.concat(new_func, "\n")
end

-- Main logic
local api_files = list_files(api_dir)
local all_cpp_content = ""
for _, file in ipairs(api_files) do
  if file:match("%.cpp$") then
    local f = io.open(api_dir .. file, "r")
    if f then
      print("Reading API from: " .. api_dir .. file)
      all_cpp_content = all_cpp_content .. f:read("*a") .. "\n"
      f:close()
    end
  end
end

local parsed_funcs = parse_api_functions(all_cpp_content)
local func_count = 0
for _ in pairs(parsed_funcs) do func_count = func_count + 1 end

print("\n--- Parsed " .. func_count .. " functions ---")
for name, info in pairs(parsed_funcs) do
    local args_str = ""
    for _, arg in ipairs(info.args) do
        args_str = args_str .. arg.type .. " " .. arg.name .. ", "
    end
    print(string.format("  %s %s(%s)", info.ret_type, name, args_str))
end

-- Read mock file
local mock_f = io.open(mock_file_path, "r")
if not mock_f then
  print("[ERROR] Could not read mock file: " .. mock_file_path)
  os.exit(1)
end
local mock_content = mock_f:read("*a")
mock_f:close()

local replacements = 0
-- Iterate through all parsed C++ functions
for name, info in pairs(parsed_funcs) do
  -- This pattern finds the corresponding placeholder function in the Lua mock file.
  -- It is designed to be flexible, handling variations in whitespace and newlines.
  -- The double backslash `\\.` is crucial to correctly escape the dot for the pattern.
  local pattern = "(function%s+reaper\\." .. name .. "%s*%(%s*%.%.%.%s*%)%s*)[%s%S]-?(end)"
  local hardened_func_body = generate_hardened_function(info)

  local new_mock_content, count = mock_content:gsub(pattern, hardened_func_body)

  if count > 0 then
    mock_content = new_mock_content
    replacements = replacements + count
    print("  Replaced mock for " .. name)
  end
end

if replacements > 0 then
  print("\n--- Writing " .. replacements .. " hardened mocks to " .. mock_file_path .. " ---")
  local out_f = io.open(mock_file_path, "w")
  if not out_f then
    print("[ERROR] Could not write to mock file: " .. mock_file_path)
    os.exit(1)
  end
  out_f:write(mock_content)
  out_f:close()
  print("--- Hardening complete. ---")
else
  print("\n--- No functions were replaced. Mocks may already be hardened or do not exist. ---")
end

print("\nHarden Mocks script finished. (Implementation in progress)")
