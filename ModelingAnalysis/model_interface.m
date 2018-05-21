function [ls,ydata,xdata,Q1,Q2] = model_interface(x,cs,us,xdata,model,out_f,incl_us)

beta_prior = 1;

switch model
    case 'RW1'
        init = 0.5;
        %initialize values for CS+ and CS-:
        Q1 = init*ones(size(us));
        Q2 = init*ones(size(us));
        %update rule for every trial:
        for i = 1:length(us)-1
            if cs(i) == 1 %cs+, update cs+ representation:
                Q1(i+1:end) = Q1(i)+x(end)*(us(i)-Q1(i));
            else %update cs- representation:
                Q2(i+1:end) = Q2(i)+x(end)*(us(i)-Q2(i));
            end
        end
        
    case 'BM0'
        trials = length(cs);
        init = beta_prior;
        A = init;
        B = init;
        A1 = init;
        B1 = init;
        Q1 = (A/(A+B))*ones(trials,1);
        Q2 = (A1/(A1+B1))*ones(trials,1);
        for tr = 1:trials
            if cs(tr) == 1
                %model update:
                A = A+us(tr);
                B = B-us(tr)+1;
                BM = A/(A+B);
                Q1(tr+1:end) = BM;
            else
                A1 = A1+us(tr);
                B1 = B1-us(tr)+1;
                BM = A1/(A1+B1);
                Q2(tr+1:end) = BM;
            end
        end
        
    case 'UN0'
        trials = length(cs);
        init = beta_prior;
        A = init;
        B = init;
        A1 = init;
        B1 = init;
        Q1 = (A/(A+B))*ones(trials,1);
        Q2 = (A1/(A1+B1))*ones(trials,1);
        for tr = 1:trials
            if cs(tr) == 1
                %model update:
                A = A+us(tr);
                B = B-us(tr)+1;
                Q1(tr+1:end) = -log(A+B);
            else
                %model update:
                A1 = A1+us(tr);
                B1 = B1-us(tr)+1;
                Q2(tr+1:end) = -log(A1+B1);
            end
        end
        
    case 'BC0'
        trials = length(cs);
        init = beta_prior;
        A = init;
        B = init;
        A1 = init;
        B1 = init;
        Q1 = (A/(A+B))*ones(trials,1);
        Q2 = (A1/(A1+B1))*ones(trials,1);
        for tr = 1:trials  
            if cs(tr) == 1   
                %model update:
                A = A+us(tr);
                B = B-us(tr)+1;
                BM = A/(A+B);
                UN = -log(A+B);
                Q1(tr+1:end) = BM+UN;     
            else
                %model update:
                A1 = A1+us(tr);
                B1 = B1-us(tr)+1;
                BM = A1/(A1+B1);
                UN = -log(A1+B1);
                Q2(tr+1:end) = BM+UN;
                
            end
        end
        
    case 'HM1' %hybrid model between PH and RW
        init1 = 1;
        init2 = 1;
        Q1 = 0.5*ones(size(us));
        Q2 = 0.5*ones(size(us));
        a1 = init1*ones(size(us));
        a2 = init2*ones(size(us));
        
        %update rule for every trial:
        for i = 1:length(us)-1
            if cs(i) == 1 %cs+, update cs+ representation:
                a1(i+1:end) = x(end)*abs(us(i)-Q1(i))+(1-x(end))*a1(i);
                Q1(i+1:end) = Q1(i)+a1(i)*(us(i)-Q1(i));    
            else %update cs- representation:
                a2(i+1:end) = x(end)*abs(us(i)-Q2(i))+(1-x(end))*a2(i);
                Q2(i+1:end) = Q2(i)+a2(i)*(us(i)-Q2(i));
            end
        end
        Q1 = a1;
        Q2 = a2;
        
    case 'HM2' %hybrid model between PH and RW
        init1 = 1;
        init2 = 1;
        %initialize values for CS+ and CS-:
        Q1 = 0.5*ones(size(us));
        Q2 = 0.5*ones(size(us));
        a1 = init1*ones(size(us));
        a2 = init2*ones(size(us));
        %update rule for every trial:
        for i = 1:length(us)-1
            if cs(i) == 1 %cs+, update cs+ representation:
                
                a1(i+1:end) = x(end)*abs(us(i)-Q1(i))+(1-x(end))*a1(i);
                Q1(i+1:end) = Q1(i)+a1(i)*(us(i)-Q1(i));
                
            else %update cs- representation:
                a2(i+1:end) = x(end)*abs(us(i)-Q2(i))+(1-x(end))*a2(i);
                Q2(i+1:end) = Q2(i)+a2(i)*(us(i)-Q2(i));
            end
        end
          
    case 'NL0'
        Q1 = ones(length(cs),1);
        Q2 = zeros(length(cs),1);
             
end

switch out_f
    case 'li2' %linear function
        Q1 = x(1)*Q1+x(2);
        Q2 = x(1)*Q2+x(2);   
end
ydata1 = [Q1 Q2];
for i = 1:size(ydata1,1)
    ydata(i) = ydata1(i,cs(i));
end
xdata = xdata./max(xdata);
%compute sum of squared residuals:
if ~incl_us
    ls = 0;
    for i = 1:length(ydata)
        if us(i) == 0
            ls = ls + (ydata(i)-xdata(i))^2;
        end
    end
else
    ls = 0;
    for i = 1:length(ydata)
        
        ls = ls + (ydata(i)-xdata(i))^2; 
    end
end

