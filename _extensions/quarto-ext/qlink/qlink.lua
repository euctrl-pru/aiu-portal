-- {{< blank_url "TITLE" "URL" >}}
-- {{< blank_url eurocontrol "TITLE" "URL" >}}
-- {{< a_blank_url skybrary "GA - General Aviation" "https://skybrary.aero/articles/general-aviation-ga" >}}

local function is_empty(s)
  return s == nil or s == ''
end

local function is_valid_org(org)
  if is_empty(org) then
    return ''
  end
  local org_table = {
    ["ec"]          = "European Union",
    ["icao"]        = "ICAO",
    ["wiki"]        = "Wikipedia",
    ["wikipedia"]   = "Wikipedia",
    ["euctrl"]      = "EUROCONTROL",
    ["ectrl"]      = "EUROCONTROL",
    ["eurocontrol"] = "EUROCONTROL",
    ["skybrary"]    = "Skybrary"
  }
  
  for key, value in pairs(org_table) do
    if key == org then
      return value
    end
  end
  return ''
end

local function is_valid_url(org)
  if is_empty(org) then
    return ''
  end
  local url_table = {
    ["ec"]          = "https://ec.europa.eu/commission/index_en",
    ["icao"]        = "https://icao.int",
    ["wiki"]        = "https://wikipedia.org",
    ["wikipedia"]   = "https://wikipedia.org",
    ["euctrl"]      = "https://eurocontrol.int",
    ["ectrl"]      = "https://eurocontrol.int",
    ["eurocontrol"] = "https://eurocontrol.int",
    ["skybrary"]    = "https://www.skybrary.aero"
  }

  for key, value in pairs(url_table) do
    if key == org then
      return value
    end
  end
  return ''
end


return {
  ["a_blank"] = function(args, kwargs, meta)
    if quarto.doc.is_format("html:js") then
      -- html specific output
      if #args == 3 then
        org = pandoc.utils.stringify(args[1])
        org_name = is_valid_org(org)
        title = pandoc.utils.stringify(args[2])
        url = pandoc.utils.stringify(args[3])
        org_url = is_valid_url(org)
        return pandoc.RawInline(
          'html',
          "<a target='_blank' "
             .. "href='" .. url .. "' "
             .. "title='" .. title .. "'>" .. title .. "</a> "
          .. " page at "
          .. "<a target='_blank' href='" .. org_url .. "' "
          .. "title='" .. org_name .. "'>" .. org_name .. "</a> website."
        )
      end
      if #args == 2 then
        title = pandoc.utils.stringify(args[1])
        url = pandoc.utils.stringify(args[2])
        return pandoc.RawInline(
          'html',
          "<a target='_blank' "
             .. "href='" .. url .. "' "
             .. "title='" .. title .. "'>" .. title .. "</a> "
          .." website."
        )
      end
    end
    return pandoc.Null()
  end
}