% % <summary>
% % Task 4.0: Isodose and Quadrant specific strand location
% % </summary>
% % <remarks>
% %  Author:            SG
% %                     (C) Heidelberg University
% %  Project name:      Seed train positions (orientation and trajectories) of
% %                     the pre-plan and the final intra-operative implant using dicom files:
% %
% %  Date:              2021-07-18
% % </remarks>
% % % % % % % % % % % % % % % % % % % %


clc, close all, clear all
%% DVH  plot
figure
subplot(1,2,1)
[x,yp] = PullDVH("C:\Users\Data\histogram_DVH_pre and Intra op plans\P1_Intra-OP - Preop- DVH Data.txt");

x(1,1) = 0;
yp(1,1) = 0;

plot(x,yp,'r--')
hold on
[x,yp_io] = PullDVH("C:\Users\Data\histogram_DVH_pre and Intra op plans\P1_Intra-OP - Intraop - DVH Data.txt");

x(1,1) = 0;
yp_io(1,1) = 0;
plot(x,yp_io,'r')

% OAR 1
[x,yr] = PullDVH("C:\Users\Data\histogram_DVH_pre and Intra op plans\P1_Rectum Intra-OP - Preplan - DVH Data.txt");
plot(x,yr,'g--')

[x,yr_io] = PullDVH("C:\Users\Data\histogram_DVH_pre and Intra op plans\P1_Rectum Intra-OP - Intraop - DVH Data.txt");
plot(x,yr_io,'g')

% OAR 2
[x,yu] = PullDVH("C:\Users\Data\histogram_DVH_pre and Intra op plans\P1_Urethra Intra-OP - Preplan - DVH Data.txt");
plot(x,yu,'b--')

[x,yu_io] = PullDVH("C:\Users\Data\histogram_DVH_pre and Intra op plans\P1_Urethra Intra-OP - Intraop - DVH Data.txt");
plot(x,yu_io,'b')

legend("Plan Target","IntraOp Target","Plan Rectum","IntraOp Rectum","Plan Urethra","IntraOp Urethra")
xlabel('Dose (Gy)')
ylabel('% Volume')

subplot(1,2,2)
[x,yp_p2] = PullDVH("C:\Users\Data\histogram_DVH_pre and Intra op plans\P2_Intra-OP - Preop- DVH Data.txt");

x(1,1) = 0;
yp_p2(1,1) = 0;

plot(x,yp_p2,'r--')
hold on

[x,yp_io_p2] = PullDVH("C:\Users\Data\histogram_DVH_pre and Intra op plans\P2_Intra-OP - Intraop - DVH Data.txt");
x(1,1) = 0;
yp_io_p2(1,1) = 0;

plot(x,yp_io_p2,'r')
legend("Plan Target_ P2","IntraOp Target_ P2")
xlabel('Dose (Gy)')
ylabel('% Volume')
%% p1 u/r isodose D90
isodose_u = DXX(90, x, yu);
isodose_u_io = DXX(90, x, yu_io);
isodose_r = DXX(90, x, yr);
isodose_r_io = DXX(90, x, yr_io);
isodose_p = DXX(90, x, yp);
isodose_p_io = DXX(90, x, yp_io);

%% Find Volume difference
%% Delta_vol_Pat1
xverts_plan_p1 = x(1:1:end);
yverts_plan_p1 = yp(1:1:end);
p1 = patch(xverts_plan_p1,yverts_plan_p1,'g');%,'LineWidth',0,5);
Vol_plan_p1 = trapz(yp);
cvol_plan_p1 = cumtrapz(yp);

yverts_io = [yp_io(1:end)];
Vol_io_p1 = trapz(yp_io);
cvol_io_p1 = cumtrapz(yp_io);
Delta_vol_p1 = Vol_io_p1 - Vol_plan_p1
%% P1 pre D90 isodose curve p/r/u
dose = squeeze(dicomread('C:\Users\Data\Pat1_Preplan\DO001.dcm'));
doseI = dicominfo('C:\Users\Data\Pat1_Preplan\DO001.dcm');
total_area_pre = 0;
col = [];
for i = 1:size(dose,3)
    figure;
    imshow(dose(:,:,i),[]);axis on; hold on
    contour(dose(:,:,i)*doseI.DoseGridScaling,'ShowText','on');set(gca, 'YDir','reverse');
    if sum((dose(:,:,i)*doseI.DoseGridScaling)>=isodose_p,'all') >=1
        hold on
        contour(dose(:,:,i)*doseI.DoseGridScaling,[isodose_p,isodose_p],'LineColor','r','LineWidth',3,'ShowText','on');set(gca, 'YDir','reverse');
        hold on
        contour(dose(:,:,i)*doseI.DoseGridScaling,[isodose_r,isodose_r],'LineColor','g','LineWidth',3,'ShowText','on');set(gca, 'YDir','reverse');
        hold on
        contour(dose(:,:,i)*doseI.DoseGridScaling,[isodose_u,isodose_u],'LineColor','y','LineWidth',3,'ShowText','on');set(gca, 'YDir','reverse');
        [area,~,~] = Contour2Area(contour(dose(:,:,i)*doseI.DoseGridScaling,[isodose_p,isodose_p]));
        title(['area: ',num2str(area)])
        col = [col;[i, sum(area,'all')]];
    end
    %     waitforbuttonpress
    
end

for i = 1:length(col)-1
    volu_inter = (col(i,2) + col(i+1,2))*5/2;
    total_area_pre = total_area_pre + volu_inter;
end
disp(sum(total_area_pre/1000,'all'))

%% P1 interaoperative D90 isodose curves p/r/u
dose = squeeze(dicomread('C:\Users\Data\Pat1_IntraoperativeTrementPlan\DO001.dcm'));
doseI = dicominfo('C:\Users\Data\Pat1_IntraoperativeTrementPlan\DO001.dcm');
total_area_inter = 0;
col = [];
for i = 1:size(dose,3)
    figure;
    imshow(dose(:,:,i),[]);axis on; hold on
    contour(dose(:,:,i)*doseI.DoseGridScaling,'ShowText','on');set(gca, 'YDir','reverse');
    if sum((dose(:,:,i)*doseI.DoseGridScaling)>=isodose_p_io,'all') >=1
        hold on
        contour(dose(:,:,i)*doseI.DoseGridScaling,[isodose_p_io,isodose_p_io],'LineColor','r','LineWidth',3,'ShowText','on');set(gca, 'YDir','reverse');
        hold on
        contour(dose(:,:,i)*doseI.DoseGridScaling,[isodose_r_io,isodose_r_io],'LineColor','g','LineWidth',3,'ShowText','on');set(gca, 'YDir','reverse');
        hold on
        contour(dose(:,:,i)*doseI.DoseGridScaling,[isodose_u_io,isodose_u_io],'LineColor','y','LineWidth',3,'ShowText','on');set(gca, 'YDir','reverse');
        
        [area,~,~] = Contour2Area(contour(dose(:,:,i)*doseI.DoseGridScaling,[isodose_p_io,isodose_p_io]));
        title(['area: ',num2str(sum(area,'all'))])
        col = [col;[i, sum(area,'all')]];
    end
    
    %     waitforbuttonpress
    
end

for i = 1:length(col)-1
    volu_inter = (col(i,2) + col(i+1,2))*5/2;
    total_area_inter = total_area_inter + volu_inter;
end
disp(sum(total_area_inter/1000,'all'))

%% P1 prostate volume diff (based on D90 curve)
fprintf(['P1 prostate volume diff (based on D90 curve) = ',num2str(sum(total_area_inter/1000,'all')-sum(total_area_pre/1000,'all')),'ml\n']);

%% P1 dose map diff visual
dosePre = squeeze(dicomread('C:\Users\Data\Pat1_Preplan\DO001.dcm'));
dosePost = squeeze(dicomread('C:\Users\Data\Pat1_IntraoperativeTrementPlan\DO001.dcm'));
doseDelta = abs(dosePost-dosePre);
for i = 1:14
    %     disp(i)
    figure;
    subplot(1,3,1)
    imshow(dosePre(:,:,i),[]);axis on; hold on
    colormap(jet(256));
    contour(dosePre(:,:,i)*doseI.DoseGridScaling,'ShowText','on');set(gca, 'YDir','reverse');
    title('Preplan')
    
    subplot(1,3,2)
    imshow(dosePost(:,:,i),[]);axis on; hold on
    colormap(jet(256));
    contour(dosePost(:,:,i)*doseI.DoseGridScaling,'ShowText','on');set(gca, 'YDir','reverse');
    title('Intraoperative plan')
    subplot(1,3,3)
    imshow(doseDelta(:,:,i),[]);axis on; hold on
    colormap(jet(256));
    contour(doseDelta(:,:,i)*doseI.DoseGridScaling,'ShowText','on');set(gca, 'YDir','reverse');
    title('Difference')
    
end

doseDeltaInterp = interp3(cast(doseDelta,"double"));
figure
a = slice(doseDeltaInterp,[],[],[1:1:10]);
shading flat
alpha(a, 0.5)
subt = ["Pre-plan","IntraOperative","Difference"];
figure
dose = {dosePre,dosePost, doseDelta};
for  l = 1:1:3
    doseDeltaInterp = interp3(cast(dose{l},"double"));
    subplot(1,3,l)
    aval = 0.0;
    i = 1;
    col = ["white",'blue',"green","yellow","red"];
    for j = 0:max(doseDeltaInterp,[],"all")/5:max(doseDeltaInterp,[],"all")*0.99
        b = patch(isosurface(doseDeltaInterp,j),"FaceAlpha",aval);
        
        b.FaceColor = col(i);
        b.EdgeColor = 'none';
        daspect([1 1 1])
        view(3);
        axis tight
        camlight
        lighting gouraud
        grid minor
        i = i +1;
        aval = aval + 0.2;
    end
    title(subt(l))
end
sgtitle("Patient 1")

%Pull Quad Data
quadStats = cell(4,4);
q = 1;
figure
for i = [1,40]
    for j = [1,40]
        subplot(2,2,q)
        quad = cast(doseDelta(i:i+40,j:j+40,:),"double");
        %         disp(size(quad))
        hist(reshape(quad,[1,41*41*14]))
        quadStats{q,1} = quad;
        quadStats{q,3} = std(quad,[],"all");
        quadStats{q,2} = mean(quad,"all");
        quadStats{q,4} = median(quad,"all");
        title(['q=', num2str(q),' mean=', num2str(mean(quad,"all"))])
        q = q+1;
    end
end
%% bar plot (std mean) for P1 prostate (4 region)

x = [];
for i=1:4
    x = [x;quadStats{i,2},quadStats{i,3}];
end
figure
bar(x(:,1))
hold on
er = errorbar([1:1:length(x)],x(:,1),x(:,2)/2,x(:,2)/2);
er.Color = [0 0 0];
er.LineStyle = 'none';
set(gca,'xticklabel',{'P1Q1','P1Q2','P1Q3','P1Q4'})
legend('mean','std')
%% (D90 curve p/r/u) for all slices

dosePre = squeeze(dicomread('C:\Users\Data\Pat1_Preplan\DO001.dcm'));
dosePost = squeeze(dicomread('C:\Users\Data\Pat1_IntraoperativeTrementPlan\DO001.dcm'));

dosemap = sum(dosePre,3);
ma = max(dosemap,[],'all');
mi = min(dosemap,[],'all');
dosemap_16 = uint16((dosemap-mi)/(ma-mi)*65536);

spot = {};
for i = 1:80
    [~, loc] = findpeaks([single(dosemap_16(i,:))]);
    %     disp(size(loc))
    if size(loc)==[1,1]
        spot{i} = loc;
    else
        spot{i} = loc;
    end
end

spot_v = {};
for i = 1:80
    [~, loc] = findpeaks([single(dosemap_16(:,i))]);
    %     disp(size(loc))
    if size(loc)==[1,1]
        spot_v{i} = loc;
    else
        spot_v{i} = loc;
    end
end

testmap = zeros(80,80);
for i = 1:80
    testmap(i,spot{i}) = testmap(i,spot{i}) + 1;
end
for i = 1:80
    testmap(spot_v{i},i) = testmap(spot_v{i},i) + 1;
end

dosemap2 = sum(dosePost,3);
ma = max(dosemap2,[],'all');
mi = min(dosemap2,[],'all');
dosemap_16 = uint16((dosemap2-mi)/(ma-mi)*65536);

spot = {};
for i = 1:80
    [~, loc] = findpeaks([single(dosemap_16(i,:))]);
    %     disp(size(loc))
    if size(loc)==[1,1]
        spot{i} = loc;
    else
        spot{i} = loc;
    end
end

spot_v = {};
for i = 1:80
    [~, loc] = findpeaks([single(dosemap_16(:,i))]);
    %     disp(size(loc))
    if size(loc)==[1,1]
        spot_v{i} = loc;
    else
        spot_v{i} = loc;
    end
end

testmap2 = zeros(80,80);
for i = 1:80
    testmap2(i,spot{i}) = testmap2(i,spot{i}) + 1;
end
for i = 1:80
    testmap2(spot_v{i},i) = testmap2(spot_v{i},i) + 1;
end

figure;
subplot(1,2,1)
imshow(testmap==2,[])
subplot(1,2,2)
imshow(testmap2==2,[])

for i = 1:size(dosePost,3)
    
    figure
    imshow(testmap==2,[])
    hold on
    pre = dosePre(:,:,i);
    post = dosePost(:,:,i);
    doseI = dicominfo('C:\Users\Data\Pat1_Preplan\DO001.dcm');
    contour(pre*doseI.DoseGridScaling,[isodose_p,isodose_p],'LineColor','r','LineWidth',1,'ShowText','off');set(gca, 'YDir','reverse');
    hold on
    contour(pre*doseI.DoseGridScaling,[isodose_r,isodose_r],'LineColor','g','LineWidth',1,'ShowText','off');set(gca, 'YDir','reverse');
    hold on
    contour(pre*doseI.DoseGridScaling,[isodose_u,isodose_u],'LineColor','y','LineWidth',1,'ShowText','off');set(gca, 'YDir','reverse');
    hold on
    % [area2,~,~] = Contour2Area(contour(post*doseI.DoseGridScaling,[isodose_p_io,isodose_p_io]));
    contour(post*doseI.DoseGridScaling,[isodose_p_io,isodose_p_io],'LineColor','r','LineWidth',1,'LineStyle','-.','ShowText','off');set(gca, 'YDir','reverse');
    hold on
    contour(pre*doseI.DoseGridScaling,[isodose_r_io,isodose_r_io],'LineColor','g','LineWidth',1,'LineStyle','-.','ShowText','off');set(gca, 'YDir','reverse');
    hold on
    contour(pre*doseI.DoseGridScaling,[isodose_u_io,isodose_u_io],'LineColor','y','LineWidth',1,'LineStyle','-.','ShowText','off');set(gca, 'YDir','reverse');
    hold on
    line([1,80],[40,40]);hold on; line([40,40],[1,80]);
    legend({'Preplan','Preplan rectum','Preplan urethra','Intraoperative','Intraoperative rectum','Intraoperative urethra'},'Location','eastoutside')
    set(gca,'position',[0,0,1,1])
    
    %     waitforbuttonpress
    
end
%% P1 sum stack/ isodose curve for p/r/u (D90 V100/ D90 V150)
%D90 V100
dosePre = squeeze(dicomread('C:\Users\Data\Pat1_Preplan\DO001.dcm'));
dosePost = squeeze(dicomread('C:\Users\Data\Pat1_IntraoperativeTrementPlan\DO001.dcm'));
dosePre = sum(dosePre,3)/14;
dosePost = sum(dosePost,3)/14;
figure
subplot(1,2,1)
t = zeros([80,80,3]);
t(:,:,1) = (testmap==2);
t(:,:,2) = (testmap2==2);
imshow(t,[])
hold on
doseI = dicominfo('C:\Users\Data\Pat1_Preplan\DO001.dcm');
[C,h] = contour(dosePre*doseI.DoseGridScaling,[isodose_p,isodose_p],'LineColor','r','LineWidth',1,'ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
[C,h] = contour(dosePre*doseI.DoseGridScaling,[isodose_r,isodose_r],'LineColor','g','LineWidth',1,'ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
[C,h] = contour(dosePre*doseI.DoseGridScaling,[isodose_u,isodose_u],'LineColor','y','LineWidth',1,'ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
[C,h] = contour(dosePost*doseI.DoseGridScaling,[isodose_p_io,isodose_p_io],'LineColor','r','LineWidth',1,'LineStyle','-.','ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
[C,h] = contour(dosePost*doseI.DoseGridScaling,[isodose_r_io,isodose_r_io],'LineColor','g','LineWidth',1,'LineStyle','-.','ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
[C,h] = contour(dosePost*doseI.DoseGridScaling,[isodose_u_io,isodose_u_io],'LineColor','y','LineWidth',1,'LineStyle','-.','ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
line([1,80],[40,40]);hold on; line([40,40],[1,80]);
legend({'Preplan prostate','Preplan rectum','Preplan urethra','Intraoperative','Intraoperative rectum','Intraoperative urethra'},'Location','eastoutside')
title(['D90 V100 Patient1'])


% D90 V150
subplot(1,2,2)
t = zeros([80,80,3]);
t(:,:,1) = (testmap==2);
t(:,:,2) = (testmap2==2);
imshow(t,[])
hold on
% [area,~,~] = Contour2Area(contour(pre*doseI.DoseGridScaling,[isodose_p,isodose_p]));
[C,h] = contour(dosePre*doseI.DoseGridScaling,[isodose_p*1.5,isodose_p*1.5],'LineColor','r','LineWidth',1,'ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
[C,h] = contour(dosePre*doseI.DoseGridScaling,[isodose_r*1.5,isodose_r*1.5],'LineColor','g','LineWidth',1,'ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
[C,h] = contour(dosePre*doseI.DoseGridScaling,[isodose_u*1.5,isodose_u*1.5],'LineColor','y','LineWidth',1,'ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
% [area2,~,~] = Contour2Area(contour(post*doseI.DoseGridScaling,[isodose_p_io,isodose_p_io]));
[C,h] = contour(dosePost*doseI.DoseGridScaling,[isodose_p_io*1.5,isodose_p_io*1.5],'LineColor','r','LineWidth',1,'LineStyle','-.','ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
[C,h] = contour(dosePost*doseI.DoseGridScaling,[isodose_r_io*1.5,isodose_r_io*1.5],'LineColor','g','LineWidth',1,'LineStyle','-.','ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
[C,h] = contour(dosePost*doseI.DoseGridScaling,[isodose_u_io*1.5,isodose_u_io*1.5],'LineColor','y','LineWidth',1,'LineStyle','-.','ShowText','on');set(gca, 'YDir','reverse');
clabel(C,h,'FontSize',7,'LabelSpacing',1000,'Color','w')
hold on
line([1,80],[40,40]);hold on; line([40,40],[1,80]);
legend({'Preplan Preplan','Preplan rectum','Preplan urethra','Intraoperative','Intraoperative rectum','Intraoperative urethra'},'Location','eastoutside')
title(['D90 V150 Patient1'])




