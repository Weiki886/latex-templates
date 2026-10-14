-- Keep long decision tables legible in the generated PDF.
function Table(tbl)
  if tbl.attributes["custom-widths"] == "true" then
    return tbl
  end
  local count = #tbl.colspecs
  if count >= 4 then
    local width = 0.96 / count
    for index = 1, count do
      tbl.colspecs[index][2] = width
    end
  end

  if count >= 5 then
    return {
      pandoc.RawBlock("latex", "\\begin{landscape}\\footnotesize"),
      tbl,
      pandoc.RawBlock("latex", "\\end{landscape}")
    }
  end

  return tbl
end

-- A fenced Div with attribute colwidths="0.2,0.3,..." pins the widths of the
-- first table it contains (values are fractions of the text width).
-- A fenced Div with class "landscape" forces its content onto a landscape page.
-- Add "compact-table" when a text-heavy landscape table must stay on one page.
function Div(el)
  local colwidths = el.attributes["colwidths"]
  if colwidths then
    local widths = {}
    for value in string.gmatch(colwidths, "[^,]+") do
      table.insert(widths, tonumber(value))
    end
    for _, block in ipairs(el.content) do
      if block.t == "Table" and #widths == #block.colspecs then
        for index, width in ipairs(widths) do
          block.colspecs[index][2] = width
        end
        block.attributes["custom-widths"] = "true"
      end
    end
  end
  if el.classes:includes("landscape") then
    -- Tables with 5+ columns are auto-wrapped by the Table function above;
    -- skip a second wrap to avoid nested landscape environments.
    local first = el.content[1]
    if first and first.t == "RawBlock" and first.text:match("begin{landscape}") then
      return el.content
    end
    local opening = "\\begin{landscape}\\footnotesize"
    local closing = "\\end{landscape}"
    if el.classes:includes("compact-table") then
      opening = "\\begin{landscape}\\begingroup\\AtBeginEnvironment{longtable}{\\fontsize{9.7}{12}\\selectfont\\renewcommand{\\arraystretch}{1.28}}\\setlength{\\tabcolsep}{4.7pt}\\fontsize{9.7}{12}\\selectfont"
      closing = "\\endgroup\\end{landscape}"
    end
    local blocks = { pandoc.RawBlock("latex", opening) }
    for _, block in ipairs(el.content) do
      table.insert(blocks, block)
    end
    table.insert(blocks, pandoc.RawBlock("latex", closing))
    return blocks
  end
  if colwidths then
    return el
  end
end
