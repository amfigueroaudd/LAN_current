function A = lan_smooth_d1(A,n)






if nargin==2
    if n == 0
    return
    end
    
    for x = 1:n
    A=lan_smooth(A);
    end
else
nn = isnan(A);
A(nn) = 0;    




[d1 d2]= size(A);

A = ( A +  ...
           (cat(1,A(1,:),A(1:d1-1,:)))/2 .... 
           + (cat(1,A(2:d1,:),A(d1,:)))/2 ...
           ...%+ (cat(2,A(:,1),A(:,1:d2-1)))/4 .... 
           ...%+ (cat(2,A(:,2:d2),A(:,d2)))/4 ...
       ) /2  ;

A = ( A +  ...
           (cat(1,A(1:2,:),A(1:d1-2,:)))/4 .... 
           + (cat(1,A(3:d1,:),A(d1-1:d1,:)))/4 ...
           ...+ (cat(2,A(:,1:2),A(:,1:d2-2)))/8 .... 
           ...+ (cat(2,A(:,3:d2),A(:,d2-1:d2)))/8 ...
       ) /1.5  ;

A = ( A +  ...
           (cat(1,A(1:3,:),A(1:d1-3,:)))/8 .... 
           + (cat(1,A(4:d1,:),A(d1-2:d1,:)))/8 ...
           ...+ (cat(2,A(:,1:3),A(:,1:d2-3)))/16 .... 
           ...+ (cat(2,A(:,4:d2),A(:,d2-2:d2)))/16 ...
       ) /1.25  ;

A = ( A +  ...
           (cat(1,A(1:4,:),A(1:d1-4,:)))/16 .... 
           + (cat(1,A(5:d1,:),A(d1-3:d1,:)))/16 ...
           ...+ (cat(2,A(:,1:4),A(:,1:d2-4)))/32 .... 
           ...+ (cat(2,A(:,5:d2),A(:,d2-3:d2)))/32 ...
       ) /1.125  ;

A = ( A +  ...
           (cat(1,A(1:5,:),A(1:d1-5,:)))/32 .... 
           + (cat(1,A(6:d1,:),A(d1-4:d1,:)))/32 ...
           ...+ (cat(2,A(:,1:5),A(:,1:d2-5)))/64 .... 
           ...+ (cat(2,A(:,6:d2),A(:,d2-4:d2)))/64 ...
       ) /1.0625  ;
   
A(nn) = nan;   
end