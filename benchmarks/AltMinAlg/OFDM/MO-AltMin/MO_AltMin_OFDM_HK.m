function [ FRF, FBB, stat ] = MO_AltMin_OFDM_HK(Fopt, NRF, FRF_in)


    [Nt, Ns, K] = size(Fopt);
    y = [];
    %FRF = exp( 1i*unifrnd(0,2*pi,Nt,NRF) );
    if FRF_in == 0
        FRF = exp( 1i*unifrnd(0,2*pi,Nt,NRF) );
    else
        FRF = FRF_in;
    end 

    init_cost = 0;
    for k = 1:K      
        FBB(:,:,k) = pinv(FRF) * Fopt(:,:,k); 
        init_cost = init_cost + norm(Fopt(:,:,k) - FRF * FBB(:,:,k),'fro')^2;
    end
     
    index = 1;
    cost(index) = init_cost;
    
    last_time = 0;
    time(index) = last_time;
    
    while(isempty(y) || abs(y(1)-y(2))>1e-1)

        % set start time
        start_time = tic();

        y = [0,0];
        for k = 1:K      
            FBB(:,:,k) = pinv(FRF) * Fopt(:,:,k); 
            y(1) = y(1) + norm(Fopt(:,:,k) - FRF * FBB(:,:,k),'fro')^2;
        end        
        
        % measure elapsed time
        elapsed_time = toc(start_time);

        last_time = last_time + elapsed_time;

        [FRF, info] = sig_manif(Fopt, FRF, FBB);


        y(2) = real(info(end).cost);

        len = length(info);
        for j=1:len
            index = index + 1;
            cost(index) = real(info(j).cost);
            time(index) = last_time + real(info(j).time);
        end

        last_time = time(index);
    end

    stat.cost = cost;
    stat.time = time;

end