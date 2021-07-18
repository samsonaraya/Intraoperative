% % <summary>
% % Task 1.0: Check data set
% % </summary>
% % <remarks>
% %  Author:            SG
% %                     (C) Heidelberg University
% %  Project name:      Master Thesis : Seed train positions (orientation and trajectories) of
% %                     the pre-plan and the final intra-operative implant using the dicom files:
% %
% %  Date:              2021-04-01
% % </remarks>
% % % % % % % % % % % % % % % % % % % %


%% file
% switch lower( getenv( 'COMPUTERNAME' ) )
%     case 'computername' % your computer name
%         path_proj = 'C:\----'; % your folder location
%     case 'desktop-ae86p3r'
%         path_proj = 'C:\Users\Samson\Documents\Data';
%     otherwise
%         return
% end



clc, close all

projectdir = 'C:\Users\Samson\Documents\Data';
%%

D = "C:\Users\Samson\Desktop\Thesis\Data\Mat files\dicom-dict-iotp.txt";
seed_location_preplan = dicominfo('C:\Users\Samson\Documents\Data\Pat1_Preplan\PL001.dcm','dictionary',D);
seeds = struct2array(seed_location_preplan.ApplicationSetupSequence);
tplan = cell(length(seeds),3);

for i = 1:length(seeds)
    tplan{i,1} = seeds(i).ApplicationSetupNumber;
    tplan{i,2} = seeds(i).ChannelSequence.Item_1.BrachyControlPointSequence.Item_1.ControlPoint3DPosition;
    tplan{i,3} = seeds(i).ChannelSequence.Item_1.BrachyControlPointSequence.Item_1.ControlPointOrientation;
end

seed_location_iotp = dicominfo('C:\Users\Samson\Documents\Data\Pat1_IntraoperativeTrementPlan\PL001.dcm','dictionary',D);
seeds = struct2array(seed_location_iotp.ApplicationSetupSequence);
tiotp = cell(length(seeds),3);

for i = 1:length(seeds)
    tiotp{i,1} = seeds(i).ApplicationSetupNumber;
    tiotp{i,2} = seeds(i).ChannelSequence.Item_1.BrachyControlPointSequence.Item_1.ControlPoint3DPosition;
    tiotp{i,3} = seeds(i).ChannelSequence.Item_1.BrachyControlPointSequence.Item_1.ControlPointOrientation;
end

dose = squeeze(dicomread('C:\Users\Samson\Documents\Data\Pat1_IntraoperativeTrementPlan\DO001.dcm'));
structure_set = dicominfo('C:\Users\Samson\Documents\Data\Pat1_IntraoperativeTrementPlan\SS001.dcm');

mag_centroids = @(c1)sqrt(sum(c1.^2));
mag_Dif = @(c1,c2)sqrt(sum((c1-c2).^2)); % in mm
ang_Mag =  @(v1,v2) acos(dot(v1,v2)/(mag_centroids(v1)*mag_centroids(v2))); % in degrees

% tplan{i,2},tiotp{i,2}

dTrue = zeros(length(tplan),4);
for i = 1:length(tplan)
    dI = zeros(1,length(tiotp));
    for j = 1:length(tiotp)
        dI(j) = mag_Dif(tplan{i,2},tiotp{j,2});
    end
    [V,J] = min(dI); % select the minimum distance to avoid overlap
    
    dTrue(i,:) = [tplan{i,1},tiotp{J,1},V,ang_Mag(tplan{i,3},tiotp{J,3})];
end




%% 3D plot to visualize seed movement
% preplan first

figure
hold on

for i = 1:length(tplan)
    scatter3(tplan{i,2}(1),tplan{i,2}(2),tplan{i,2}(3),'g')
end

% Iotp Second

for i = 1:length(tiotp)
    scatter3(tiotp{i,2}(1),tiotp{i,2}(2),tiotp{i,2}(3),'r+')
end

for i = 1:length(dTrue)
    plot3([tplan{dTrue(i,1),2}(1),tiotp{dTrue(i,2),2}(1)],...
        [tplan{dTrue(i,1),2}(2),tiotp{dTrue(i,2),2}(2)],...
        [tplan{dTrue(i,1),2}(3),tiotp{dTrue(i,2),2}(3)],'k-')
end

grid minor



%% to visualize seed distribution

% dicomFiles = dir( fullfile(projectdir, '*.dcm' ));
% y = length(dicomFiles);
%
%
% [V,spatial,dim] = dicomreadVolume(fullfile('C:\Users\Samson\Documents\Data\0408\'));
% V = squeeze(V);
%
% intensity = [0 20 40 120 220 1024];
% alpha = [0 0 0.15 0.3 0.38 0.5];
% color = ([0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255])/ 255;
% queryPoints = linspace(min(intensity),max(intensity),256);
% alphamap = interp1(intensity,alpha,queryPoints)';
% colormap = interp1(intensity,color,queryPoints);
% ViewPnl = uipanel(figure,'Title','4-D Dicom Volume');
% volshow(V,'Colormap',colormap,'Alphamap',alphamap,'Parent',ViewPnl);