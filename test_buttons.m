trigger_meg_init;
[buttons, suppressor] = LV_init_response; 


button_pressed = 0; 

while true

    Datapixx('RegWrRd'); % synchronize datapixx
    status = Datapixx('GetDinStatus');

    % disp(status);
    % check if response is given
    if status.newLogFrames > 0
        [buttons, logTimetags, underflow] = Datapixx('ReadDinLog',1);

        pressed = bitand(buttons, suppressor);

        % collect response
        % response.subj_button(i_resp) = pressed;
        % response.subj_responsetime(i_resp) = GetSecs - StartResponse; % record RT
        % send trigger 
        %Box 1
        %if response.subj_button(i_resp) == 1 %red button
        %    trigger_meg_send(triggers.('button_red'), .02)

        %elseif response.subj_button(i_resp) == 8 %blue button
        %    trigger_meg_send(triggers.('button_blue'), .02)
        %Box 2
        %elseif response.subj_button(i_resp) == 2 %yellow button
        %    trigger_meg_send(triggers.('button_yellow'), .02)

            %elseif response.subj_button(i_resp) == 4 %green button
        %    trigger_meg_send(triggers.('button_green'), .02)
        %end
        % update variables
        if ~button_pressed && pressed ~=0
            button_pressed = 1;
            disp(['Button Pressed: ',num2str(pressed)]);
        elseif button_pressed && pressed == 0 
            disp('Button released')
            break
        end
    end
end