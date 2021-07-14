function LAN = vol_thr_lan(LAN,thr,tagname)
%       <*LAN)<
%       v.0.0.01
%
%       Detec voltange variations
%
% 16.06.2011
% Pablo Billeke
%
if nargin <3
    tagname = 'bad';
end
fprintf( 'Voltage threshold \n')


LAN = lan_check(LAN);




if iscell(LAN)
    for lan =1:length(LAN)
        LAN{lan} = vol_thr_lan_str(LAN{lan},thr,tagname);
    end
else
    LAN = vol_thr_lan_str(LAN,thr,tagname);
end

            fprintf( '\n DONE \n')
end

function LAN = vol_thr_lan_str(LAN,thr,tagname)

%
if isempty(LAN.tag.labels)
    ntag = 1;
    LAN.tag.labels{1} = tagname;
else
    ntag = find(ifcellis(LAN.tag.labels,tagname));
    if isempty(ntag)
        ntag = length(LAN.tag.labels) + 1;
        LAN.tag.labels{ntag} = tagname;

    end
end

%
c=0;

tt = 1:LAN.trials;
%tt(LAN.accept)=[];% no interpolar trial no aceptados

for nt = tt;
    for nch = 1:LAN.nbchan
        d = LAN.data{nt}(nch,:);
        %d = d - mean(d)
        if abs(max(d)-min(d))>thr
            LAN.tag.mat(nch,nt) = ntag;
            fprintf('o')
            c=c+1;
            if mod(50,c)>1
               c = c-50;
               fprintf('\n') 
            end
        end  
    end
end
end


