local M = {}

local function create_ef_resource()
  -- Prompt the user for a filename
  local filename = vim.fn.input('Enter filename for SQL migration: ')

  -- Determine the project root directory
  local csproj_file = nil
  local dir = vim.fn.fnamemodify(vim.fn.bufname('%'), ':h')
  local log_file = io.open(dir .. '/create-ef-resource.log', 'a')
  local parent_dir = vim.fn.fnamemodify(dir, ':h')
  local count = 0
  while dir ~= nil and dir ~= '' and count <= 2 do
    csproj_file = vim.fn.fhttps://neovim.io/doc/user/lua.htmlindfile('*.csproj', dir .. ';')
    log_file:write('dir: ' .. tostring(dir) .. '\n')
    if csproj_file ~= '' then
      log_file:write('csproj_file: ' .. tostring(csproj_file) .. '\n')
      log_file:write('breaking' .. '\n')
      break
    end
    count = count + 1
    dir = parent_dir
    parent_dir = vim.fn.fnamemodify(dir, ':h')
  end

   -- Check if csproj file was found
  if csproj_file == nil then
    error('Could not find csproj file')
  end

  local project_dir = vim.fn.fnamemodify(csproj_file, ':h')


  -- Save logs to a file
  print('project_dir: ' .. tostring(project_dir))
  log_file:write('csproj_file: ' .. tostring(csproj_file) .. '\n')
  log_file:write('project_dir: ' .. tostring(project_dir) .. '\n')

  -- Create the migrations/files directory if it doesn't exist
  local migrations_dir = project_dir .. '/migrations/files'
  vim.fn.mkdir(migrations_dir, 'p')

  -- Create the SQL migration file
  local sql_filename = filename .. '.sql'
  local sql_filepath = migrations_dir .. '/' .. sql_filename
  vim.fn.writefile({}, sql_filepath)


  -- Close the log file
  log_file:write('Finished creating EF resource\n\n')
  log_file:close()
  -- Add the SQL file to the csproj file
  local csproj_lines = {}
  for line in io.lines(csproj_file) do
    table.insert(csproj_lines, line)
  end

  -- Find the last <ItemGroup> element in the csproj file
  local last_item_group_index = #csproj_lines
  for i = #csproj_lines, 1, -1 do
    if csproj_lines[i]:find('<ItemGroup>') then
      last_item_group_index = i
      break
    end
  end

  -- Add the <None Update> element for the SQL file
  local update_element = string.format([[  <None Update="%s">
    <CopyToOutputDirectory>Always</CopyToOutputDirectory>
  </None>]], sql_filepath:gsub('\\', '/'))

  table.insert(csproj_lines, last_item_group_index + 1, update_element)

  -- Write the modified csproj file back to disk
  local csproj_filename = vim.fn.fnamemodify(csproj_file, ':t')
  local new_csproj_path = project_dir .. '/' .. csproj_filename
  local csproj_file = io.open(new_csproj_path, 'w')
  csproj_file:write(table.concat(csproj_lines, '\n'))
  csproj_file:close()

end

function M.create_sql_migration_file()
  create_ef_resource()
end

return M
