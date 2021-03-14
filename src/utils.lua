local is_sequence, noop

is_sequence = (function(value)
  if type(value) ~= "table" then
    return false
  end
  local i = 1
  for _, _ in pairs(value) do
    if value[i] == nil then return false end
    i = i + 1
  end
  return true
end)

noop = (function() end)

return {
  is_sequence = is_sequence,
  noop = noop,
}

