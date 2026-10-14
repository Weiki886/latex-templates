-- Drop a top-level H1 that duplicates the metadata title, promote the rest,
-- and strip manual "N. " numbering prefixes so automatic numbers stay clean.
local removed_title = false

function Pandoc(doc)
  local title = pandoc.utils.stringify(doc.meta.title or "")
  local blocks = {}
  for index, block in ipairs(doc.blocks) do
    local duplicate_title = index == 1
      and block.t == "Header"
      and block.level == 1
      and pandoc.utils.stringify(block.content) == title
    if duplicate_title then
      removed_title = true
    else
      if removed_title and block.t == "Header" and block.level > 1 then
        block.level = block.level - 1
      end
      table.insert(blocks, block)
    end
  end
  doc.blocks = blocks
  return doc
end

function Header(header)
  local text = pandoc.utils.stringify(header.content)
  local stripped = text:gsub("^%d+[%.%d]*%.?%s+", "")
  if stripped ~= text then
    header.content = pandoc.Inlines({ pandoc.Str(stripped) })
  end
  return header
end
