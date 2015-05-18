function mapview_plot(varargin)

try

    info  = evalin('base','info');
    stream  = evalin('base','stream');
%     strax  = evalin('base','strax');

    curr_val = evalin('base','curr_val');
catch
    msgbox('No Data to Plot','Error')
    uiwait
    return
end


try
    logfig = evalin('base','logfig');
    figure(logfig)
    cla
    set(gca,'Visible','off')
    set(logfig,'MenuBar','none','Name','Stream Profile Analysis','NumberTitle','off');
    set(gcf,'CloseRequestFcn',@close_profile)
catch
    logfig = figure('Units','Pixels','Name','Stream Profile Analysis','NumberTitle','off');
    set(gcf,'CloseRequestFcn',@close_profile)
    set(logfig,'MenuBar','none');
    pos=get(logfig,'Position');
    pos(1) = 6;
    pos(2) = pos(2)-50;
    set(logfig,'Position',pos);
end

assignin('base','logfig',logfig);
assignin('base','antyp','map');
set(gcf,'CloseRequestFcn',@close_profile)
axes('position',[0.1 0.2 .8 .7], 'Box','on','Visible','off');

col = get(gcf,'Color');

no = 20;



text1 = uicontrol('Style','text','String','Smoothness Factor:','Position',[50,12,130,20], 'HorizontalAlignment','Left', 'BackgroundColor',col);
%
Edit1 = uicontrol('Style','Edit','String',no,'Position',[150,15,30,20], 'CallBack', @edited, 'HorizontalAlignment','right');

text2 = uicontrol('Style','text','String','Stream No.','Position',[200,12,70,20], 'HorizontalAlignment','Left', 'BackgroundColor',col);
Edit2 = uicontrol('Style','Edit','String',num2str(curr_val),'Position',[260,15,30,20], 'CallBack', @EditCallBack, 'HorizontalAlignment','left');

lstr = length(stream);

sstep = (100/(lstr -1))/100;

Slider = uicontrol('Style','Slider','Position',[300,15,110,20],'CallBack', @SliderCallBack, 'Value',curr_val, 'Min',1,'Max',lstr, 'SliderStep', [sstep sstep]);

% pbotton = uicontrol('Style','pushbutton','String','Zoom','Position',[450,15,50,20], 'HorizontalAlignment','Left','CallBack',@zooms);

edited();

    function zooms(h, eventdata)

        zoom on;
    end

    function edited(varargin)

        r = evalin('base','r');
        %         no1 = str2num(get(Edit1,'String'));
        no2 = str2num(get(Edit2,'String'));
        no = str2num(get(Edit1,'String'));
        assignin('base','curr_val',no2);
        assignin('base','no',no);
        num = round(no2);
        curr_val = round(num);
        add_histroy({strcat('Map view plot of stream no. ', num2str(curr_val))});
        cla
        plot(stream(num).y, stream(num).x,'r');
        xlabel('Columns','FontSize',10);
        ylabel('Rows', 'FontSize',10);
        ttl =  strcat('Map view of Stream No. ', num2str(num));
        title(ttl, 'FontSize',13);
        set(gca,'Ydir','Reverse');
        axis image
        hold on

        knickpoints = [];

        try
            knickpoints = [knickpoints; (stream(curr_val).knickpoint)];
        catch
            stream(curr_val).knickpoint= [];
            knickpoints = [knickpoints; (stream(curr_val).knickpoint)];
        end

        for i = 1:1:length(knickpoints)
            plot(stream(num).y(knickpoints(i)), stream(num).x(knickpoints(i)),'ob');
            text(stream(num).y(knickpoints(i)), stream(num).x(knickpoints(i)),strcat('KP', num2str(i)));
        end

    xlim([1 r(2)]);
    ylim([1 r(1)]);
    end;

    function EditCallBack(varargin)

        num = str2num(get(Edit2,'String'));
        if length(num) == 1 & num <=lstr & num >=0
            set(Slider,'Value',num);
        else
            message=strcat('The value should be a number in the range [1-',num2str(lstr));
            message=strcat(message, ']');
            msgbox(message,'Invalid Stream Number','error','modal');
            uiwait
            num = get(Slider, 'Value');
            set(Edit2, 'String', num2str(round(num)));
            return
        end
        assignin('base','curr_val',num);

        edited();
    end

    function SliderCallBack(varargin)

        num = get(Slider, 'Value');

        set(Edit2, 'String', num2str(round(num)));
        assignin('base','curr_val',num);
        edited();

    end

end
