%% Wind data analysis integrating 3 data bases
% The three data bases used are MERRA, LiDAR Measurements and Ma�a Eolis WT 
% measurements.
%%

%% 1. Filtering dates and selection criteria
% The dates are choosen as desired;from MERRA DB are extracted the conditions 
% of Monin Obukhov stability (MO),Wind direction(WD) and Wind Speed (WS). 
close all; clear all; clc
% p = [3032         -63         803         740];
% set(0,'DefaultFigurePosition',p);


UseDateRange=1; % input('use data Range (If yes tipe 1, else 0)');

UseMERRA=1;
Iu=0.15;

     %%%%%%%------------EDIT DATA FOR MERRA----------%%%%%%%%%%%%%
        %MO4MERRAmin=-1000;      % Limit of the MO criteria
        MO4MERRA=1000;      % Limit of the MO criteria
        %MO4MERRAmax=140;      % Limit of the MO criteria
        %MO4MERRAmin=-1000;      % Limit of the MO criteria
        useWD=1; %input('Restrict WD (If yes tipe 1, else 0 )');
                  WD=233; %input('WD [degrees]=');
                  pmWD=(atand(Iu*0.75)); %input('Dispersion ');
        useWS=1; %input('Restrict WS (If yes tipe 1, else 0 )');
                  WS=13; WSref=WS;%input('WS [m.s^-1]=');
                  pmWS=(Iu*WS); %input('Dispersion ');

        %---------------------------------------------
UseME=1; UseSMV6=0; % 0 for SMV5  1 for SMV6

% % % -----------EDIT LiDAR TREATMENT--------------- % % %
    % 1 Average total; 2 Average per minutes, 3 No average and only 3
    % consecutives PPIS, 4 No Average at all,
    Averagetype=1; 
    % % % % % %  If Avergae type 2 selected
    Averagein_min=60; % Modify the code for averages smaller than 60 FIXME
        %  1 MERRA, 2 LIDAR
    UseWDFROM=2; 
    RestricitLiDARWD=1; % 0 No, 1 Yes

            if UseDateRange
                Date=['21122015';'31052016'];
                sprintf('\b\b\b\b\b\b\b\b\nData will be analized between: %s/%s/%s and %s/%s/%s',...
                    Date(1,1:2),Date(1,3:4),Date(1,5:8),...
                    Date(2,1:2),Date(2,3:4),Date(2,5:8))
            else
                Date='21122015'; 
                sprintf('\b\b\b\b\b\b\b\b\b\b Data will be analized in:');
                    sprintf('\b\b\b\b\b\b\b\b\b\b %s/%s/%s',...
                        Date(1,1:2),Date(1,3:4),Date(1,5:8))
            end
 
 %% 2. Analize WD ans WS on wind rose from MERRA
 % The data is impoted from MERRA DB, the selected dates are separated and
 % clasified for assesment of the wind conditions.
 %%
%     rootmerra=('C:\EOLINEPRJ\RAW-DATA\Data\MERRA\');
 rootmerra=('/home/hji2016/LIDAR/Smarteole Database/MERRA/');
%     rootmerra=('\\ESA-173\EOLINE-PRJ-EulalioPC\RAW-DATA\Data\MERRA\');
    toto=importdata(strcat(rootmerra,'Merra_E2.5_N49.5-201510-201607_Interpolates.csv'), ';', 1);
%         toto=importdata(strcat(rootmerra,'Merra_E2.5_N49.5-201510-201607_I2.csv'), ';', 1);

%         toto=importdata(strcat(rootmerra,'Merra_E2.5_N49.5-201510-201607.csv'), ';', 1);
%      toto=importdata(strcat(rootmerra,'Merra_E2.5_N49.5-201510-201607corrected.csv'),
%     ';', 1); % Correted +15� FIXME
    data_merra =toto.data;
    date=toto.textdata(2:end,1);
    [I,J]=size(Date);
    
    ExtractWindData; % read the data between the specified dates
  countFigs=1;  
 % Plotting Wind conditions
 %%  2.1) Wind direction
 % Histogram of WD in bins of 10� and centered at decens of degress with a  
 % width of +-5�each bin.
 %
   figure;
    MM=hist (WD_50m2Pass,Y);
    text1=(Y( find(MM==max(MM))));
    hist (WD_50m2Pass,Y);
    text2=sprintf('Wind Direction, mean %3.1f �', mean(WD_50m2Pass));
    xlabel('WD [�]'); ylabel('# '); title (text2); 
    xlim([0 350])
%% 2.2) Wind Speed
% Histogram of WS in bins of 1 m/s.
%-------------------------------------------------------------------------
    figure(countFigs + 1);
    countFigs=countFigs + 1;
    hist(WS_50m2Pass,30);
        text2=sprintf('Wind speed, mean %3.1f m * s^{-1}', mean(WS_50m2Pass));
        xlabel('WS [m \cdot s^{-1}]'); ylabel('relative frequency per 0.5 m\cdot s^{-1} interval '); title (text2);
%% 2.3) Wind rose
% Wind rose in meteorological wind directions.
%-------------------------------------------------------------------------
    figure(countFigs + 1);
    countFigs=countFigs + 1;
     wind_rose(WD_50m2Pass,WS_50m2Pass,'n',50,'di',[0 5 7 9 11 13 18 21 24],'dtype','meteo','lablegend',('m \cdot s^{-1}'));
     set(gcf, 'InvertHardcopy','off');  
%% 2.4) Data acumulation
% Acmulation of number of hours (vertical axis), separated according WD and 
% MO criteria.
%-------------------------------------------------------------------------
 figure(countFigs + 1);
    countFigs=countFigs + 1;
 plot(Y,N1,'--ro',Y,N2,'--b*',Y,N3,'--g<')
 legend('|\it{L}| \geq 1000','|\it{L}| \geq 800','|\it{L}| \geq 500')
 xlabel('WD [�] MERRA');ylabel('# hours')
 xlim([100 350])
 title(['D A T E ';Date])
 
%% 3) Filtering data in MERRA
% In this section it is select more condtitions for further posprocessing,
% selection of the MO, use the WD limitation and scatter in the main WD,
% the data will be send to Scanning LiDAR, the data will be used to comparison 
% with the field measurements.
% Define MO, Use of WD the centered WD and the limits to consider. Tha date
% will be send to the next stage.


if UseMERRA
 sprintf('\b\b\b\b\b\b\b\bMERRA Data Base will be use to filter the dates')
 
    I_MO=find(-MO4MERRA <= MO & MO <= 0);% unstable
   % I_MO=find(0<= MO & MO <= MO4MERRA); %stable
   % I_MO=find(MO4MERRAmin >= MO | MO >= MO4MERRA); %neutral
%         I_MO=find(  MO4MERRA <= MO &  MO <0 );
        plot(MO(I_MO))
        

    
    sprintf('\b\b\b\b\b\b\b\b\rThe MO criteria is |MO| >= % 4.0f', MO4MERRA)
    sprintf('\b\b\b\b\b\b\b\b\rIn MERRA there is %d hours that fullfill the MO criteria', numel(I_MO))

            if useWD
              sprintf('\b\b\b\b\b\b\b\b\rThe WD is centered in %d� with a scater of +-%d�',...
                  WD,pmWD)
              I_WD=find(WD-pmWD <= WD_50m2Pass(I_MO) & WD+pmWD > WD_50m2Pass(I_MO));  
            else
              sprintf('\b\b\b\b\b\b\b\b\rThere is no WD restriction in MERRA DB')              
            end
            if useWS
              sprintf('\b\b\b\b\b\b\b\b\rThe WS is centered in %d m*s^{-1} with a scater of +-%d m*s^{-1}',...
              WS,round(pmWS*10)/10)
              I_WS=find(WS-pmWS <= WS_50m2Pass(I_MO) & WS+pmWS > WS_50m2Pass(I_MO));  
            else
              sprintf('\b\b\b\b\b\b\b\b\rThere is no WS restriction in MERRA')               
            end
            
            if useWD && useWS
              Date2PassMERRA=Date2Pass(I_MO(I_WD(find(ismember(I_MO(I_WD), I_MO(I_WS))==1))));
              WS2PassMERRA=WS_50m2Pass(I_MO(I_WD(find(ismember(I_MO(I_WD), I_MO(I_WS))==1))));
              WD2PassMERRA=WD_50m2Pass(I_MO(I_WD(find(ismember(I_MO(I_WD), I_MO(I_WS))==1))));
              MO2PassMERRA=MO(I_MO(I_WD(find(ismember(I_MO(I_WD), I_MO(I_WS))==1))));
            elseif useWD
              Date2PassMERRA= Date2Pass(I_MO(I_WD));
              WS2PassMERRA=WS_50m2Pass(I_MO(I_WD));
              WD2PassMERRA=WD_50m2Pass(I_MO(I_WD));
              MO2PassMERRA=MO(I_MO(I_WD));
            elseif useWS

              Date2PassMERRA= Date2Pass(I_MO(I_WS));
              WS2PassMERRA=WS_50m2Pass(I_MO(I_WS));
              WD2PassMERRA=WD_50m2Pass(I_MO(I_WS));
              MO2PassMERRA=MO(I_MO(I_WS));  
            else
              Date2PassMERRA=Date2Pass(I_MO);
              WS2PassMERRA=WS_50m2Pass(I_MO);
              WD2PassMERRA=WD_50m2Pass(I_MO);
              MO2PassMERRA=MO(I_MO);
                
            end
else
          sprintf('\b\b\b\b\b\b\b\b\b\bMERRA Data Base wont be use to filter the dates');

              Date2PassMERRA=Date2Pass;
              WS2PassMERRA=WS_50m2Pass;
              WD2PassMERRA=WD_50m2Pass;
              MO2PassMERRA=MO;   
   end
 sprintf('\b\b\b\b\b\b\b\bThere are %d hours within the characteristics specified',numel(Date2PassMERRA));

  %% 4) Filtering data in ME
  zp = 1.0e+03 * [2.0017    0.5971    0.2234    0.0466];
  zz=waitbar(0,'Filtering DATA in ME DB','position',zp);
 if UseME
      sprintf('\b\b\b\b\b\b\b\bMa�a Eolis (ME) Data Base will be used')
      if iscell(Date2PassMERRA)
         Date2PassMERRA=cell2mat(Date2PassMERRA);
      end
         [M,J]=size(Date2PassMERRA);    
%             rootMaiaE= ('C:\EOLINEPRJ\RAW-DATA\Data\process-ker6');
%             rootMaiaESMV5= ('C:\EOLINEPRJ\RAW-DATA\Data\process-smv5');
            rootMaiaE= ('F:\Donnes Brutes\process-ker6');
            rootMaiaESMV5= ('F:\Donnes Brutes\process-smv5');
            DateME=[];
            DateMESMV5=[];
            JJ=zeros(M,1);
            JJ2=zeros(M,1);
                            clear indexes;

            for i=1:M
                date1 = strrep(Date2PassMERRA(i,1:10),'/','_');
                agno= Date2PassMERRA(i,7:10);
                agnored=Date2PassMERRA(i,9:10);
                dateME = strrep(date1,agno,agnored);
                hour = Date2PassMERRA(i,12:13);
                filename=strcat(rootMaiaE,filesep,agno,'_',Date2PassMERRA(i,4:5),filesep,'VoieProcess_KER6_IEC-INCLINOMETRE_', dateME,'_',hour);
                indexes=(dir(strcat(filename,'_*.txt')));
                filenameSMV5=strcat(rootMaiaE,filesep,agno,'_',Date2PassMERRA(i,4:5),filesep,'VoieProcess_SMV5_PROCESS_', dateME,'_',hour);
                indexesSMV5=(dir(strcat(filename,'_*.txt')));
            
                J=length(indexes);
                JJ(i)=J;
                 if size(indexes)>=1;
                    DateME=[DateME;strcat(dateME,'_',hour)];
                 end
                 if isempty(DateME)==0
                    sprintf('There is no data in ME DB SMV6 for %s',date1);
                 end
                 
                 J=length(indexesSMV5);
                JJ2(i)=J;
                 if size(indexesSMV5)>=1;
                    DateMESMV5=[DateMESMV5;strcat(dateME,'_',hour)];
                 end
                 if isempty(indexesSMV5)==0
                    sprintf('There is no data in ME DB SMV5 for %s',date1);
                 end
               end  

    sprintf('\b\b\b\b\b\b\b\b\nThere are %d files of 10 min in ME DB for WT SMV6', sum(JJ))
        sprintf('\b\b\b\b\b\b\b\b\nThere are %d files of 10 min in ME DB for WT  SMV5', sum(JJ2))


   loadSMV6data;
   loadSMV5data;
   if UseSMV6
       Date2Pass2=DateME;
       DataME=DataMESMV6;

       
   else
       Date2Pass2=DateMESMV5;
       DataME=DataMESMV5;

   end
 else
    sprintf('\b\b\b\b\b\b\b\b\bMa�a Eolis Data Base wont be used')
    DataME=zeros(numel(Date2PassMERRA),7);
    temp=(datevec(Date2PassMERRA,'dd/mm/yyyy HH:MM'));
    DataME(:,[1:3])=temp(:,[2:4]);
    JJ=zeros(size(Date2PassMERRA));
 
end

%% 5) Extracting data in Scanning LiDAR
% This section extract the information from Scanning LiDAR postprocessing, 
% the data included the coordinates of each PPI, the wind speed, wind direction,
% Time stamp and and indexation for the PPI elevation. In the PLOT the markers 
% in red indicated the PPI with NaN and that wonth be taken into account for the procedure. 

%Define  if the plots are going to be instantaneous, 10 Min Average or 1 HH
% Average

% Selecteddata=[Date, # files in ME if selected, WS, WD, MO];
            selecteddata=[datenum(datevec(Date2PassMERRA, 'dd/mm/yyyy HH:MM')),JJ,...
                WS2PassMERRA,WD2PassMERRA,MO2PassMERRA];
    waitbar(1/5,zz,'Extracting LiDAR Data','position',zp);

    
    rootLiDAR=('F:\SmartEole Data Base\ScanningLidar\Field Test1\Processed MAT');
    %rootLiDAR=('E:\SmartEole Data Base\ScanningLidar\Field Test1\Processed MAT');
%    rootLiDAR=('C:\EOLINEPRJ\EAV_V112\for_redistribution_files_only\22122016\');
%    rootLiDAR=('C:\EOLINEPRJ\EAV_V112\for_redistribution_files_only\curtail');
%    rootLiDAR=('\\ESA-173\EOLINE-PRJ-EulalioPC\EAV_V112\for_redistribution_files_only\Mat Processed\');
% %    %     rootLiDAR=('C:\EOLINEPRJ\EAV_V112\for_redistribution_files_only\Mat ProcessedV3');
    [XFF,YFF,ZFF,WSFF,WD_LiDAR,EL,TimeStamp,Index_PPI0,Index_PPI1,Index_PPI2,Index_PPI3,Index_RHI,countfileswithNAN]=...
        ExtractDataV1(selecteddata,rootLiDAR);

    sprintf('\b\b\b\b\b\b\b\bThere are %d files readed in LiDAR measurements\r',numel(TimeStamp))
        if numel(TimeStamp)==0
            return
        end
      

   figure(countFigs + 1);
    countFigs=countFigs + 1;
     plot(Index_PPI1,EL(Index_PPI1),'ob');hold on
      plot(Index_PPI2,EL(Index_PPI2),'og')
       plot(Index_PPI3,EL(Index_PPI3),'ok')
        plot(countfileswithNAN, EL(countfileswithNAN),'*r')

    Index_PPI0_woNaN=setdiff(Index_PPI0,countfileswithNAN);
    Index_PPI1_woNaN=setdiff(Index_PPI1,countfileswithNAN);
    Index_PPI2_woNaN=setdiff(Index_PPI2,countfileswithNAN);
    Index_PPI3_woNaN=setdiff(Index_PPI3,countfileswithNAN);
    Index_RHI_woNaN=setdiff(Index_RHI,countfileswithNAN);
   
    sprintf('\b\b\b\b\b\b\b\b\bPPI1\tPPI2\tPPI3\tRHI\t\tNaN\r')
    sprintf('\b\b\b\b\b\b\b\b\b%d\t\t\t%d\t\t\t%d\t\t\t%d\t\t\t%d\r',numel(Index_PPI1),numel(Index_PPI2),...
    numel(Index_PPI3),numel(Index_RHI),numel(countfileswithNAN))

    sprintf('\b\b\b\b\b\b\b\b\t\two NaN')
    sprintf('\b\b\b\b\b\b\b\b\bPPI1\tPPI2\tPPI3')
    sprintf('\b\b\b\b\b\b\b\b\b%d\t\t\t%d\t\t\t%d',numel(Index_PPI1_woNaN),numel(Index_PPI2_woNaN),...
    numel(Index_PPI3_woNaN))
    
% Wind direction detected by the each PPI in Scannig LiDAR
    figure(countFigs + 1);
    countFigs=countFigs + 1;
    plot(Index_PPI1_woNaN,WD_LiDAR(Index_PPI1_woNaN),'ob--');hold on
    plot(Index_PPI2_woNaN,WD_LiDAR(Index_PPI2_woNaN),'og--')
    plot(Index_PPI3_woNaN,WD_LiDAR(Index_PPI3_woNaN),'ok--')
    title('WD measured by LiDAR system')
    legend('PPI 1','PPI 2','PPI3 ')
    xlabel('Count')
    ylabel('WD [�]')
%     plot(countfileswithNAN, EL(countfileswithNAN),'*r')
% CorrectVelocityFieldv0;

%% 5.1) Vertical profile
%%=====================COMENTS=================================% % %
% There are three cases to average, the total average from the selected
% conditions; 2 the average every certain time within an hour and the
% calculations per plane
% If the second case is selected, averages btwn 10 and 60 min can be choosen.
% The avergae will be done at the end of the interval. It means that if  10 min
% averageas is selected, the intervals will be define from to 10, from 10:01 to
% 20:00 and so on.
%%=====================END OF COMENTS=================================% % %
%***************************************************************************
%=======================END OF EDITION===========================
 ConditionalWD
% datestr(selecteddata(:,1));
% EL,TimeStamp,Index_PPI0,Index_PPI1,Index_PPI2,Index_PPI3
o=numel(selecteddata(:,1));

%     waitbar(2/5,zz,'Calculating Vertical Profiles','position',zp);
    
 AZI=[244:273]; % Azimuth Angle
 
switch Averagetype
    case 1 % Average total
        
        sprintf ('\b\b\b\b\b\b\b\bIt will be calculated only one average for the %d hours selected',o)
        AverageWD_LiDAR=nanmean([nanmean(WD_LiDAR(Index_PPI1_woNaN));nanmean(WD_LiDAR(Index_PPI2_woNaN));nanmean(WD_LiDAR(Index_PPI3_woNaN))]);
        AverageWD_MERRA=nanmean(selecteddata(:,4));
        [ss,sss]=min(AverageWD_LiDAR-AZI);
                LOS=30;
        sprintf('\b\b\b\b\b\b\b\b\bThe average WD is:')
        sprintf('\b\b\b\b\b\b\b\b\b LiDAR  MERRA\n %d    %d',round(AverageWD_LiDAR),round(AverageWD_MERRA))
        MeanType1
        Hours=zeros(1,11);
        if exist('DataME') && numel(DataME)>1
        Hours(1,8)=nanmean(DataME(:,5));
        Hours(1,9)=nanmean(DataME(:,6));
        end
        [u1,u2,u3, z1,z2,z3, uexp, alpha, ulog, uref,zref,z0,ucontrol,zcontrol,ushear]=...
            ExtractVelocitProfile(meanZFF1,meanZFF2,meanZFF3,meanWSFF1,meanWSFF2,meanWSFF3,...
            stdWSFF1,stdWSFF2,stdWSFF3,LOS,AverageWD_LiDAR,WSref);
        
    case 2 % average for minutes
       
        Hours=datevec(datestr(selecteddata(:,1)));
        sprintf ('\b\b\b\b\b\b\b\bIt will be calculated an average every %d min within the %d hours selected',Averagein_min,o)
        
        if Averagein_min>60
            sprintf('The average sould be stablished in an hour, as maximum 60 min');
        end
        MeanType2
       
        u1=[];u2=[];u3=[]; 
        z1=[];z2=[];z3=[]; 
        uexp=[]; alpha=[]; 
        ulog=[]; uref=[];zref=[];
        z0=[];ucontrol=[];zcontrol=[];
        varIntern=0;
        
        NumVarxPPI= numel(var(:,1))/3;
        for ll=1:NumVarxPPI
            if numel(eval(var(ll,:))) && numel(eval(var(ll+NumVarxPPI,:))) && numel(eval(var(ll+NumVarxPPI*2,:)))
            eval(['[u1bin,u2bin,u3bin, z1bin,z2bin,z3bin, uexpbin, alphabin, ulogbin, urefbin,zrefbin,z0bin,ucontrolbin,zcontrolbin]=ExtractVelocitProfile(meanZFF',...
                var(ll,6:18),',meanZFF',var(ll+NumVarxPPI,6:18),',meanZFF',var(ll+(2*NumVarxPPI),6:18),...
            ',meanWSFF',var(ll,6:18),',meanWSFF',var(ll+NumVarxPPI,6:18),',meanWSFF',var(ll+(2*NumVarxPPI),6:18),...
            ',stdWSFF',var(ll,6:18),',stdWSFF',var(ll+NumVarxPPI,6:18),',stdWSFF',var(ll+(2*NumVarxPPI),6:18),');']);
                u1=[u1,u1bin];u2=[u2,u2bin];u3=[u3,u3bin]; 
                z1=[z1,z1bin];z2=[z2,z2bin];z3=[z3,z3bin]; 
                alpha=[alpha,alphabin]; 
                uref=[uref,urefbin];zref=[zref,zrefbin];
                z0=[z0,z0bin];ucontrol=[ucontrol,ucontrolbin];zcontrol=[zcontrol,zcontrolbin]; 
                varIntern=varIntern+1;
                conditional_uexp_ulog % all should have the same size
            end
            
       end
        
    case 3 % No average instantaneous plots
        sprintf ('\b\b\b\b\b\b\b\bIt will be calculated a profile per every 3 consecutives PPIs')
        MeanType3
        u1=[];u2=[];u3=[]; 
        z1=[];z2=[];z3=[]; 
        uexp=[]; alpha=[]; 
        ulog=[]; uref=[];zref=[];
        z0=[];ucontrol=[];zcontrol=[];
         varIntern=0;
       
        [h,i]=size(Index2Plot);
        
        if h==0
            sprintf('\b\b\b\b\b\b\bThere is no data to plot')
            close(zz)
            return
        end
        NumVarxPPI= numel(Index2Plot(:,1));
        for ll=1:NumVarxPPI
            eval(['[u1bin,u2bin,u3bin, z1bin,z2bin,z3bin, uexpbin, alphabin, ulogbin, urefbin,zrefbin,z0bin,ucontrolbin,zcontrolbin]=ExtractVelocitProfile(ZFF(:,',...
                num2str(Index2Plot(ll,1)),'),ZFF(:,',num2str(Index2Plot(ll,2)),'),ZFF(:,',num2str(Index2Plot(ll,3)),...
            '),WSFF(:,',num2str(Index2Plot(ll,1)),'),WSFF(:,',num2str(Index2Plot(ll,2)),'),WSFF(:,',num2str(Index2Plot(ll,3)),'));']);
        u1=[u1,u1bin];u2=[u2,u2bin];u3=[u3,u3bin]; 
        z1=[z1,z1bin];z2=[z2,z2bin];z3=[z3,z3bin]; 
        alpha=[alpha,alphabin]; 
        uref=[uref,urefbin];zref=[zref,zrefbin];
        z0=[z0,z0bin];ucontrol=[ucontrol,ucontrolbin];zcontrol=[zcontrol,zcontrolbin]; 
         varIntern=varIntern+1; 
        conditional_uexp_ulog
        end
         sprintf ('\b\b\b\b\b\b\b\b\bIt were found %d PPIs',NumVarxPPI)

         case 4
        sprintf('\b\b\b\b\b\b\b\b\bNo average at all')
end

%%%===================================================================
% Plotting option for averaged vertical profiles:
%%================================================================
if Averagetype==4
  else
    for j =1:numel(z0)
%     waitbar(j/numel(z0),zz,'Ploting Vertical Profiles','position',zp);

      figure(200+j);
            ZZ=(z0(j):5:250);
            m=1; n=4; gap=[0.07 0.02]; marg_h=[0.1 0.1]; marg_w=[0.1 0.02];
            args={'EdgeColor','none', 'FaceAlpha',0.5, 'EdgeAlpha', 0};
            colors={'or', '*b', '<k'};
            coloru={'k'};
            coloriu={'r'};
            color2={'y'};
            color3={'r'};
            h=[];
            h4=[];
            for i=1:3;
                hold on
                eval(['h1=plot(u',num2str(i),'(:,',num2str(j),'),z',num2str(i),'(:,',num2str(j),'),colors{i});']); hold on
% %                 eval(['limzz=max(u',num2str(i),'(:,',num2str(j),'));'])
% %                 eval(['limaa=min(u',num2str(i),'(:,',num2str(j),'));'])
                plot([4 16],[80 80],'--k');
                plot([4 16],[39 39],'-k');
                plot([4 16],[121 121],'-k');% % % 
                h=[h,h1];
            end


% %             h1=plot(ucontrol(:,j),zcontrol(:,j),'ro');
% %             h=[h,h1];

            h1=plot(ulog(1:length(ZZ),j),ZZ,'g');
            h=[h,h1];

            h1=plot(uexp(1:length(ZZ),j),ZZ,'r');
            h=[h,h1];

            legend([h],'PPI 1','PPI 2','PPI 3','Log Law','Exp','Location','NorthEastOutside' )
            xlabel('{\itu} [m \cdot s^{-1}]')
            ylabel('{\itz} [m]')
            title('')
            
            if WSref==11
            xlim([4 14]);
            else
               xlim([4 16]);
           end
            ylim([0 280]);
            
    end
                title(gca,strcat('{\itWD} =',{blanks(1)}, num2str(WD),'�, {\itm} =',{blanks(1)},num2str(round(alpha*100)/100)));

end

  
%% 5.2 Plot velocity field & velocity deficit

    waitbar(3/5,zz,'Velocity field','position',zp);
    
 %% Conditional of wake direction alignement;
   
switch Averagetype
    case 1 % Average total
        
         ConditionalVDandWakeAVG1

    sprintf('\b\b\b\b\b\b\b\b\t\two NaN VD restricted')
    sprintf('\b\b\b\b\b\b\b\b\bPPI1\tPPI2\tPPI3')
    sprintf('\b\b\b\b\b\b\b\b\b%d\t\t\t%d\t\t\t%d',numel(Index_PPI1_woNaN),numel(Index_PPI2_woNaN),...
    numel(Index_PPI3_woNaN))
        
    MeanType1
        
        D_Fplot=[1 2 3];
        Diameter_WT=82;
        WTD=Diameter_WT;
        HubHeight=80;

                if UseWDFROM==1
                     angle_rot=mean([...
                                 mean(Hours1(:,7)),...
                                 mean(Hours2(:,7)),...
                                 mean(Hours3(:,7))]); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar,11 WS WT
                else
                    angle_rot=mean([...
                                 mean(Hours1(:,10)),...
                                 mean(Hours2(:,10)),...
                                 mean(Hours3(:,10))]);
                 %  colums in matrix Hours: 7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar,11 WS WT
                end
                
% %                  if WSref==11
            cmin=4;
          cmax=16;
% %             else
% %           cmin=0;
% %           cmax=10;
% %            end
                


        [Xp1_normal,Xp2_normal,Xp3_normal,Yp1_normal,Yp2_normal,Yp3_normal]=RotationFF(angle_rot,meanXFF1,meanXFF2,meanXFF3,meanYFF1,meanYFF2,meanYFF3);

        sprintf('\b\b\b\b\b\b\b\bPPI  El  # sampl WD-LiDAR   WD-MERRA  WD-ME     Yaw        DateIni               DateFin       ')
                for i=1:3;
                    eval(['Elevation=EL(Index_PPI' num2str(i) '_woNaN(1,1));'])
                    eval(['Samples=numel(Index_PPI' num2str(i) '_woNaN);'])
                    eval(['Date1=(datestr(TimeStamp(Index_PPI' num2str(i) '_woNaN(1,1))));'])
                    eval(['Date2=(datestr(TimeStamp(Index_PPI' num2str(i) '_woNaN(end,1))));'])
                    eval(['WDlidar=mean(WD_LiDAR(Index_PPI' num2str(i) '_woNaN));'])
                    eval(['WDmerra=nanmean(selecteddata(:,4));'])
                    eval(['WDME=nanmean(DataME(:,5));'])
                    eval(['Yaw=nanmean(DataME(:,6));'])
                    sprintf('\b\b\b\b\b\b\b\b\b %d  %1.1f    %d    %3.1f      %3.1f     %3.1f   %3.1f   %s    %s    ',...
                        i,round(Elevation*10)/10,Samples,WDlidar,WDmerra,WDME,Yaw,Date1,Date2)
                end

            for kkk=1:3

                 eval(['Xp'  num2str(kkk) '=reshape(Xp' num2str(kkk) '_normal,115,30);']);
                 eval(['Yp'  num2str(kkk) '=reshape(Yp' num2str(kkk) '_normal,115,30);']);
                 eval(['Zp'  num2str(kkk) '=reshape(meanZFF' num2str(kkk) ',115,30);']);
                 eval(['WS'  num2str(kkk) '=reshape(meanWSFF' num2str(kkk) ',115,30);']);

%                 eval(['[ULiDAR80 UextVP VDSMV5 VDSMV6]=wake_VD_GUI(Xp' num2str(kkk) ',Yp' num2str(kkk) ...
%                   ',Zp' num2str(kkk) ',WS' num2str(kkk) ',120,angle_rot,D_Fplot,WTD,uexp,ZZ);']);
%                 eval(['[Y_wake_SMV5,X_wake_SMV5,Y_wake_SMV6,X_wake_SMV6]=wake_tracking_GUI(Xp' num2str(kkk) ...
%                   ',Yp' num2str(kkk) ',Zp' num2str(kkk) ',WS' num2str(kkk) ',60,angle_rot,WTD);']);

               figure(1000);
                    arg={'FaceAlpha'};
                    eval(['surf(Xp' num2str(kkk) '(30:65,:),Yp' num2str(kkk) '(30:65,:),Zp' num2str(kkk) '(30:65,:),WS' num2str(kkk) '(30:65,:),arg{:} ,0.5); hold on; shading flat'])
                    caxis([cmin cmax])
                    
                     
            end

            ll=1;
            DecoracionSURF3PPI

            eval(['Date1=(datestr(TimeStamp(Index_PPI1_woNaN(1,1))));']);
                        eval(['Date2=(datestr(TimeStamp(Index_PPI3_woNaN(end,1))));']);
                        A=sprintf('-----------WD---------------     WT    ');
                        B=sprintf('LiDAR | MERRA |   ME  | Yaw ');
                        C=sprintf('  %3.1f   |  %3.1f    | %3.1f | %3.1f ',AverageWD_LiDAR, AverageWD_MERRA, Hours(ll,8),Hours(ll,9));
                        title({Date1;Date2;A;B;C});
                h=[];
                m=3; r=3; gap=[0.05 0.02]; marg_h=[0.11 0.08]; marg_w=[0.1 0.01];
                a4VD=[7 4 1];
                a4WSMV6=[8 5 2];
                a4WSMV5=[9 6 3];
               
colors1={'sr', 'sb', 'sk'};
colors2={'*r', '*b', '*k'};
hvd=[];

                for kkk=1:3

                        eval(['Xp'  num2str(kkk) '=reshape(Xp' num2str(kkk) '_normal,115,30);']);
                        eval(['Yp'  num2str(kkk) '=reshape(Yp' num2str(kkk) '_normal,115,30);']);
                        eval(['Zp'  num2str(kkk) '=reshape(meanZFF' num2str(kkk) ',115,30);']);
                        eval(['WS'  num2str(kkk) '=reshape(meanWSFF' num2str(kkk) ',115,30);']);
                        eval(['stdWS'  num2str(kkk) '=reshape(stdWSFF' num2str(kkk) ',115,30);']);
% %                         
                        eval(['Iu'  num2str(kkk) '=stdWS'  num2str(kkk) './WS'  num2str(kkk) ';']);



                    eval(['[ULiDAR80 UextVP VDSMV5 VDSMV6]=wake_VD_GUI(Xp' num2str(kkk) ',Yp' num2str(kkk) ...
                        ',Zp' num2str(kkk) ',WS' num2str(kkk) ',80,angle_rot,D_Fplot,WTD,uexp,ZZ);']);
                    eval(['VDSMV5', num2str(kkk) '=VDSMV5;']) 
                    eval(['VDSMV6', num2str(kkk) '=VDSMV6;'])
                    
                     eval(['[ULiDAR80 UextVP VDSMV5c VDSMV6c VDISMV5c VDISMV6c]=wake_VD_cumulatedv1(Xp' num2str(kkk) ',Yp' num2str(kkk) ...
                        ',Zp' num2str(kkk) ',WS' num2str(kkk) ',60,angle_rot,D_Fplot,WTD,uexp,ZZ);']);
                    eval(['VDSMV5c', num2str(kkk) '=VDSMV5c;']) 
                    eval(['VDSMV6c', num2str(kkk) '=VDSMV6c;'])
                   figure(5000)
                  h3=plot(mean(VDSMV5c(:,:,2))'*-1,sqrt(VDISMV5c.^2),colors1{kkk}); hold on
                  hvd=[hvd,h3];
                  h3=plot(mean(VDSMV6c(:,:,2))'*-1,sqrt(VDISMV6c.^2),colors2{kkk})
                  hvd=[hvd,h3];
                  xlabel('\itx_{WD}/D'); ylabel('u_{hub}-u_{min}/u_{hub}')
                    ylim([0 1])
                    eval(['[Y_wake_SMV5,X_wake_SMV5,Y_wake_SMV6,X_wake_SMV6]=wake_tracking_GUI(Xp' num2str(kkk) ...
                        ',Yp' num2str(kkk) ',Zp' num2str(kkk) ',WS' num2str(kkk) ',60,angle_rot,WTD);']);
                    
                    
                    eval(['VDSMV5', num2str(kkk) '=VDSMV5;']) 
                    eval(['VDSMV6', num2str(kkk) '=VDSMV6;'])
                    
                    Xcoord_WT=[-1272 -1300 -1438 -1402];
                    Ycoord_WT=[70 -280 -550 -863];
                    X_WT_normal=Xcoord_WT*cosd(angle_rot)-Ycoord_WT*sind(angle_rot);
                    Y_WT_normal= Ycoord_WT*cosd(angle_rot)+ Xcoord_WT*sind(angle_rot);
                    
                    eval(['X_WT_normal', num2str(kkk) '=X_WT_normal;']) 
                    eval(['Y_WT_normal', num2str(kkk) '=Y_WT_normal;'])
                    
%                     var={strcat('Xp', num2str(kkk)),strcat('Yp', num2str(kkk)),strcat('WS', num2str(kkk))...
%                         ,strcat('Iu', num2str(kkk)),strcat('X_WT_normal', num2str(kkk)),strcat('Y_WT_normal', num2str(kkk))...
%                         ,strcat('VDSMV5', num2str(kkk)),strcat('VDSMV6', num2str(kkk))};
%                     name=strcat('alpha', num2str(kkk),'case6bis.mat');
%                     pathname=fullfile('C:\EOLINEPRJ\Docs\Presentation 4 julliet\testfigs', name);
%                  save(pathname, var{:});
                 
                      figure(1001);
                      plotPPIsWake
%                     
                      figure(1002);
                      plotPPIsSTD;
                    
                end
                      
               

                AXESproperties
                titlePPI1=['\alpha = 2.5� Average ' num2str(numel(Index_PPI1_woNaN)) ' samples'];
                titlePPI2=['\alpha = 3.8� Average ' num2str(numel(Index_PPI2_woNaN)) ' amples'];
                titlePPI3=['\alpha = 5.2� Average ' num2str(numel(Index_PPI3_woNaN)) ' samples'];

                set(get(h(1), 'title'),'string',titlePPI1);
                set(get(h(4), 'title'),'string',titlePPI2);
                set(get(h(7), 'title'),'string',titlePPI3);
                
                figure(5000);
                 xd=[1:0.1:7];
                yd=0.56*xd.^(-0.57);
                h=plot(xd,yd,'g');plot(xd+3.05,yd,'g');
                hvd=[hvd,h];
               legend(hvd,'SMV5 \alpha 2.5�','SMV6 \alpha 2.5�',...
                   'SMV5 \alpha 3.8�','SMV6 \alpha 3.8�','SMV5 \alpha 5.2�','SMV6 \alpha 5.2�','VD = 0.56x/d^{-0.57}')
 
   case 2 % average for minutes
       ConditionalVDandWakeAVG2
        D_Fplot=[1 2 3 ];
        Diameter_WT=82;
        WTD=Diameter_WT;
        HubHeight=80; 
        NumVarxPPI= numel(var(:,1))/3;
        h1=[];
        Hours1=zeros(ll,4);
        MeanWDLidarHour=[];


       for iteration=1:numel(HourswithVDcentered)
            ll=HourswithVDcentered(iteration);
             for i=1:numel(Bins4AVERAGE)-1
            cadena={'\b\b\b\b\b\b\b\bAverage from %d:%d to %d:%d   '};
            eval(['sprintf(cadena{:},LimHH' num2str(i-1) '(ll,1),LimHH' num2str(i-1) '(ll,2),LimHH' num2str(i) '(ll,1),LimHH' num2str(i) '(ll,2))']);
            sprintf('\b\b\b\b\b\b\b\b\b\b\b of the %d / %d / %d', Hours(ll,3),Hours(ll,2),Hours(ll,1))
            sprintf('\b\b\b\b\b\b\b\bPPI  El  # sampl WD-LiDAR   WD-MERRA  WD-ME     Yaw        DateIni               DateFin       ')
            
            [s,t]=find(DataME(:,1)== Hours(ll,2)); %filter month
            [u,v]=find(DataME(s,2) == Hours(ll,3)); %filter day
            
            eval(['L1=LimHH' num2str(i-1) '(ll,1)*60*60+LimHH' num2str(i-1) '(ll,2)*60;']);
            eval(['L2=LimHH' num2str(i) '(ll,1)*60*60+LimHH' num2str(i) '(ll,2)*60;']);
            [b,c]=find(L1<=DataME(s(u),4) & L2> DataME(s(u),4)) ;%filter hourly limits

            eval(['WDME=nanmean(DataME(s(u(b)),5));'])
            eval(['Yaw=nanmean(DataME(s(u(b)),6));'])

            for i=1:3;
            eval(['Elevation=EL(Index_PPI' num2str(i) '_woNaN(' var(ll+NumVarxPPI*(i-1),:) '(1,1)));'])
            eval(['Samples=numel(Index_PPI' num2str(i) '_woNaN(' var(ll+NumVarxPPI*(i-1),:) '));'])
            eval(['Date1=(datestr(TimeStamp(Index_PPI' num2str(i) '_woNaN(' var(ll+NumVarxPPI*(i-1),:) '(1,1)))));'])
            eval(['Date2=(datestr(TimeStamp(Index_PPI' num2str(i) '_woNaN(' var(ll+NumVarxPPI*(i-1),:) '(1,end)))));'])
            eval(['WDlidar=nanmean(WD_LiDAR(Index_PPI' num2str(i) '_woNaN(' var(ll+NumVarxPPI*(i-1),:) ')));'])
            eval(['WDmerra=nanmean(selecteddata(ll,4));'])
          
            sprintf('\b\b\b\b\b\b\b\b\b %d  %1.1f    %d    %3.1f      %3.1f     %3.1f   %3.1f   %s    %s    ',...
                    i,round(Elevation*10)/10,Samples,WDlidar,WDmerra,WDME,Yaw,Date1,Date2)
            end

         end
        
        end
        
     

       
        for iteration=1:numel(HourswithVDcentered)
            
                waitbar(1/numel(HourswithVDcentered),zz,'Velocity field','position',zp);
            ll=HourswithVDcentered(iteration);

                if UseWDFROM==1
                     angle_rot=Hours(ll,7); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar,11 WS WT
                else
                    angle_rot=Hours(ll,10); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar,11 WS WT
                end
                
                
        % % % % %  Crossing position of the PPI
            if iteration==1
                PlotCrossingplanesRearview
            end
            
            % % % Figure PPI mean Flow field 3D

                for i=1:3
                    eval(['meanXFF' num2str(i) '=meanXFF' var(ll+(NumVarxPPI*(i-1)),6:end) ';']);
                    eval(['meanYFF' num2str(i) '=meanYFF' var(ll+(NumVarxPPI*(i-1)),6:end) ';']);
                    eval(['meanZFF' num2str(i) '=meanZFF' var(ll+(NumVarxPPI*(i-1)),6:end) ';']);
                    eval(['meanWSFF' num2str(i) '=meanWSFF' var(ll+(NumVarxPPI*(i-1)),6:end) ';']);
                end

                    [Xp1_normal,Xp2_normal,Xp3_normal,Yp1_normal,Yp2_normal,Yp3_normal]=...
                        RotationFF(angle_rot,meanXFF1,meanXFF2,meanXFF3,meanYFF1,meanYFF2,meanYFF3);
       
                     for kkk=1:3
                       eval(['Xp'  num2str(kkk) '=reshape(Xp' num2str(kkk) '_normal,115,30);']);
                       eval(['Yp'  num2str(kkk) '=reshape(Yp' num2str(kkk) '_normal,115,30);']);
                       eval(['Zp'  num2str(kkk) '=reshape(meanZFF' num2str(kkk) ',115,30);']);
                       eval(['WS'  num2str(kkk) '=reshape(meanWSFF' num2str(kkk) ',115,30);']);

                        eval(['[ULiDAR80 UextVP VDSMV5 VDSMV6]=wake_VD_GUI(Xp' num2str(kkk) ',Yp' num2str(kkk) ...
                            ',Zp' num2str(kkk) ',WS' num2str(kkk) ',120,angle_rot,D_Fplot,WTD,uexp,ZZ);']);
                        eval(['[Y_wake_SMV5,X_wake_SMV5,Y_wake_SMV6,X_wake_SMV6]=wake_tracking_GUI(Xp' num2str(kkk) ...
                            ',Yp' num2str(kkk) ',Zp' num2str(kkk) ',WS' num2str(kkk) ',60,angle_rot,WTD);']);
                          figure(500+iteration);
                        eval(['surf(Xp' num2str(kkk) '(30:65,:),Yp' num2str(kkk) '(30:65,:),Zp' num2str(kkk) '(30:65,:),WS' num2str(kkk) '(30:65,:),args{:}); hold on;'])
                        caxis([2 18])
                        end

                        DecoracionSURF3PPI 

                        eval(['Date1=(datestr(TimeStamp(Index_PPI1_woNaN(' var(ll,:) '(1,1)))));']);
                        eval(['Date2=(datestr(TimeStamp(Index_PPI3_woNaN(' var(ll+NumVarxPPI*2,:) '(1,end)))));']);
                        A=sprintf('-----------WD---------------     WT    ');
                        B=sprintf('LiDAR | MERRA |   ME  | Yaw ');
                        C=sprintf('  %3.1f   |  %3.1f    | %3.1f | %3.1f ',Hours(ll,10), Hours(ll,7),Hours(ll,8),Hours(ll,9));
                        title({Date1;Date2;A;B;C});

        % % % % % %  2D Planes and VD
            
            
            cmin=2;
                 cmax=16;
                 h=[];
                 m=3; r=3; gap=[0.05 0.02]; marg_h=[0.12 0.08]; marg_w=[0.12 0.01];
                 args={'EdgeColor','none', 'FaceAlpha',0.5, 'EdgeAlpha', 0};
                a4VD=[7 4 1];  a4WSMV6=[8 5 2]; a4WSMV5=[9 6 3]; swp=[];
            for kkk=1:3
                      figure(2000+iteration);
                    eval(['Xp'  num2str(kkk) '=reshape(Xp' num2str(kkk) '_normal,115,30);']);
                    eval(['Yp'  num2str(kkk) '=reshape(Yp' num2str(kkk) '_normal,115,30);']);
                    eval(['Zp'  num2str(kkk) '=reshape(meanZFF' num2str(kkk) ',115,30);']);
                    eval(['WS'  num2str(kkk) '=reshape(meanWSFF' num2str(kkk) ',115,30);']);

                eval(['[ULiDAR80 UextVP VDSMV5 VDSMV6]=wake_VD_GUI(Xp' num2str(kkk) ',Yp' num2str(kkk) ...
                    ',Zp' num2str(kkk) ',WS' num2str(kkk) ',120,angle_rot,D_Fplot,WTD,uexp,ZZ);']);
                eval(['[Y_wake_SMV5,X_wake_SMV5,Y_wake_SMV6,X_wake_SMV6]=wake_tracking_GUI(Xp' num2str(kkk) ...
                    ',Yp' num2str(kkk) ',Zp' num2str(kkk) ',WS' num2str(kkk) ',60,angle_rot,WTD);']);
                plotPPIsWake
            end
                AXESproperties
      
                titlePPI1=['\alpha = 2.5�, Average ' num2str(numel(eval(var(ll,:)))) ' samples'];
                titlePPI2=['\alpha = 3.8� Average ' num2str(numel(eval(var(ll+NumVarxPPI,:)))) ' samples'];
                titlePPI3=['\alpha = 5.2� Average ' num2str(numel(eval(var(ll+NumVarxPPI*2,:)))) ' samples'];
                set(get(h(1), 'title'),'string',titlePPI1);
                set(get(h(4), 'title'),'string',titlePPI2);
                set(get(h(7), 'title'),'string',titlePPI3);

        end
        
        
    case 3 % No average instantaneous and consecutive plots
        
        D_Fplot=[1 2 3];
        Diameter_WT=82;
        WTD=Diameter_WT;
        HubHeight=82; 
        NumVarxPPI= numel(Index2Plot(:,1));
        h1=[];
        VDstatisticsSMV5=zeros(25,3,4,NumVarxPPI);
        VDstatisticsSMV6=zeros(25,3,4,NumVarxPPI);
        Wakestatistics=NaN(44,4,3,NumVarxPPI);
        aglexPPI=nan(NumVarxPPI,1);
        
        Hours1=[];
        W=datestr(TimeStamp(Index2Plot(:,1)));
        W1=datestr(selecteddata(:,1));
        W2=selecteddata(:,4);
        for i=1: numel(W1(:,1)) %
            for j=1: numel(W(:,1)) %
            a=strcmp(W(j,1:15),W1(i,1:15)); %
                if a==1
                 Hours1=[Hours1;W2(i)];
                end
            end
        end
                [m,p]=size(Hours1);
        Hours=zeros(m,10);
        Hours(:,7)=Hours1;
        Hours(:,10)=nanmean(WD_LiDAR(Index2Plot),2);
if UseWDFROM==1
     angle_rot=Hours(:,7); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar
else
    angle_rot=Hours(:,10); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar
end

        for ll=1:NumVarxPPI
                            waitbar(ll/NumVarxPPI,zz,'Velocity field','position',zp);

     
            if UseWDFROM==1
            angle_rot=Hours(ll,7); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar
            else
            angle_rot=Hours(ll,10); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar
            end
            
                    % % % % Plot overview means and std
             m=1; n=3; gap=[0.07 0.02]; marg_h=[0.1 0.1]; marg_w=[0.1 0.1];
             args={'EdgeColor','none', 'FaceAlpha',0.5, 'EdgeAlpha', 0};


             cmin=2;
             cmax=16;

     
           for i=1:3
            eval(['meanXFF' num2str(i) '=XFF(:,' num2str(Index2Plot(ll,i)) ');']);
            eval(['meanYFF' num2str(i) '=YFF(:,' num2str(Index2Plot(ll,i)) ');']);
            eval(['meanZFF' num2str(i) '=ZFF(:,' num2str(Index2Plot(ll,i)) ');']);
            eval(['meanWSFF' num2str(i) '=WSFF(:,' num2str(Index2Plot(ll,i)) ');']);
          end


[Xp1_normal,Xp2_normal,Xp3_normal,Yp1_normal,Yp2_normal,Yp3_normal]=RotationFF(angle_rot,meanXFF1,meanXFF2,meanXFF3,meanYFF1,meanYFF2,meanYFF3);
    
        h=[];
m=3; r=3; gap=[0.05 0.02]; marg_h=[0.08 0.08]; marg_w=[0.06 0.01];
a4VD=[7 4 1];
a4WSMV6=[8 5 2];
a4WSMV5=[9 6 3];
            for kkk=1:3
                  figure(gcf+1);
                eval(['Xp'  num2str(kkk) '=reshape(Xp' num2str(kkk) '_normal,115,30);']);
                eval(['Yp'  num2str(kkk) '=reshape(Yp' num2str(kkk) '_normal,115,30);']);
                eval(['Zp'  num2str(kkk) '=reshape(meanZFF' num2str(kkk) ',115,30);']);
                eval(['WS'  num2str(kkk) '=reshape(meanWSFF' num2str(kkk) ',115,30);']);

                
            eval(['[ULiDAR80 UextVP VDSMV5 VDSMV6]=wake_VD_GUI(Xp' num2str(kkk) ',Yp' num2str(kkk) ...
                ',Zp' num2str(kkk) ',WS' num2str(kkk) ',120,angle_rot,D_Fplot,WTD,uexp,ZZ);']);
            eval(['[Y_wake_SMV5,X_wake_SMV5,Y_wake_SMV6,X_wake_SMV6]=wake_tracking_GUI(Xp' num2str(kkk) ...
                ',Yp' num2str(kkk) ',Zp' num2str(kkk) ',WS' num2str(kkk) ',60,angle_rot,WTD);']);
         plotPPIsWake
         [q,p]=size(X_wake_SMV6');
         Wakestatistics(1:q,1,kkk,ll)=X_wake_SMV6';
         [q,p]=size(Y_wake_SMV6');
         Wakestatistics(1:q,2,kkk,ll)=Y_wake_SMV6';
        [q,p]=size(X_wake_SMV5');
         Wakestatistics(1:q,3,kkk,ll)=X_wake_SMV5';
        [q,p]=size(Y_wake_SMV5');
        Wakestatistics(1:q,4,kkk,ll)=Y_wake_SMV5';
           
              end

    
     AXESproperties
      titlePPI1=['\alpha = 2.5� '  datestr(TimeStamp(Index2Plot(ll,1))) ];
        titlePPI2=['\alpha = 3.8�'  datestr(TimeStamp(Index2Plot(ll,2)))];
        titlePPI3=['\alpha = 5.2�'  datestr(TimeStamp(Index2Plot(ll,3)))];
        set(get(h(1), 'title'),'string',titlePPI1);
        set(get(h(4), 'title'),'string',titlePPI2);
        set(get(h(7), 'title'),'string',titlePPI3);
        [m,p,q]=size(VDSMV5);
                VDstatisticsSMV5(1:m,1:p,1:q,ll)=VDSMV5;
                [m,p,q]=size(VDSMV6);
                VDstatisticsSMV6(1:m,1:p,1:q,ll)=VDSMV6;

        end
        
     
        
        case 4 % No average instantaneous plots
        D_Fplot=[1 2 3];
        Diameter_WT=82;
        WTD=Diameter_WT;
        HubHeight=82; 
        NumPPIs= numel(Index_PPI1_woNaN)+numel(Index_PPI2_woNaN)+numel(Index_PPI3_woNaN);
                NamePPIs= [Index_PPI1_woNaN;Index_PPI2_woNaN;Index_PPI3_woNaN];

        h1=[];
        VDstatisticsSMV5=zeros(25,3,4,NumPPIs);
        VDstatisticsSMV6=zeros(25,3,4,NumPPIs);
        Wakestatistics=NaN(44,4,3,NumPPIs);
        aglexPPI=nan(NumPPIs,1);
        
        Hours1=[];
        W=datestr(TimeStamp(NamePPIs(:,1)));
        W1=datestr(selecteddata(:,1));
        W2=selecteddata(:,4);
        for i=1: numel(W1(:,1)) %
            for j=1: numel(W(:,1)) %
            a=strcmp(W(j,1:15),W1(i,1:15)); %
                if a==1
                 Hours1=[Hours1;W2(i)];
                end
            end
        end
                [m,p]=size(Hours1);
        Hours=zeros(m,10);
        Hours(:,7)=Hours1;
        Hours(:,10)=nanmean(WD_LiDAR(NamePPIs),2);
if UseWDFROM==1
     angle_rot=Hours(:,7); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar
else
    angle_rot=Hours(:,10); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar
end

        for ll=1:NumPPIs
     
                 
            eval(['meanXFF' num2str(ll) '=XFF(:,' num2str(NamePPIs(ll)) ');']);
            eval(['meanYFF' num2str(ll) '=YFF(:,' num2str(NamePPIs(ll)) ');']);
            eval(['meanZFF' num2str(ll) '=ZFF(:,' num2str(NamePPIs(ll)) ');']);
            eval(['meanWSFF' num2str(ll) '=WSFF(:,' num2str(NamePPIs(ll)) ');']);


            eval(['Xp' num2str(ll) '_normal=meanXFF' num2str(ll) '*cosd(' num2str(angle_rot(ll)) ')'...
                '-' 'meanYFF' num2str(ll) '*sind(' num2str(angle_rot(ll)) ');'] );
    eval(['Yp' num2str(ll) '_normal=' 'meanYFF' num2str(ll) '*cosd(' num2str(angle_rot(ll)) ')'...
        '+' 'meanXFF' num2str(ll) '*sind(' num2str(angle_rot(ll)) ');'] );

    
% %         h=[];
% % m=3; r=3; gap=[0.05 0.02]; marg_h=[0.08 0.08]; marg_w=[0.06 0.01];
% % a4VD=[7 4 1];
% % a4WSMV6=[8 5 2];
% % a4WSMV5=[9 6 3];
% %             for kkk=1:3
%                 figure(300+ll)
                eval(['Xp'  num2str(ll) '=reshape(Xp' num2str(ll) '_normal,115,30);']);
                eval(['Yp'  num2str(ll) '=reshape(Yp' num2str(ll) '_normal,115,30);']);
                eval(['Zp'  num2str(ll) '=reshape(meanZFF' num2str(ll) ',115,30);']);
                eval(['WS'  num2str(ll) '=reshape(meanWSFF' num2str(ll) ',115,30);']);

                
% %             eval(['[ULiDAR80 UextVP VDSMV5 VDSMV6]=wake_VD_GUI(Xp' num2str(ll) ',Yp' num2str(ll) ...
% %                 ',Zp' num2str(ll) ',WS' num2str(ll) ',120,angle_rot,D_Fplot,WTD,uexp,ZZ);']);
            eval(['[Y_wake_SMV5,X_wake_SMV5,Y_wake_SMV6,X_wake_SMV6]=wake_tracking_GUI(Xp' num2str(ll) ...
                ',Yp' num2str(ll) ',Zp' num2str(ll) ',WS' num2str(ll) ',60,' num2str(angle_rot(ll)) ',WTD);']);
%          plotPPIsWake
% % figure(ll);
% % eval(['pcolor(Xp' num2str(ll) '(30:75,:),Yp' num2str(ll) '(30:75,:)' ',WS' num2str(ll) '(30:75,:)); shading interp'])
% %    caxis([cmin, cmax]); axis equal
        if ll<=numel(Index_PPI1_woNaN)
        kkk=1;
        elseif ll> numel(Index_PPI1_woNaN) && ll<=numel(Index_PPI1_woNaN)+numel(Index_PPI2_woNaN)
            kkk=2;
        else
            kkk=3;
        end
    
         [q,p]=size(X_wake_SMV6');
         Wakestatistics(1:q,1,kkk,ll)=X_wake_SMV6';
         [q,p]=size(Y_wake_SMV6');
         Wakestatistics(1:q,2,kkk,ll)=Y_wake_SMV6';
        [q,p]=size(X_wake_SMV5');
         Wakestatistics(1:q,3,kkk,ll)=X_wake_SMV5';
        [q,p]=size(Y_wake_SMV5');
        Wakestatistics(1:q,4,kkk,ll)=Y_wake_SMV5';
           


        end
        
            
            
            
        % PPIS instantaneos no continuos
        
        
        

      
end

%%  5.2 Wake statistics

%                 waitbar(4/5,zz,'Wake statistics','position',zp);

if Averagetype==1
    
    Maxitems=max([numel(Index_PPI1_woNaN),numel(Index_PPI2_woNaN),numel(Index_PPI3_woNaN)]);
    angletmp=NaN(Maxitems,3);
    
        if UseWDFROM==1
                      for i=1:3
                      eval(['angletmp1=Hours',num2str(i),'(HourswithVDcentered',num2str(i),',7);']);
                      [r,s]=size(angletmp1);
                      angletmp(1:r,i)=angletmp1;
                      end
                          angle_rot=(angletmp);
           else
                 for i=1:3
                     eval(['angletmp1=Hours',num2str(i),'(:,10);']);
                     [r,s]=size(angletmp1);
                     angletmp(1:r,i)=angletmp1;
                 end
                   angle_rot=(angletmp);
                     %  colums in matrix Hours: 7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar,11 WS WT
        end
          PLOTWakestatisticsAVG1

else 
    if UseWDFROM==1
     angle_rot=Hours(HourswithVDcentered,7); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar
    else
    angle_rot=Hours(HourswithVDcentered,10); %  7 MERRA, 8 ME, 9 Yaw ME,10 WD Lidar
    end
PLOTWakestatistics
end
    


close (zz)
% close all