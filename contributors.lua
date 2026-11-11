local contributors_block
local credit_block
local citation_text
local license_text

function escape_html(value)
  return tostring(value):gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'):gsub("'", '&#39;')
end

function read_citation()
  local file = io.open('CITATION.cff', 'r')
  if not file then
	return pandoc.Inlines({pandoc.Str('Open Lesson Template, Cardona 2026')})
  end

  local title
  local repository_code
  local year
  local families = {}
  local current_family
  for line in file:lines() do
    title = title or line:match('^title:%s*["\'](.*)["\']%s*$')
	repository_code = repository_code or line:match('^repository%-code:%s*["\']?([^"\']+)["\']?%s*$')
    year = year or line:match('^date%-released:%s*["\']?(%d%d%d%d)')
    local family = line:match('^%s*family%-names:%s*(.*)%s*$')
    if family then
      current_family = family:gsub('^["\']', ''):gsub('["\']$', '')
      table.insert(families, current_family)
    end
  end
  file:close()

  if not title or not year or #families == 0 then
	return pandoc.Inlines({pandoc.Str('Open Lesson Template, Cardona 2026')})
  end
  local title_inline = pandoc.Str(title)
  if repository_code then
    title_inline = pandoc.Link({title_inline}, repository_code)
  end
  return pandoc.Inlines({
    pandoc.Emph({title_inline}),
    pandoc.Str(', ' .. table.concat(families, ' and ') .. ' (' .. year .. ').')
  })
end

function Meta(meta)
  contributors_block = nil
  credit_block = nil
  citation_text = read_citation()
  license_text = meta.book and meta.book.license and pandoc.utils.stringify(meta.book.license) or 'License information not specified.'
  if not meta['contributors-page'] then
    return meta
  end

  if meta.contributors then
    local entries = {}
    for _, contributor in ipairs(meta.contributors) do
      local name = contributor.name and escape_html(pandoc.utils.stringify(contributor.name)) or ''
      local orcid = contributor.orcid and pandoc.utils.stringify(contributor.orcid) or nil
      local orcid_link = ''
      if orcid then
        orcid_link = string.format(' <a href="https://orcid.org/%s" class="quarto-title-author-orcid" aria-label="ORCID profile"><span aria-hidden="true" style="display: inline-flex; align-items: center; justify-content: center; width: 16px; height: 16px; border-radius: 50%%; background: #a6ce39; color: white; font: 700 9px/1 Arial, sans-serif;">iD</span></a>', escape_html(orcid))
      end
      table.insert(entries, string.format('%s%s', name, orcid_link))
    end

    local html = table.concat({
      '<div id="contributors-list">',
      '<div class="quarto-title-meta-heading">Contributors</div>',
      '<div class="quarto-title-meta-contents">',
      '<p>' .. table.concat(entries, ', ') .. '</p>',
      '</div>',
      '</div>'
    })
    contributors_block = pandoc.RawBlock('html', html)
  end

  local authors = meta.book and meta.book.author or nil
  if authors then
    local entries = {}
    for _, author in ipairs(authors) do
      local name = author.name and escape_html(pandoc.utils.stringify(author.name)) or ''
      local roles = {}
      if author.roles then
        for _, role in ipairs(author.roles) do
          local role_text = escape_html(pandoc.utils.stringify(role))
          table.insert(roles, role_text)
        end
      end
      table.insert(entries, string.format('<p style="margin: 0;">%s: %s</p>', name, table.concat(roles, ', ')))
    end
    credit_block = pandoc.RawBlock('html', table.concat({
      '<details>',
      '<summary>CRediT author statement</summary>',
      '<div style="font-size: 0.8rem; line-height: 1.4;">',
      table.concat(entries, ''),
      '</div>',
      '</details>'
    }))
  end
  return meta
end

function Pandoc(document)
  document = document:walk {
    Str = function(element)
      if element.text == 'CITATION_CFF' then
        return citation_text
      end
      if element.text == 'LICENSE_QUARTO' then
        return pandoc.Str(license_text)
      end
    end
  }
  if contributors_block then
    table.insert(document.blocks, 1, contributors_block)
  end
  if credit_block then
    table.insert(document.blocks, 2, credit_block)
  end
  return document
end
