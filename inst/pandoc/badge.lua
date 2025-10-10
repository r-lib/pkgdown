function Link(el)
  -- Check if this is a lifecycle.r-lib.org link
  if string.match(el.target, "lifecycle%.r%-lib%.org") then
    -- Check if it contains exactly one image
    if #el.content == 1 and el.content[1].t == "Image" then
      local img = el.content[1]
      local img_src = img.src
      
      -- Extract lifecycle stage from the image filename
      local stage = string.match(img_src, "lifecycle%-(%w+)%.svg")
      if stage then
        return pandoc.Strong({pandoc.Str(stage)})
      end
    end
  end
  
  -- Return unchanged
  return el
end