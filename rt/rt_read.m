function RT = rt_read(cfg,LAN)
%     v.0.2
%     <*LAN)<|
% Read event file for reaction time analysis and modeling
%
%  RT = rt_read(cfg)
%
% cfg.filename =       'nombredearchivo.log'
% cfg.type = 'presentation' 'neuroscan' 'pos' 'RT'
%            %%% si se decea evaluar respuestas correctas
% cfg.delim =      [est, resp,resp,resp;
%                          est, resp,resp,-99]  %% matriz con estimulos
%                                        %%   y respuestas  para cada estimulo
%                                        %%   -99 se ocupa para cuadrar las
%                                        %%   matricez, 
%           %%% si no se desea evaluar respuestas correctas
% cfg.est = [est1,est2,...]
% cfg.resp = [resp1, resp2, ...]
% cfg.invert = false 
%
% cfg.stop =        % distarctor, termian el tiempo de respuesta
% cfg.rw = []       %   (ventada de rerspuestas, en cfg.unit)(for TR in MS!!!)
% cfg.iflbc =       % partir las latencia del priemr estimulo contado como cero.
                    % 1: primer estimulo (de los definidos en cfg.est)
                    % 2: segundo estimulo (de los definidos en cfg.est)
                    % -1 primer estimulo encontrados (incluifos los no definidos en cfg.est)
% cfg.unit = 'ms'   %% unidades 's'
% cfg.miss=1;       % no separa los miss
%
% Speficit option
% - For Neuroscan ev2
%   cfg.srate = 1000  % sample rate of date
%   cfg.ifr   = false % If responces are in diferente column, for default false
%
% this function replace older functions:
% see also RT_READ_EV2 RT_READ_PRESENTATION

% Pablo Billeke
% Francisco Zamorano

% 29.08.2019  !!! Crucial fix for 'RT' case for sample rate other than 1000 !!!! 
% 02.03.2016 fix read presnetation data and string logfile 
% 03.05.2012 add invert option to search estimuli related to a response
% 27.04.2012 fix neuroscan duplicate estimuli
% 26.04.2012 add fix_path
% 09.04.2012  
% 02.04.2012
% 30.03.2012  add posibility to add RT to LAN, and correct first latency
% 25.11.2011 fix ev2 read
% 21.11.2011

if nargin == 0
   help rt_read
   if strcmp(lanversion('t'),'devel')
   edit rt_read
   end
   return
end




if isfield(cfg,'iflbc') 
    iflbc = cfg.iflbc;
    if (iflbc~=0)&&(iflbc~=1)
       f_laten =  iflbc; 
       iflbc = true;
    else
       f_laten = false; 
    end
else
    iflbc = 0;
    cfg.iflbc = 0;
end


if isfield(cfg,'delim') 
    ifrt=1;
    ifdelim=1;
    delim = cfg.delim;
else
    ifrt=0;
    ifdelim=0;
end

%----%
getcfg(cfg,'invert',false)
%invet option
if invert
   dt = -1;
   disp('invert options')
else
    dt = 1;
end


if isfield(cfg,'est') && isfield(cfg,'resp')
    ifrt=1;
    if invert
    r_r = cfg.est;
    r_e = cfg.resp;
    else
    r_r = cfg.resp; 
    r_e = cfg.est;        
    end
    if ifdelim
       ifdelim = 2;
    end
elseif ifdelim
    if invert
    r_r = unique(delim(:,1));
    r_e = unique(delim(:,2:end));
    r_e(r_e==-99)=[];    
    else
    r_e = unique(delim(:,1));
    r_r = unique(delim(:,2:end));
    r_r(r_r==-99)=[];
    end
    ifdelim = 2;
end
%----%    



if isfield(cfg,'stop') 
    ifstop = 1;
    stop = cfg.stop;
else
    ifstop = 0;
end


switch cfg.type
  case 'presentation'
        getcfg(cfg,'sep','[,\t]') 
        if isfield(cfg, 'unit')
           if strcmp(cfg.unit, 'ms'),

               unit = 0.1; 
           elseif strcmp(cfg.unit, 's'), 
               unit = 0.0001; 
           end
        else
            cfg.unit = 'ms';
            unit = 0.1;
        end
   case {'neuroscan','ev2','EV2'}
       getcfg(cfg,'sep',' ') 
       getcfg(cfg,'srate',1000)
       getcfg(cfg,'unit',1000/srate)
       if ischar(unit)
          if strcmp(cfg.unit, 'ms')
              unit= 1000/srate;
          elseif strcmp(cfg.unit, 's')
              unit= 1/srate;
          end          
       end
    case {'micromed' , 'pos' , 'POS','POS_raw'}
       getcfg(cfg,'sep',' ') 
       getcfg(cfg,'srate',512)
       getcfg(cfg,'unit',1000/srate)
       if ischar(unit)
          if strcmp(cfg.unit, 'ms')
              unit= 1000/srate;
          elseif strcmp(cfg.unit, 's')
              unit= 1/srate;
          end          
       end  
    case {'RT','rt'}
       getcfg(cfg,'sep',' ') 
       getcfg(cfg,'srate')
       unit = 1; %  ms
       
end
        
        

if isfield(cfg,'rw') 
    ifrw = 1;
    rw = cfg.rw/unit;
else
    ifrw = 0;
end

if isfield(cfg,'miss')
    ifmiss=cfg.miss;
else
    ifmiss=0;
end

% busca los tiempos alreves, 
getcfg(cfg,'invert',false)

if isfield(cfg, 'filename')
    cfg.filename = fix_path(cfg.filename);
end

%-----%
rt = [];
laten = [];
est =  [];
resp =  [];





%---% diferentes formatos:
switch cfg.type
    
   %-:% neuroscan, file *.ev2
    case {'neuroscan', 'ev2', 'EV2'}
        % read file
        raw = readtext(cfg.filename,sep,'','','textual');%
        [f c] = size(raw);
        data = cell(f,6);
        for ci = 1:f
            %paso = 
            data(ci,:) = raw(ci,~isemptycell(raw(ci,:)));
            %data{ci,6} = data{ci,6}+1;% fix poit zero
        end
        % borrara repetidos
            [paso1 indx] = sort(str2double(data(:,6)));
            data = data(indx,:);
            paso2 = str2double(data(:,2));
            borrame=cat(1,false,(diff(paso1)==0)&(diff(paso2)==0));
            data(borrame,:) = [];
        %
        ne = 2 ;
        nt = 6 ;
        getcfg(cfg,'ifr',false)
        nr = 3;
        %data(ci,:)
    %-:% LAN, Rtstructure   
    case {'RT','rt'}
        data = [ cfg.RT.est(:)  cfg.RT.laten(:)  cfg.RT.resp(:)  ] ;
        ne=1;
        nt=2;
        getcfg(cfg,'ifr',false)
        nr = 3;
        % del repeteated
        ind = find( diff(cfg.RT.est)==0 & diff(cfg.RT.laten)==0 );
        disp([ 'Delete '    num2str(numel(ind)) ' repeteated stimuli ' ] )
        data(ind,:) = [];
        if isfield(cfg.RT, 'OTHER')
            dataOTHER = cfg.RT.OTHER;
            for OT = fieldnames(dataOTHER)'
                eval([ 'dataOTHER.'  OT{1}  '=[];'])
            end
        end
    %-:% presentation, file *.log 
    case 'presentation'
        % read file
        raw = readtext(cfg.filename,sep,'','','textual');
        [f c] = size(raw);
     
        
        header = raw(1:5,:);
        data = raw(6:f,:);
        if strcmp(header{4,1}, 'Subject')
        suject = data{1,1};
        data = data(:,2:c);
        end
        
        ne = 3 ;
        nt = 4 ;
        ifr = false;
        
    case {'micromed', 'pos', 'POS'}
        % read file
        raw = readtext(cfg.filename,sep,'','','textual');%
        [f c] = size(raw);
        raw=raw';
        raw(ifcellis(raw,''))=[];
        raw = reshape(raw,3,f);
        data = raw';%cellfun(@str2num,raw);
        %data = cell(f,6);
        %for ci = 1:f
        %    %paso = 
        %    data(ci,:) = raw(ci,~isemptycell(raw(ci,:)));
        %    %data{ci,6} = data{ci,6}+1;% fix poit zero
        %end
        
        % % orden check
            [paso1 indx] = sort(str2double(data(:,1)));
            if any(diff(indx)~=1), error('Pos file time are not sort... check your file!'); end
            %data = data(indx,:);
        %
        ne = 2 ;
        nt = 1 ;
        getcfg(cfg,'ifr',false)
        nr = 2;
        %data(ci,:)
    %-:% presentation, file *.log        
end
%---%



if ifrt 
    if ischar(data(1,ne))
        odel = str2double(data(:,ne));      % estimulos
        del = zeros(size(odel));
        tt  = str2double(data(:,nt));       % tiempo
        if ifr                              % si respuestas separadas
            rdel = str2double(data(:,nr));  % respuestas
        end
    elseif iscell(data)
        odel = (fun_in_cell (data(:,ne), 'str2num(@)' ));      % estimulos
        del = zeros(size(odel));
        tt  = fun_in_cell(data(:,nt),'str2num(@)');       % tiempo
        if ifr                              % si respuestas separadas
            rdel =fun_in_cell(data(:,nr),'str2num(@)');  % respuestas
        end
    else
        odel = (data(:,ne));      % estimulos
        del = zeros(size(odel));
        tt  = (data(:,nt));       % tiempo
        if ifr                              % si respuestas separadas
            rdel =(data(:,nr));  % respuestas
        end
    end
    %---%
    if ifdelim==1
        for i = 1:size(delim,1)
                del= del + (odel==delim(i,1));
                for ii = 2:size(delim,2)
                    if delim(i,ii)==-99, break,end % termina el loop al encontrat un -99
                     if ifr
                         del = del + (2*(rdel==delim(i,ii)));
                     else
                         del = del + (2*(odel==delim(i,ii)));
                     end
                end
        end
    else
        for i = 1:length(r_e)
            del= del + (odel==r_e(i));
        end
        for ii = 1:length(r_r)
                %if delim(i,ii)==-99, break,end % termina el loop al encontrat un -99
                del = del + (2*(odel==r_r(ii)));    
        
        end   
    end
    %---%
    
    
    
if ifstop
    stop = stop(:);
    no = zeros(size(del));
    for di = unique(stop')
    no = no + (3*(odel==(di)));
    end
    del = del + no;
    clear no
end

delind = find(del==1);
%%%
c=1;
cmis=1;
misslaten = 0;
%laten = tt(r);





for r = delind'  
    rp=1;
    while rp > 0
    if ( r+(rp*dt) > length(del) ) ||( r+(rp*dt) <1 ) || ( del(r+(rp*dt)) == 1) || ( del(r+(rp*dt)) == 3)
        misslaten(cmis) = tt(r);
        missest(cmis) = odel(r);
        rp = -1;  % end, miss 
        cmis = cmis+1;
    elseif del(r+(rp*dt)) == 2
        laten(c) = tt(r);
        rt(c)    = tt(r+(rp*dt)) - tt(r);
        if ifr
            resp(c)  = rdel(r+(rp*dt));
        else
            resp(c)  = odel(r+(rp*dt));
        end
        est(c)   = odel(r);
        if logical(ifrw) && (rt(c) > rw)
            misslaten(cmis) = tt(r);
            missest(cmis) = odel(r);
            rp = -1;  % end, miss 
            cmis = cmis+1;
                laten(c) = [];
                rt(c)    = [];
                resp(c)  = [];
                est(c)   = [];
        else
            rp = 0;
            c = c+1;
        end
    else
        rp = rp +1;
    end
    end
    %%%
    
end

if sum(misslaten) >0
    ifml=1;
    misslaten = misslaten* unit;
else
    ifml=0;
end
    rt = rt * unit;
    laten = laten * unit;
    tr_tt = tt *unit;


if (iflbc)&&(~f_laten)
    if sum(misslaten) >0
    lb = min(laten(1),misslaten(1));
    else
    lb = min(laten);
    end
elseif (iflbc)&&(f_laten)
    if (sum(misslaten) >0)&&(~isempty(laten))
    lb = min(laten(1),misslaten(1));
    elseif ~isempty(laten)
    lb = min(laten);    
    else
    lb = min(misslaten);
    end   
    if f_laten<0
        lb = tr_tt(abs(f_laten));
    else
        lb=   lb-f_laten ;
    end
else
    lb=0;
end

RT.rt    = (rt);
RT.laten = (laten-lb);

if ifml
    RT.misslaten = (misslaten-lb);
    RT.missest = missest;
else
     RT.misslaten = [];
     RT.missest   = [];
end

if invert
RT.est = resp;
RT.resp = est;
RT.laten = RT.laten + RT.rt ;
RT.rt = RT.rt * -1;
else
RT.est = est;
RT.resp = resp;    
end
RT.cfg = cfg; 
RT.nblock = 1;

if ~ifmiss
    RT = miss2rt(RT);
end

%---% find correct
if ifdelim==2
correct = false(size(RT.est));
for i = 1:size(delim,1)
    for ii = 2:size(delim,2)
        if delim(i,ii) == -99, break, end
        correct( RT.est==delim(i,1) & RT.resp==delim(i,ii) ) = true;
    end
end
RT.correct = logical(correct); 
end
%---%

% save optcions
RT.cfg=cfg;

%--%
if nargin ==2
   RT = lan_add_rt(LAN,RT); 
end


% elimina repetidos %FIXME !!!
repetidos = find((diff(RT.laten))==0);
RT = rt_del(RT,repetidos);

end