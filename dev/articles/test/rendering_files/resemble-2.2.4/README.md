This directory contains the resemble.js library from https://github.com/Huddle/Resemble.js, with the following change:

It adds the field `data.dims`, which contains the height and width for both files. This is used by the diffviewer to set the sizes of the images, before the images are loaded, so that there isn't any flicker from images resizing after they've been loaded.
