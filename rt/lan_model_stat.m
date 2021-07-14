function [pval, stats] = lan_model_stat(y,varargin)
% v.0.4
% [pval stats] = lan_model_stat(y,x1,x2,...,cfg)
%
% cfg.type = 'glm' , 'robust', 'lme'
% cfg.ops = option for bar  SEE bar_wait.m  
%
% Dependences: Statistic Toolbox
%
% Pablo Billeke
% 21.06.2017 --> implenetado modelo mixto LME, REQUIERE MATLAB 2015 en
%                adelante!!!; ultimo X, es el factoro de agrpaci?n para
%                intercepto!!!!
% 11.04.2014
% 05.03.2014
% 16.05.2012

if nargin == 0
   help  lan_model_stat
   if strcmp(lanversion('t'),'devel')
       edit lan_model_stat
   end
   return
end


if isstruct(varargin{end})
  cfg = varargin{end};
  nx = length(varargin)-1;  
else
  cfg = [];
  nx = length(varargin);
end
varargin = varargin(1:nx);


%cfg
ntype = getcfg(cfg,'type','glm');
ops = getcfg(cfg,'ops',' ');


dimen = size(y);
ns = dimen(end);

for x = 1:nx+1
pval{x} = zeros(dimen(1:(end-1)));
stats.t{x} = zeros(dimen(1:(end-1)));
stats.b{x} = zeros(dimen(1:(end-1)));
end

np = prod(dimen(1:(end-1)));


y = reshape(y,np,ns);

% regresors
for x = 1:nx
  if numel(varargin{x})==ns;
  ifuni(x) = true;
  elseif numel(varargin{x})==np*ns;
  varargin{x} = reshape(y,np,ns);
  ifuni(x) = false;
  else
    error('dimension of xs')
  end
end
warning off
% type
switch ntype
    
    case {'lme', 'fitlme'}    
    
    x_s = '' ;
    x_n = ' ';
    f='Y ~ 1 ';
    for x=1:nx
       if ifuni, rp = '1'; else rp = 'p' ; end
       %if x==1, first=''; ys='y(p,:)'; else first=' , '; ys='' ;;end
       x_s = [ x_s , strrep( strrep([', varargin{x}(p,:)'' ' ], 'x' , num2str(x)), 'p' , rp )    ];
       x_n = [ x_n   ', ''X' num2str(x) ''' '  ];
       if x==nx
       f= [f '+ (1|X' num2str(x)  ') ' ];   
       else
       f= [f '+X' num2str(x)  ' ' ];
       end
    end
    x_s = ['table(y(p,:)''  ' x_s ', ''VariableNames'' , { ''Y'' ' x_n  ' } )  '];
    
    
    
    
    for p = 1:np
    bar_wait(p,np,ops);
    % no perform regretion with NaNs    
    if any(isnan(y(p,:)))   
        continue
    end
    
    D=eval(x_s);
    clear lme
    lme = fitlme(D,f);
    
    %[b a s] = glmfit( eval(x_s) , y(p,:) );
    for x = 1:nx
    pval{x}(p)=lme.Coefficients.pValue(x);
    stats.t{x}(p)=lme.Coefficients.tStat(x);
    stats.b{x}(p)=lme.Coefficients.Estimate(x);
    end
    end        
        
        
        
        
case {'glm','lm'}
    x_s = 'cat(2' ;
    for x=1:nx
       if ifuni, rp = '1'; else rp = 'p' ; end
       x_s = [ x_s , strrep( strrep(', varargin{x}(p,:)'' ' , 'x' , num2str(x)), 'p' , rp )    ];
    end
    x_s = [ x_s ' )  '];

    for p = 1:np
    bar_wait(p,np,ops);
    % no perform regretion with NaNs    
    if any(isnan(y(p,:)))   
        continue
    end
    
    
    
    [b a s] = glmfit( eval(x_s) , y(p,:) );
    for x = 1:nx+1
    pval{x}(p)=s.p(x);
    stats.t{x}(p)=s.t(x);
    stats.b{x}(p)=b(x);
    end
    end
case 'robust'
    x_s = 'cat(2' ;
    for x=1:nx
       if ifuni, rp = '1'; else rp = 'p'; end
       x_s = [ x_s , strrep( strrep(', varargin{x}(p,:)'' ' , 'x' , num2str(x)), 'p' , rp )    ];
    end
    x_s = [ x_s ' )  '];

    for p = 1:np
    bar_wait(p,np,ops);
    % no perform regretion with NaNs    
    if any(isnan(y(p,:)))   
        continue
    end
    
    [b  s] = robustfit( eval(x_s) , y(p,:) );
   
    for x = 1:nx+1
    pval{x}(p)=s.p(x);
    stats.t{x}(p)=s.t(x);
    stats.b{x}(p)=b(x);
    end
    end	
end% switch type
 warning on


end % fucntion