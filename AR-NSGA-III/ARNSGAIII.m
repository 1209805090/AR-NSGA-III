function ARNSGAIII(Global)
% <algorithm> <A>
% ���ڲο���ѡ����ԵĸĽ���NSGA-III�㷨

%------------------------------- Reference --------------------------------
% ����ͬ,���б�,������,���, ��.���ڲο���ѡ����ԵĸĽ���NSGA-III�㷨[J].ģʽʶ�����˹�����,2020.

%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Generate the reference points and random population

    [Z,numOfReferencePoint] = DzbUniformPoint(Global.N * 1.19,Global.M);	%��ʼ���ο�����Ŀ>=N*1.20,�����д��>N*1.19
    
    Population   = Global.Initialization();     %��ʼ����Ⱥ
    
    M = Global.M;                               %Ŀ����
    N = Global.N;                               %��Ⱥ��ģ
    D = Global.D;                               %���߱���ά��
    ub =  Global.upper;                         %���߱����Ͻ�
    lb = Global.lower;                          %���߱����½�
    Gmax = Global.maxgen;                       %��Ⱥ����������
    
    
    threshold = D*((0.5+1/N)*log10(0.5+1/N)-0.5*log10(0.5));    %��Ⱥ�����׶���ֵ
	fprintf('��ֵ��%f\n',threshold);

    
    [dec, ~] = getPopulationDecAndObj(Population);              %��ȡ��Ⱥ�ľ�������
    X = sort(dec);                                              %�Ծ�������ÿ��ά�Ƚ�������
    mid = X(int32(N*2/4),:);                                    %��������ÿ��ά�ȵ���λ��
   
    i=1;
    entropyArr = zeros(1,Gmax);                                 %�����洢ÿ����Ⱥ����
    entropyArr2 = zeros(1,Gmax);                                %�����洢����������Ⱥ���ز�
    entropy = getEntropy(Population, ub, lb, mid);              %������
    entropyArr(i) = entropy;

    Zmin = min(Population(all(Population.cons<=0,2)).objs,[],1);
    

    totalOfRPointAssociation = [0];                             %ÿ���ο�������ĸ�����ͳ��ֵ
    Dsum = 0;                                                   %ͳ���ز�С����ֵ���ֵĴ���
    flag = 0;                                                   %�ж��Ƿ��Ѿ����вο���ɾ�������ı��
    fprintf('Dzb��Ⱥ����%d\tԭʼ�ο�������%d\t�����ο�������%d\n',Global.N,numOfReferencePoint,Global.N);
    
    
    %% Optimization
    while Global.NotTermination(Population)

        MatingPool = TournamentSelection(2,Global.N,sum(max(0,Population.cons),2));
        Offspring  = GA(Population(MatingPool));
        Zmin       = min([Zmin;Offspring(all(Offspring.cons<=0,2)).objs],[],1);
        
        
        [Population,rho] = EnvironmentalSelection([Population,Offspring],Global.N,Z,Zmin);
        totalOfRPointAssociation = totalOfRPointAssociation + rho;  %ͳ�Ʋο�������ĸ�����������rhoΪÿһ���ο�������ĸ�����Ŀ
        
        
        i=i+1;
        entropy = getEntropy(Population, ub, lb, mid);              %�������Ⱥ���߱�������
        entropyArr(i) = entropy;
        entropyArr2(i) = abs(entropyArr(i-1) - entropyArr(i));      %��������������Ⱥ���ز�
        
        %����ز�С����ֵ
        if entropyArr2(i) < threshold
            Dsum = Dsum + 1;
        end

        
        [dec, ~] = getPopulationDecAndObj(Population);              %��ȡ��Ⱥ�ľ�������
        X = sort(dec);                                              %�Ծ�������ÿ��ά�Ƚ�������
        mid = X(int32(N*2/4),:);                                    %��������ÿ��ά�ȵ���λ��
        
             
%         if Global.evaluated >= Global.evaluation / 2 && flag == 0
        %�ο���ɸѡ����
        if Dsum >= Gmax * 0.1 && flag == 0
            fprintf('��%d�����롰̽���ס���\n',i);
            flag = flag + 1;
            numOfDel = numOfReferencePoint - N;                     %����ɾ���Ĳο�����Ŀ
            k=0;
            while k < numOfDel
                [~,n]=min(totalOfRPointAssociation);                %��ȡ����������Ŀ���ٵĲο���
                totalOfRPointAssociation(n) = [];
                Z(n,:)=[];                                          %ɾ���ο���
                k = k + 1;
            end
%             save('Zn.mat','Z');
%             fprintf('�����ο�������%d\n',size(Z,1));
        end
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
end