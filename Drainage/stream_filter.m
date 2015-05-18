function stream_filter(no)

stream  = evalin('base','stream');
curr_val = evalin('base','curr_val');

[u,v,logarea,logslope] = arrange_data(stream(curr_val),no);

stream(curr_val).lon= stream(curr_val).lon(2:end);
stream(curr_val).lat= stream(curr_val).lat(2:end);
stream(curr_val).x= stream(curr_val).x(2:end);
stream(curr_val).y= stream(curr_val).y(2:end);
stream(curr_val).len= stream(curr_val).len(2:end);
stream(curr_val).elevation= stream(curr_val).elevation(2:end);
stream(curr_val).rawelevation= stream(curr_val).rawelevation(2:end);
stream(curr_val).area= stream(curr_val).area(2:end);
stream(curr_val).bit= stream(curr_val).bit(2:end);

stream(curr_val).u = u(2:end,:);
stream(curr_val).v = v(2:end);
stream(curr_val).logarea = logarea;
stream(curr_val).logslope = logslope;

assignin('base','stream',stream);

end

