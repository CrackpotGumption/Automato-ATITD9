--
-- 
--

--Cabbage        | 128, 64, 144   | 8      | Y | bulk    | 10
--Carrot         | 224, 112, 32   | 10     | Y | bulk    | 10
--Clay           | 128, 96, 32    | 4      | Y | bulk    | 20
--DeadTongue     | 112, 64, 64    | 500    | N | normal  | 4
--ToadSkin       | 48, 96, 48     | 500    | N | normal  | 4
--FalconBait     | 128, 240, 224  | 10000  | N | normal  | 4
--RedSand        | 144, 16, 24    | 10     | Y | bulk    | 20
--Lead           | 80, 80, 96     | 50     | Y | normal  | 6
--Silver         | 16, 16, 32     | 50     | N | normal  | 6
--Iron           | 96, 48, 32     | 30     | Y | normal  | 8
--Copper         | 64, 192, 192   | 30     | Y | normal  | 8

--Sulfur         | catalyst       | 10     | Y | normal  | 1
--Potash         | catalyst       | 50     | Y | normal  | 1
--Lime           | catalyst       | 20     | Y | normal  | 1
--Saltpeter      | catalyst       | 10     | Y | normal  | 1


--                 cj   ca  cl   dt   ts   el   rs   le   si   ir   co   su  po li sp
paint_colourR = { 128, 224, 128, 112, 48,  128, 144, 80,  16,  96,  64  };
paint_colourG = { 64,  112, 96,  64,  96,  240, 16,  80,  16,  48, 192  };
paint_colourB = { 144, 32,  32,  64,  48,  224, 24,  96,  32,  32, 192  };
catalyst1 = 12;

dofile("screen_reader_common.inc");
dofile("ui_utils.inc");
dofile("common.inc");

button_names = {
"Cabbage Juice","Carrot","Clay","Dead Tongue","Toad Skin","Falcon Bait","Red Sand",
"Lead","Silver","Iron","Copper","C: Sulfur","C: Potash","C: Lime","C: Saltpeter"}; 

per_paint_delay_time = 1000;
per_read_delay_time = 600;
per_click_delay = 10;
added = {};

-- bar_width: This should be 307. If we get Red/Green Cloth added to menu, around Xmas time (like on T8), this will likely need to be set to 328.
-- When they added Red/Green Cloth, this caused the window to be wider, hence increasing width of bars.

bar_width = 307; 

function doit()

    local paint_sum = {0,0,0};
    local paint_count = 0;
    local bar_colour = {0,0,0};
    local expected_colour = {0,0,0};
    local diff_colour = {0,0,0};
    local new_px = 0xffffffFF;
    local px_R = nil;
    local px_G = nil;
    local px_B = nil;
    local px_A = nil;
    m_x = 0; -- Do not set as local
    m_y = 0; -- Do not set as local
    local update_now = 1;
    local y = 0;
    local button_push = 0;

    lsSetCaptureWindow();

    askForWindow("Pin your Pigment Laboratory window, anywhere (but don\'t move it once you start macro).\n\nNote: You will want to keep a supply of Red Sand for the Reset button (100 to test all reactions should be fine).\n\nClicking the 'Reset' button will set your Pigment Lab 'back to Black' color, again, but it requires Red Sand to do so. It\'s Magic!\n\nIf you have an Upgraded Pigment Laboratory, be sure to set Batch = 1x so you use LEAST amount of resources while testing reactions!");


    srReadScreen();
    xyWindowSize = srGetWindowSize();
    findBigColorBar();

    local paint_buttons = findAllImages("plus.png");
    if (#paint_buttons == 0) then
        error "No buttons found";
    end


    while 1 do
        lsSetCamera(0,0,lsScreenX*1.5,lsScreenY*1.5);
        -- Where to start putting buttons/text on the screen.
        y = 10;
        
        if lsButtonText(lsScreenX - 10, 50, 0, 100, 0xff6251ff, "Reset") then

            for i= 1, 10 do
                srClickMouseNoMove(paint_buttons[7][0]+2,paint_buttons[7][1]+2, right_click);
                lsSleep(per_click_delay);
            end
            srReadScreen();
            lsSleep(100);
            clickAllText("Take the Paint");
            lsSleep(100);
            paint_sum = {0,0,0};
            paint_count = 0;
            bar_colour = {0,0,0};
            expected_colour = {0,0,0};
            diff_colour = {0,0,0};
            new_px = 0xffffffFF;
            px_R = nil;
            px_G = nil;
            px_B = nil;
            px_A = nil;
            update_now = 1;
            added = {}; -- Erase the array
        end

        -- Create each button and set the button push.
        for i=1, #button_names do
            if lsButtonText(10, y, 0, 250, 0xFFFFFFff, button_names[i]) then
                image_name = button_names[i];
                update_now = 1;
                button_push = i;
            end
            y = y + 30;
        end

        srReadScreen();

        if not foundBigColorBar then
            findBigColorBar();
        end

        -- read the bar pixels
        new_px = srReadPixel(m_x, m_y);
        px_R = (math.floor(new_px/256/256/256) % 256);
        px_G = (math.floor(new_px/256/256) % 256);
        px_B = (math.floor(new_px/256) % 256);
        px_A = (new_px % 256);

        if not(update_now==0) then
        --{
            if not (button_push==0) then
            --{
                -- click the appropriate button to add paint.
                srClickMouseNoMove(paint_buttons[button_push][0]+2,paint_buttons[button_push][1]+2, right_click);
                lsSleep(per_click_delay);
            
                if(button_push < catalyst1) then
                    -- add the paint estimate 
                    paint_sum[1] =     paint_sum[1] + paint_colourR[button_push];
                    paint_sum[2] =     paint_sum[2] + paint_colourG[button_push];
                    paint_sum[3] =     paint_sum[3] + paint_colourB[button_push];
                    paint_count = paint_count + 1.0;
                end

                table.insert(added, button_names[button_push]);

            --}
            end

            -- count up all the pixels.
            lsSleep(per_paint_delay_time);
            srReadScreen();

            bar_colour[1] = #findAllImages("paint_watch/paint-redbarC.png");
            lsSleep(per_read_delay_time/3);
            bar_colour[2] = #findAllImages("paint_watch/paint-greenbarC.png");
            lsSleep(per_read_delay_time/3);
            bar_colour[3] = #findAllImages("paint_watch/paint-bluebarC.png");
            lsSleep(per_read_delay_time/3);
            update_now = 0;

            -- tweak/hack because we miss the first pixel
            for i=1, 3 do
                if(bar_colour[i]>0)then                
                    bar_colour[i]=bar_colour[i]+1;
                    bar_colour[i]=bar_colour[i]*256.0/bar_width;
                end
            end


            -- New colour has been added, mix in the pot, and see if there's a difference from the expected value.
            if paint_count > 0 and button_push > 0 then
            --{                
                for i=1, 3 do
                    expected_colour[i] = paint_sum[i] / paint_count;
                    diff_colour[i] = math.floor(0.5+bar_colour[i]) - math.floor(0.5+expected_colour[i]);
                end

                button_push = 0;
            --}
            end
        --}
        end


        if foundBigColorBar then
          barReadRGB = px_R .. ", " .. px_G .. ", " .. px_B .. ", " .. px_A
          pixelRGBA = math.floor(bar_colour[1]+0.5) .. ", " .. math.floor(bar_colour[2]+0.5) .. ", " .. math.floor(bar_colour[3]+0.5)
        else
          pixelRGBA = "Will Display on Next Reset ..."
        end

        -- Display all the goodies
        y = y + 5;
        lsPrintWrapped(0, y, 1, lsScreenX * 1.5 - 20, 1, 1, 0xFFFFFFff,
            " Pixel RGBA: " .. pixelRGBA);
        y = y + 26;
        lsPrintWrapped(0, y, 1, lsScreenX * 1.5 - 20, 1, 1, 0xFFFFFFff,
            " Bar Read RGB: " .. math.floor(bar_colour[1]+0.5) .. ", " .. math.floor(bar_colour[2]+0.5) .. ", " .. math.floor(bar_colour[3]+0.5));
        y = y + 26;
        lsPrintWrapped(0, y, 1, lsScreenX * 1.5 - 20, 1, 1, 0xFFFFFFff,
            " Expected RGB: " .. math.floor(expected_colour[1]+0.5) .. ", " .. math.floor(expected_colour[2]+0.5) .. ", " .. math.floor(expected_colour[3]+0.5) );
        y = y + 26;
        lsPrintWrapped(0, y, 1, lsScreenX * 1.5 - 20, 1, 1, 0xFFFFFFff,
            " Reactions RGB: " .. math.floor(diff_colour[1]+0.5) .. ", " .. math.floor(diff_colour[2]+0.5) .. ", " .. math.floor(diff_colour[3]+0.5) );
        y = y + 26;


        if not foundBigColorBar then
          addedDisplay = "Leftover Ingredients? Reset, please!"
        elseif #added == 0 then
          addedDisplay = "Nothing"
        else
          addedDisplay = ""
        end


        for i = 1, #added, 1 do
          addedDisplay =  addedDisplay .. added[i]
            if i < #added then
              addedDisplay = addedDisplay .. "  +  "
            end
        end

        lsPrintWrapped(0, y, 1, lsScreenX * 1.5 - 20, 1, 1, 0xFFFFFFff, " Added: " .. addedDisplay);

        if lsButtonText(lsScreenX - 10, 120, 0, 100, 0xFFFFFFff, "Exit") then
            error "I quit!";
        end

        lsDoFrame();
        lsSleep(10);
    end
end


function findBigColorBar()
    local colour_panel = findAllImages("paint_watch/paint-black.png");
    if (#colour_panel == 0) then
        m_x, m_y = srMousePos();
    else
        m_x = colour_panel[1][0]-10;
        m_y = colour_panel[1][1]+10;
        foundBigColorBar = 1;    
    end
end
