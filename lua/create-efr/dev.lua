local M = {}

local function create_ef_resource()
  -- Prompt the user for a filename
  local filename = vim.fn.input('Enter filename for SQL migration: ')

  -- Determine the project root directory
  local project_dir = vim.fn.fnamemodify(vim.fn.finddir('.csproj', ';'), ':h')

  -- Create the migrations/files directory if it doesn't exist
  local migrations_dir = project_dir .. '/migrations/files'
  vim.fn.mkdir(migrations_dir, 'p')

  -- Create the SQL migration file
  local sql_filename = filename .. '.sql'
  local sql_filepath = migrations_dir .. '/' .. sql_filename
  vim.fn.writefile({}, sql_filepath)

  -- Add the SQL file to the csproj file
  local csproj_path = project_dir .. '/project.csproj'
  local csproj_lines = {}
  for line in io.lines(csproj_path) do
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
  local csproj_file = io.open(csproj_path, 'w')
  csproj_file:write(table.concat(csproj_lines, '\n'))
  csproj_file:close()
end

function M.create_sql_migration_file()
  create_ef_resource()
end

return M