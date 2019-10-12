dofile("common.inc");

function doit()
  askForWindow("Shows currently hovered mouse position and RGB color values. Press shift over ATITD window to continue.");
  while true do
    srReadScreen();
    local pos = getMousePos();
    local pixelsRaw = srReadPixel(pos[0], pos[1]);
    local pixels = pixelDiffs(pos[0], pos[1], 0);
    local status = "Pos: " .. pos[0] .. ", " .. pos[1] .. "\n";
    status = status .. "Color: " .. table.concat(pixels, ", ") .. "\nPixelRaw: " .. pixelsRaw;
    lsDrawRect(10, 140, 40, 160, 0,  pixelsRaw);
    statusScreen(status, statusColor);
    lsSleep(tick_delay);
  end
end