% % <summary>
% % Task 1.0: Check data set
% % </summary>
% % <remarks>
% %  Author:            SG
% %                     (C) Heidelberg University
% %  Project name:      Seed train positions (orientation and trajectories) of
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



clc, clear all

% projectdir = 'C:\Users\Samson\Documents\Data';
%%

D = "C:\Users\Data\Mat files\dicom-dict-iotp.txt";
seed_location_preplan = dicominfo('C:\Users\Data\Pat1_Preplan\PL001.dcm','dictionary',D);
seeds = struct2array(seed_location_preplan.ApplicationSetupSequence);
tplan = cell(length(seeds),3);

for i = 1:length(seeds)
    tplan{i,1} = seeds(i).ApplicationSetupNumber;
    tplan{i,2} = seeds(i).ChannelSequence.Item_1.BrachyControlPointSequence.Item_1.ControlPoint3DPosition;
    tplan{i,3} = seeds(i).ChannelSequence.Item_1.BrachyControlPointSequence.Item_1.ControlPointOrientation;
end

seed_location_iotp = dicominfo('C:\Users\Data\Pat1_IntraoperativeTrementPlan\PL001.dcm','dictionary',D);
seeds = struct2array(seed_location_iotp.ApplicationSetupSequence);
tiotp = cell(length(seeds),3);

for i = 1:length(seeds)
    tiotp{i,1} = seeds(i).ApplicationSetupNumber;
    tiotp{i,2} = seeds(i).ChannelSequence.Item_1.BrachyControlPointSequence.Item_1.ControlPoint3DPosition;
    tiotp{i,3} = seeds(i).ChannelSequence.Item_1.BrachyControlPointSequence.Item_1.ControlPointOrientation;
end

dose = squeeze(dicomread('C:\Users\Data\Pat1_IntraoperativeTrementPlan\DO001.dcm'));
dose = squeeze(dicomread('C:\Users\Data\Pat1_Preplan\DO001.dcm'));


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
%%
% Iotp Second

for i = 1:length(tiotp)
    scatter3(tiotp{i,2}(1),tiotp{i,2}(2),tiotp{i,2}(3),'r+')
end
%%
for i = 1:length(dTrue)
    plot3([tplan{dTrue(i,1),2}(1),tiotp{dTrue(i,2),2}(1)],...
        [tplan{dTrue(i,1),2}(2),tiotp{dTrue(i,2),2}(2)],...
        [tplan{dTrue(i,1),2}(3),tiotp{dTrue(i,2),2}(3)],'k-')
end

p2 = scatter3(tiotp{i,2}(1),tiotp{i,2}(2),tiotp{i,2}(3),'r+','DisplayName', 'Intraoperative seed location');
hold on;
p1 = scatter3(tplan{i,2}(1),tplan{i,2}(2),tplan{i,2}(3),'g','DisplayName', 'Preplan seed location');
hold on;
p3 = plot3([tplan{dTrue(i,1),2}(1),tiotp{dTrue(i,2),2}(1)],...
        [tplan{dTrue(i,1),2}(2),tiotp{dTrue(i,2),2}(2)],...
        [tplan{dTrue(i,1),2}(3),tiotp{dTrue(i,2),2}(3)],'k-','DisplayName', 'Difference (mm)')
legend([p1,p2,p3])
grid minor
set(gca, 'YDir','reverse')


%%%% Break here to Get the result of seed movement 


%% Preplan 1 G(r)
figure
x = [0.1 0.15 0.25 0.5 0.75 1.00 1.5 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]*10;
y = [0.544 0.7 0.876 0.999 1.013 1.00 0.943 0.864 0.698 0.546 0.420 0.318 0.239 0.178 0.133 0.0980];

plot(x,y,'--')
hold on
doseI = dicominfo('C:\Users\Samson\Desktop\Thesis\Data\Pat1_Preplan\DO001.dcm');
dose = squeeze(dicomread('C:\Users\Samson\Desktop\Thesis\Data\Pat1_Preplan\DO001.dcm'));

doseRes = 0.122751/doseI.DoseGridScaling;
% dose_z = [0:-5:-65];
dose_z = doseI.GridFrameOffsetVector';
% dose_r = [-88.6:1:-9.6];
dose_r = [doseI.ImagePositionPatient(2):1:doseI.ImagePositionPatient(2)+79];
% dose_c = [-40.5:1:38.5];
dose_c = [doseI.ImagePositionPatient(1):1:doseI.ImagePositionPatient(1)+79];
y_all = [];
for i = 1:length(tplan)
    
    x = tplan{i,2}(1); y = tplan{i,2}(2); z = tplan{i,2}(3);
    disp([x,y,z])
    
    % find the closest z position
    slice = find(abs(dose_z-z) == min(abs(dose_z-z)));
    slice = slice(1); % in case it locates to middle of two slice, we have to select just one from either
    % find the point on z position plan
    r = find(abs(dose_r-y) == min(abs(dose_r-y)));
    c = find(abs(dose_c-x) == min(abs(dose_c-x)));
    disp([c,r,slice])
    
    npoint = 5; % select another n point from center
    
    disp(flip(double(dose(r,c:c+npoint,slice))))
    yD = flip(double(dose(r,c:c+npoint,slice))); % Coordinates depend on the Dose Map, chosen manualy
    %     xD = doseRes/2:doseRes:doseRes*(length(yD));
    xD = [];
    for j=0:npoint
        dista = ((z-dose_z(slice))^2+(x-dose_c(c)+j)^2+(y-dose_r(r))^2)^(0.5);
        disp(dista)
        xD = [xD,dista];
    end
    disp(xD)
    
    %     plot(xD/100,yD/max(yD))
    %     plot(xD,yD/max(yD))
    plot(xD,yD*doseI.DoseGridScaling/max(yD*doseI.DoseGridScaling))
    y_all = [y_all;yD*doseI.DoseGridScaling];
    hold on
end


xlabel('r(mm)')
ylabel('G(r)')
title('Preplan_1 total seeds')


yDm = mean(y_all,1);
figure
plot(xD,yDm/max(yDm))
hold on
x = [0.1 0.15 0.25 0.5 0.75 1.00 1.5 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]*10;
y = [0.544 0.7 0.876 0.999 1.013 1.00 0.943 0.864 0.698 0.546 0.420 0.318 0.239 0.178 0.133 0.0980];

plot(x,y,'--')
xlabel('r(mm)')
ylabel('G(r)')
title('Preplan_1 mean')
grid on

%% IntraoperativeTrementPlan 1 G(r)
figure
x = [0.1 0.15 0.25 0.5 0.75 1.00 1.5 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]*10;
y = [0.544 0.7 0.876 0.999 1.013 1.00 0.943 0.864 0.698 0.546 0.420 0.318 0.239 0.178 0.133 0.0980];

plot(x,y,'--')
hold on
doseI = dicominfo('C:\Users\Data\Pat1_IntraoperativeTrementPlan\DO001.dcm');
dose = squeeze(dicomread('C:\Users\Data\Pat1_IntraoperativeTrementPlan\DO001.dcm'));

doseRes = 0.122751/doseI.DoseGridScaling;
% dose_z = [0:-5:-65];
dose_z = doseI.GridFrameOffsetVector';
% dose_r = [-88.6:1:-9.6];
dose_r = [doseI.ImagePositionPatient(2):1:doseI.ImagePositionPatient(2)+79];
% dose_c = [-40.5:1:38.5];
dose_c = [doseI.ImagePositionPatient(1):1:doseI.ImagePositionPatient(1)+79];
y_all = [];


for i = 1:length(tiotp)
    
    x = tiotp{i,2}(1); y = tiotp{i,2}(2); z = tiotp{i,2}(3);
    disp([x,y,z])
    
    %find closest z position
    slice = find(abs(dose_z-z) == min(abs(dose_z-z)));
    slice = slice(1);
    %find the point on z position plan
    r = find(abs(dose_r-y) == min(abs(dose_r-y)));
    c = find(abs(dose_c-x) == min(abs(dose_c-x)));
    disp([c,r,slice])
    
    npoint = 5; % select another n point from center
    
    disp(flip(double(dose(r,c:c+npoint,slice))))
    yD = flip(double(dose(r,c:c+npoint,slice)));
    %     xD = doseRes/2:doseRes:doseRes*(length(yD));
    xD = [];
    for j=0:npoint
        dista = ((z-dose_z(slice))^2+(x-dose_c(c)+j)^2+(y-dose_r(r))^2)^(0.5);
        disp(dista)
        xD = [xD,dista];
    end
    disp(xD)
    
    %     plot(xD/100,yD/max(yD))
    %     plot(xD,yD/max(yD))
    plot(xD,yD*doseI.DoseGridScaling/max(yD*doseI.DoseGridScaling))
    y_all = [y_all;yD*doseI.DoseGridScaling];
    hold on
end
xlabel('mm')
ylabel('G(r)')
title('IntraoperativeTrementPlan_1 total seeds')


yDm = mean(y_all,1);
figure
plot(xD,yDm/max(yDm))
hold on
x = [0.1 0.15 0.25 0.5 0.75 1.00 1.5 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]*10;
y = [0.544 0.7 0.876 0.999 1.013 1.00 0.943 0.864 0.698 0.546 0.420 0.318 0.239 0.178 0.133 0.0980];

plot(x,y,'--')
xlabel('mm')
ylabel('G(r)')
title('IntraoperativeTrementPlan_1 mean')
grid on

%% F( r,theta )

ref_sheet = [0.863 0.524 0.423 0.453 0.500 0.564 0.607;
    0.865 0.489 0.616 0.701 0.702 0.706 0.720;
    0.784 0.668 0.599 0.611 0.637 0.657 0.682;
    0.861 0.588 0.575 0.603 0.632 0.655 0.682;
    0.778 0.562 0.579 0.617 0.649 0.672 0.700;
    0.889 0.688 0.698 0.722 0.750 0.761 0.781;
    0.949 0.816 0.808 0.819 0.841 0.838 0.845;
    0.979 0.898 0.888 0.891 0.903 0.901 0.912;
    0.959 0.956 0.943 0.941 0.950 0.941 0.945;
    0.980 0.988 0.968 0.980 0.985 0.973 0.982;
    0.989 0.973 1.005 1.002 1.011 0.995 0.998;
    0.994 0.994 0.989 1.015 1.018 1.003 1.011;
    1.000 1.000 1.000 1.000 1.000 1.000 1.000;];

ref_col = [0.25 0.5 1 2 3 5 7]*10; %r in mm
ref_row = [0 2 5 7 10 20 30 40 50 60 70 80 90]; % degree
y = [];
x_deg = [];
x_len = [];

for i = 1:length(dTrue)
    len = dTrue(i,3);
    rad = dTrue(i,4);
    ref_r = find(abs(ref_row-rad*180) == min(abs(ref_row-rad*180)));
    ref_c = find(abs(ref_col-len) == min(abs(ref_col-len)));
    point = ref_sheet(ref_r, ref_c);
    disp(point)
    x_deg = [x_deg, ref_row(ref_r)];
    x_len = [x_len, ref_col(ref_c)];
    y = [y,point];
end


figure
[sort_deg,loc] = sort(x_deg);
plot(sort_deg,y(loc),'o');
xlabel('deg')
ylabel('F(r,theta)')
figure
[sort_len,loc] = sort(x_len);
plot(sort_len,y(loc),'o');
xlabel('r(mm)')
ylabel('F(r,theta)')


