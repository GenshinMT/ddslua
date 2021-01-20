--[[
dds_parse, A parsing module that translates a simple custom format useful for textbox dialogues into LUA tables.

Copyright (c) 2020 Genshin <emperor_genshin@hotmail.com>
License: GPLv3
--]]

local dds = {}

--Parse custom dialogue format from file and parse it as a LUA table
function dds.parse(filename, dir)
  local dialogues = {}
  local dialogue, character, cameo, question, line = nil, nil, nil, nil, nil
  local lcount, qcount, pcount, qpcount = 0, 0, 0, 0
  local content_type = "none"

  for line in io.lines (dir..filename) do
    local callback = false
    lcount = lcount + 1

    --Unindent Lines in case of indentation (Indentation support)
    line = string.gsub(line, '^%s*(.-)%s*$', '%1')

    --Skip Comments and blanks
    if line == nil or line == "" or string.match(line, "##") then

    --Set Character Name for Dialogues
    elseif string.match(line,"Character:") or string.match(line,"character:") then
      character = string.gsub(line, "%a+: ", "")
      callback = true
      
    --Set Character Cameo for Dialogues
    elseif string.match(line,"Cameo:") or string.match(line,"cameo:") then
      cameo = string.gsub(line, "%a+: ", "")
      callback = true

    --Generate a table for the following dialogue
    elseif string.find(line,"%[") and string.find(line,"%]") then
      dialogue = string.gsub(line, "%[", "")
      dialogue = string.gsub(dialogue, "%]", "")
      qcount, pcount, qpcount = 0, 0, 0
      callback = true

      if not dialogues[dialogue] then
        dialogues[dialogue] = {}
        dialogues[dialogue]["character"] = character or "?CharacterName?"
        dialogues[dialogue]["cameo"] = cameo or "blank.png"
        dialogues[dialogue]["lines"] = {}
      end

    --Do callbacks from attributes
    elseif string.match(line,"<%a+>") then
      local attribute = string.match(line,"<%a+>")
      callback = true
      attribute = string.match(line, "%a+")
      line = string.gsub(line, "<%a+>", "")
      
      --If attribute is a line, set text in line index
      if attribute == "line" then
        content_type = "line"
        pcount = pcount + 1

      --If attribute is a question, Generate a list for each question
      elseif attribute == "question" then
        qcount = qcount + 1
        content_type = "question"
        --Generate Event List for each question
        if not dialogues[dialogue]["questions"] then
          dialogues[dialogue]["questions"] = {}
        end

      elseif attribute == "if" then
        question = string.gsub(line, "<if> ", "")
        question = question:sub(2)
        content_type = "choice"
        qpcount = 0

        --If question does not have a input, call error
        if question == nil or question == "" then
          error("Failed to parse dialogue attribute from file, question attribute is missing input. ("..dir..filename..", Line: "..lcount..")")
        end

      --If attribute is a question's line, stack following line into the answer's lines list
      elseif attribute == "qline" then
        content_type = "qline"
        qpcount = qpcount + 1
      else
        error("Failed to parse dialogue attribute from file, \""..attribute.."\" is a invalid attribute. ("..dir..filename..", Line: "..lcount..")")
      end
      
    --Close attribute Callbacks
    elseif string.match(line,"</%a+>") then
      local attribute = string.match(line,"</%a+>")
      attribute = string.match(attribute, "%a+")
      if attribute == "line" or attribute == "question" or attribute == "qline" then
        content_type = "none"
      else
        error("Failed to parse dialogue attribute from file, \""..attribute.."\" is a invalid attribute. ("..dir..filename..", Line: "..lcount..")")
      end
    end

    --The rest is just putting data together as it should
    if content_type == "question" then
      if not dialogues[dialogue]["questions"][qcount] then
        dialogues[dialogue]["questions"][tonumber(qcount)] = {
          sort = {},
          answers = {}  
        }
      end
    elseif content_type == "choice" then
      if question then
        dialogues[dialogue]["questions"][qcount]["sort"][#dialogues[dialogue]["questions"][qcount]["sort"]+1] = question
        dialogues[dialogue]["questions"][qcount]["answers"][question] = {
          lines = {}
        }
      end
    elseif content_type == "line" and callback == false then
      if dialogues[dialogue] then
        if not dialogues[dialogue]["lines"][pcount] then
          dialogues[dialogue]["lines"][#dialogues[dialogue]["lines"]+1] = line
        elseif dialogues[dialogue]["lines"][pcount] then --append to line
          line = dialogues[dialogue]["lines"][pcount].." "..line
          dialogues[dialogue]["lines"][tonumber(pcount)] = line
        end
      end
    elseif content_type == "qline" and callback == false then
      if dialogues[dialogue] then
        if not dialogues[dialogue]["questions"][qcount]["answers"][question]["lines"][qpcount] then
          dialogues[dialogue]["questions"][qcount]["answers"][question]["lines"][tonumber(qpcount)] = line
        elseif dialogues[dialogue]["questions"][qcount]["answers"][question]["lines"][qpcount] then --append to line
          line = dialogues[dialogue]["questions"][qcount]["answers"][question]["lines"][qpcount].." "..line
          dialogues[dialogue]["questions"][qcount]["answers"][question]["lines"][tonumber(qpcount)] = line
        end
      end  
    end
  end
return dialogues
end

return dds
