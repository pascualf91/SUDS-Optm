%Erase All
clc; clear all; close all

%Define Paths
p_root = 'C:\Users\pascu\Dropbox\Pascual\UPV PhD\6. Pasantia TUD\Swmm models dresden';
p_results = strcat(p_root, '\Results\Results');
p_figures = strcat('C:\Users\pascu\Dropbox\Pascual\UPV PhD\6. Pasantia TUD\Swmm models dresden\Results\Figures');
p_SUDS_Sce = 'C:\Users\pascu\Dropbox\Pascual\UPV PhD\6. Pasantia TUD\Swmm models dresden\Input Information\SUDS_Scenario';

%Loads the info 
cd(p_results)
Files_Names=importdata('Files_Names.txt');
Legends=importdata('Legend.txt');

%Carga en un Structur los datos fval de todas las ciudades
for i =1:length(Files_Names)
    Data(i).data = load(strcat(Files_Names{i,1},'.mat'));
end
cd(p_root)


%Loads info for base models (no SUDS)
cd(p_SUDS_Sce)
base_flood = importdata('Flooding_no_SUDS.txt');


%Calculates the cost-efficient scenario
reduction=[];
cost_efficient=[];

for i= 1:length(Data)
    for j= 1:length(Data(i).data.fval)
        reduction(j) = base_flood(i,2) - Data(i).data.fval(j,1);
        cost_efficient(j) =  reduction(j)/Data(i).data.fval(j,2);

        most_cost_efficient(i,1) = j;
        most_cost_efficient(i,2) = max(cost_efficient);
    end
    reduction=[];
    cost_efficient=[];
end



% %Pareto Fronts Figure
% figure(2)
% scatter(Data(1).data.fval(:,1), Data(1).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black');
% hold on
% for i =2:12
%     scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black');
% end
% hold off
% clrs = distinguishable_colors(12);
% colororder(clrs)
% %title('Pareto Front')
% xlabel('Total Flooded Volume (m^3)')
% ylabel('Cost(M€)')
% legend(Legends{:,1}, 'Location', 'southoutside', 'NumColumns', 4);
% grid on
% set(gca, 'XScale', 'log')
% set(gca, 'YScale', 'log')
% cd(p_figures)
% saveas(gcf,'2) Pareto Front Multiple 2.png')
% cd(p_root)
% close
% 
% 
% 
%Pareto Front with history

for i =1:59
    for j=1:length(Data(1).data.gascorehistory(:, 2, i))
        if Data(1).data.gascorehistory(j, 2, i) ==4.40733
            id = i;
        else
            id = -999;
        end
    end
end

figure(3)
scatter(Data(1).data.fval(:,1), Data(1).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black');
hold on
for i =1:59
    scatter(Data(1).data.gascorehistory(:,1, i), Data(1).data.gascorehistory(:, 2, i), 'filled', 'MarkerEdgeColor','black');
end
hold off
clrs = hot(60);
colororder(clrs)
%title('Pareto Front with Generations History')
%legend
xlabel('Total Flooded Volume (m^3)')
ylabel('Cost(M€)')
grid on
%colorbar
%set(gca, 'XScale', 'log')
cd(p_figures)
saveas(gcf,'3) Pareto Front History.png')
cd(p_root)
close


%Pareto Fronts Figure
figure(1)
scatter(Data(1).data.fval(:,1), Data(1).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'Marker', 'square', 'MarkerFaceColor','red');
hold on
for i =2:3
    if i==2
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'Marker', 'diamond', 'MarkerFaceColor','red');
    else
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'MarkerFaceColor','red');
    end
end

for i =4:6
    if i==4
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'Marker', 'square', 'MarkerFaceColor','blue');
    elseif i==5
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'Marker', 'diamond', 'MarkerFaceColor','blue');
    else
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'MarkerFaceColor','blue');
    end
end
for i =7:9
    if i==7
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'Marker', 'square', 'MarkerFaceColor','yellow');
    elseif i==8
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'Marker', 'diamond', 'MarkerFaceColor','yellow');
    else
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'MarkerFaceColor','yellow');
    end
end

for i =10:12
    if i==10
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'Marker', 'square', 'MarkerFaceColor','green');
    elseif i==11
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'Marker', 'diamond', 'MarkerFaceColor','green');
    else
        scatter(Data(i).data.fval(:,1), Data(i).data.fval(:, 2), 'filled', 'MarkerEdgeColor','black', 'MarkerFaceColor','green');
    end
end
hold off
title('Pareto Front')
xlabel('Total Flooded Volume (m^3)')
ylabel('Cost(M€)')
%legend(Legends{:,1}, 'Location', 'bestoutside');
grid on
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
cd(p_figures)
saveas(gcf,'1) Pareto Front Multiple 1.png')
cd(p_root)
close