function rtrim(s)
  return s:match'^(.*%S)%s*$'
end

function ltrim(s)
  return s:match'^%s*(.*)'
end

function trim(s)
	return ltrim(rtrim(s))
end