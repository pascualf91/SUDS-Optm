function [state,options,optchanged] = gaoutfun(options,state,flag)
persistent history
optchanged = false;
switch flag
    case 'init'
        history(:,:,1) = state.Score;
        assignin('base','gascorehistory',history);
    case 'iter'
        % Update the history every generation.
        ss = size(history,3);
        history(:,:,ss+1) = state.Score;
        assignin('base','gascorehistory',history);
    case 'done'
        % Include the final population in the history.
        ss = size(history,3);
        history(:,:,ss+1) = state.Score;
        assignin('base','gascorehistory',history);
end